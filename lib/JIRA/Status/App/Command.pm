package JIRA::Status::App::Command;

use Moose;
use JIRA::Status::Config;
use JIRA::Status::Data::Db;

extends qw(MooseX::App::Cmd::Command);

with qw(JIRA::Status::Config::Role JIRA::Status::Data::Db::Role);

1;

