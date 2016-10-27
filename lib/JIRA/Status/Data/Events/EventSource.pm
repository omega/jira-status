use MooseX::Declare;
namespace JIRA::Status::Data::Events;

#PODNAME: JIRA::Status::Data::Events::EventSource

class ::EventSource {
    use Class::Load;

    has 'name' => (is => 'ro', isa => 'Str', required => 1);

    method instance($class: Str:$type, HashRef:$args) {
        my $source_class = 'JIRA::Status::Data::Events::EventSource::' . $type;

        Class::Load::load_class($source_class); # Just for safety
        $source_class->new($args);
    }
}

class ::EventSource::JIRA extends ::EventSource {
    use DateTime;
    use DateTime::Format::DateParse;
    use Data::Dump qw/dump/;

    use JIRA::Status::Web::Types qw/JIRAClient/;

    use JIRA::Status::Data::Events::Event;
    has 'client' => (
        is => 'ro',
        isa => JIRAClient,
        coerce => 1,
        handles => [qw/set_search_iterator getSavedFilters get_issue_types/],
    );

    has 'custom_fields' => ( is => 'ro', isa => 'HashRef', required => 0);

    has '_remote_statuses' => (
        is => 'ro',
        isa => 'HashRef',
        lazy => 1,
        builder => '_build_remote_statuses',
    );
    sub _build_remote_statuses {
        my $self = shift;

        my $statuses = $self->client->GET('/status');

        my %statuses = map { ( $_->{id} => $_ ) } @$statuses;

        \%statuses;
    }
    sub next_issue {
        my $self = shift;
        my $issue = $self->client->next_issue;
        return unless $issue;
        # Inflate some dates
        $issue->{fields}->{updated} = $self->_inflate_date($issue->{fields}->{updated});
        $issue->{fields}->{duedate} = $self->_inflate_date($issue->{fields}->{duedate}) if $issue->{fields}->{duedate};
        $issue->{fields}->{status} = $self->get_status($issue->{fields}->{status}->{id});
        my $threshold = DateTime->now()->subtract(days => 7);
        if ($issue->{fields}->{status}->{name} ne 'In development' and $threshold > $issue->{fields}->{updated}) {
            $issue->{overdue} = 1;
        }
        # Add a link
        $issue->{fields}->{link} = "http://bugs.startsiden.no" . '/browse/' . $issue->{key};

        # need to figure out the custom-fields, if we have some
        my $i = $self->client->GET('/issue/' . $issue->{key}, { expand => 'editmeta' } );
        foreach my $key (keys %{ $self->custom_fields }) {
            my $id = $self->custom_fields->{$key};
            if ($i->{fields}->{"customfield_$id"}) {
                $issue->{fields}->{$key} = $i->{fields}->{"customfield_$id"}->{value};
            }
        }
        return $issue;
    }

    sub _inflate_date {
        my ($self, $date) = @_;
        return unless $date;
        $date = DateTime::Format::DateParse->parse_datetime($date);
        $date->set_time_zone('Europe/Oslo');
        $date->set_time_zone('floating'); # We do this to make sure epoch value is correct in the other end.

        return $date;
    }

    has '_issues' => (
        traits => ['Array'],
        is => 'ro',
        isa => 'ArrayRef',
        lazy => 1,
        builder => '_get_issues',
        handles => {
            filter_issues => 'grep',
            all_releases => 'elements',
        },
    );
    sub _get_issues {
        my ($self) = @_;
        my @issues;
        $self->set_search_iterator({
            jql => 'filter = "Active releases"',
            maxResults => 16,
            fields     => [ qw/summary status updated duedate resolution link project team assignee/  ],

        });
        while (my $issue = $self->next_issue()) {
            push(@issues, $issue);
        }

        return \@issues;

    }
    sub get_active_releases {
        my ($self) = @_;
        return [ $self->filter_issues(sub { !$_->{fields}->{resolution} }) ];
    }
    sub get_active_releases_by_month {
        my ($self, $month) = @_;

        # Need to make it into an hash
        my @issues = $self->all_releases;

        my $date_hash;
        foreach my $issue (@issues) {
            next unless $issue->{fields}->{duedate};
            push(@{ $date_hash->{ $issue->{fields}->{duedate}->ymd } }, $issue);
        }

        return $date_hash;
    }
    sub get_recent_failed_releases {
        my ($self) = @_;
        return [ $self->filter_issues(sub { $_->{fields}->{resolution} and $_->{fields}->{resolution} == 6 }) ];
    }
    sub get_recent_successfull_releases {
        my ($self) = @_;
        return [ $self->filter_issues(sub { $_->{fields}->{resolution} and $_->{fields}->{resolution} == 1 }) ];
    }

    sub get_status {
        my ($self, $id) = @_;
        return $self->_remote_statuses->{$id};
    }

    sub get_status_list {
        my $self = shift;
        # XXX: This is hardcoded because I can't seem to find a way to find the statuses from
        #      the client API
        my @statuses = map { $self->get_status($_) } (10000, 10007, 10008, 10009, 10012, 10006,);
        return \@statuses;
    }

    method events {
        my @issues;
        # XXX: This is to make sure we only return issues we can process
        foreach ($self->filter_issues(sub { $_->{fields}->{resolution} || $_->{fields}->{duedate} })) {
            my $issue = JIRA::Status::Data::Events::Event::JIRA->new(
                title => $_->{key},
                summary => $_->{fields}->{summary},
                # XXX: This should be $_->resolved, but not available :/
#                datetime => $_->{resolution} ? $_->{updated} : $_->{duedate}, # use updated for resolved issue
                datetime => $_->{fields}->{duedate},
                status => $_->{fields}->{status}->{id},
                resolution => $_->{fields}->{resolution}->{id},
                link => $_->{fields}->{link},
                project => $_->{fields}->{project}->{name},
                team => $_->{fields}->{team},
            );

            push(@issues, $issue);
        }
        @issues;
    }
}

class ::EventSource::iCal extends ::EventSource {
    use Data::ICal::DateTime;
    use MooseX::Types::URI qw(Uri);
    use LWP::Simple;

    has 'ics_url' => (is => 'ro', isa => Uri, coerce => 1, required => 1);

    has '_events' => (
        traits => [qw/Array/], is => 'ro', isa => 'ArrayRef',
        builder => '_fetch_events',
        lazy => 1,
        handles => {
            'add_event' => 'push',
            'events' => 'elements',
        },
    );

    method _fetch_events() {
        # Need to fetch the damn ics_url
        my $ics = get($self->ics_url->as_string) or confess("Could not fetch " . $self->ics_url->as_string);

        my $ical = Data::ICal->new(data => $ics);

        my $events = $ical->entries;
        my @events;
        foreach (@$events) {
            # Lets just do the damn conversion here, no need to coerce later
            next unless $_->ical_entry_type eq 'VEVENT';
            my $props = $_->properties;
            my ($summary) = $_->property('summary');
            if (!$_->end) {
                # This is a full day event
                my $event = JIRA::Status::Data::Events::Event::Fullday->new(
                    title => $summary->[0]->value,
                    datetime => $_->start,
                );
                push(@events, $event);
            } else {
                my $event = JIRA::Status::Data::Events::Event::Timed->new(
                    title => $summary->[0]->value,
                    datetime => $_->start,
                    time => $_->start->strftime('%H:%M'),
                );
                push(@events, $event);
            }
        }
        \@events;
    }
}
class ::EventSource::BlockedDays extends ::EventSource {
    use DateTime;

    method events() {
        # calculate some months ahead of now?
        my $now = DateTime->now()->subtract(months => 1);

        my $end = DateTime->now()->add(months => 3);
        my @events;
        while ($now < $end) {
            if ($now->day_of_week > 4) {# Fri-sun
                my $event = JIRA::Status::Data::Events::Event::Fullday->new(
                    datetime => $now->clone,
                    title => '', # empty, we only want to trigger the red
                );
                push(@events, $event);
            }
            $now->add(days => 1);
        }
        @events if scalar(@events);
    }
}
1;
