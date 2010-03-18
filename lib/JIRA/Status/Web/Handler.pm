package JIRA::Status::Web::Handler;
use Moose;
extends 'Tatsumaki::Handler';
__PACKAGE__->asynchronous(1);

sub model {
    return $_[0]->application->model;
}


1;