use MooseX::Declare;


class JIRA::Status::Web::Model::Events {
    
    use JIRA::Status::Web::Types qw/JIRAModel/;
    use MooseX::Types::DateTime qw(DateTime);
    
    use JIRA::Status::Web::Model::Events::EventSet;

    has 'jira' => (
        is => 'ro', isa => JIRAModel, coerce => 1,
        handles => [qw/
            next_issue filter_issues all_releases 
            get_active_releases get_active_releases_by_month
            get_recent_failed_releases get_recent_successfull_releases
            get_status get_status_list
        /],
    );


    method get_events_by_month() {
        my $events = JIRA::Status::Web::Model::Events::EventSet->new();

        # Need to make it into an hash
        my @issues = $self->all_releases;

        foreach my $issue (@issues) {
            next unless $issue->{duedate}; # XXX: This is for now, since not all releases have this enforced yet
            $events->add_event($issue);
            #push(@{ $date_hash->{ $issue->{duedate}->ymd } }, $issue);
        }
        
        return $events->as_date_hash();;
    }
}


1;