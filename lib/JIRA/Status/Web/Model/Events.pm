package JIRA::Status::Web::Model::Events;

use Moose;
use JIRA::Status::Web::Types qw/JIRAModel/;

has 'jira' => (
    is => 'ro', isa => JIRAModel, coerce => 1,
    handles => [qw/
        next_issue filter_issues all_releases 
        get_active_releases get_active_releases_by_month
        get_recent_failed_releases get_recent_successfull_releases
        get_status get_status_list
    /],
);



1;