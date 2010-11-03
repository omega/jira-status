use MooseX::Declare;
namespace JIRA::Status::Data::Events;

class ::EventSet {
    use JIRA::Status::Web::Types qw/Event ArrayOfEvents/;

    has '_events' => (
        traits => [qw/Array/],
        is => 'ro', isa => ArrayOfEvents,
        default => sub { [ ] },
        handles => {
            'add_event' => 'push',
            'events' => 'elements',
            '_grep' => 'grep',
        },
    );

    method as_date_hash() {
        my $date_hash = {};
        foreach ($self->events) {
            push(@{ $date_hash->{ $_->datetime->ymd } }, $_);
        }
        return $date_hash;
    }

    method old_events(DateTime $limit, DateTime $oldest?) {
        my $l = $limit->clone->truncate(to => 'days');
        return [$self->_grep(sub { $_->datetime < $l and (defined($oldest) ? $_->datetime > $oldest : 1) } )];
    }
}
1;
