#!perl

# Tests that the Amazon::Agent package compiles

use strict;
use warnings;
use Test::More tests => 7;

ok( $] >= 5.004, "Your perl is new enough" ); # fix?

use_ok( 'Date::Tiny' );
use_ok( 'Agent::Agent.pm' );
use_ok( 'Agent::ErrorResponse.pm' );
use_ok( 'Agent::Request.pm' );
use_ok( 'Agent::Response.pm' );
use_ok( 'Agent::Util.pm' );
