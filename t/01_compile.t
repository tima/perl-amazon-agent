#!perl

# Tests that the Amazon::Agent package compiles

use strict;
use warnings;
use Test::More tests => 6;

ok( $] >= 5.004, "Your perl is new enough" ); # fix?

use_ok( 'Amazon::Agent' );
use_ok( 'Amazon::ErrorResponse' );
use_ok( 'Amazon::Request' );
use_ok( 'Amazon::Response' );
use_ok( 'Amazon::Util' );
