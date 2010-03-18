use strict;
use warnings;

use JIRA::Status::Web::Application;
use JIRA::Status::Web::Handler::Status;
use JIRA::Status::Web::Handler::Calendar;

my $app = JIRA::Status::Web::Application->new([
    "/cal" => 'JIRA::Status::Web::Handler::Calendar',
    "/" => 'JIRA::Status::Web::Handler::Status',
]);

return $app;
