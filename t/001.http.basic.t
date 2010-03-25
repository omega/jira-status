#!/usr/bin/perl -w

use strict;
use Test::More;
use Plack::Test;
use Plack::Util;

use HTTP::Request::Common;


my $app = Plack::Util::load_psgi('jira-status.psgi');

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        
        for (qw(/ /cal /bigscreen)) {
            my $res = $cb->(GET $_);
            is($res->code, '200', "$_ is 200 OK");
        }
    }
;

done_testing();

