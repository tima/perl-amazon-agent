#!perl

# Test that our code has been tidied

use strict;
use warnings;
use Test::More;

my $MODULE = 'Test::PerlTidy';

# Don't run tests for installs
unless ($ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING}) {
    plan(skip_all => "Author tests not required for installation");
}

# Load the testing module
eval "use $MODULE";
if ($@) {
    $ENV{RELEASE_TESTING}
      ? die("Failed to load required release-testing module $MODULE")
      : plan(skip_all => "$MODULE not available for testing");
}
run_tests();
