#!/usr/bin/perl -w

use strict;
use Test::More tests => 1;
use JIRA::Status::Data::Db;


my $db = JIRA::Status::Data::Db->new( 
    dsn => 'MongoDB:database_name=jirastatus;database_host=dev-andreas2.startsiden.no;collection_name=events'
);

ok($db);
