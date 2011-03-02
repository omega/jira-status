#!/usr/bin/perl -w

use strict;
use Test::More;
use JIRA::Status::Data::Events::EventSource;

unless ($ENV{JIRA_USER} && $ENV{JIRA_PW}) {
    plan skip_all => "You need to set JIRA_USER and JIRA_PW to run this test";
}

my $es = JIRA::Status::Data::Events::EventSource::JIRA->new(
    name => 'jira',
    client => [
        'https://bugs.startsiden.no',
        $ENV{JIRA_USER},
        $ENV{JIRA_PW},
    ],
    project_field => 10070,
);

ok($es);

# now to get the issues, and make sure they work
my @issues = $es->events;
{
    my $issue = $issues[0];
    ok($issue->project);
}

done_testing();
