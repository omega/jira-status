use SOAP::Lite +trace => [ all => \&log_faults ];

open LOGFILE,">>", "../soap.log";

sub log_faults {
    my $in = shift;
    print LOGFILE $in . "\n";
}
use strict;
use warnings;

use JIRA::Status::Web::Application;
use Tatsumaki::Error;
use Time::HiRes;
use JIRA::Status::Web::Handler::Status;
use JIRA::Status::Web::Handler::Calendar;

use File::Basename;
use YAML;

my $cfg = YAML::LoadFile('config.yml');

my $app = JIRA::Status::Web::Application->new([
    "/cal" => 'JIRA::Status::Web::Handler::Calendar',
    "/" => 'JIRA::Status::Web::Handler::Status',
],
config => $cfg);

return $app;
