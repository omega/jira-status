use strict;
use warnings;
use lib qw(lib);

use JIRA::Status::Web::Application;
use JIRA::Status::Web::Handler::Status;
use JIRA::Status::Web::Handler::Calendar;
use JIRA::Status::Web::Handler::Bigscreen;

my $app = JIRA::Status::Web::Application->new([
    "/cal" => 'JIRA::Status::Web::Handler::Calendar',
    '/bigscreen' => 'JIRA::Status::Web::Handler::Bigscreen',
    "/" => 'JIRA::Status::Web::Handler::Status',
    
]);

return $app;
