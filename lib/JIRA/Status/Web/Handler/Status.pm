package JIRA::Status::Web::Handler::Status;
use base qw(JIRA::Status::Web::Handler);
sub get {
    my $self = shift;
    my $args = {
        issues => $self->model->get_source('jira')->get_active_releases,
        failed => $self->model->get_source('jira')->get_recent_failed_releases,
        rolled => $self->model->get_source('jira')->get_recent_successfull_releases,
        statuses => $self->model->get_source('jira')->get_status_list,
    };
    $self->render('index.tt', $args);
}

1;