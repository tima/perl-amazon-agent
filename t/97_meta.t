#!perl

# Test that our META.yml file matches the current specification.

use strict;
use warnings;
use Test::More;

my $MODULE = 'Test::CPAN::Meta 0.12';

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

meta_yaml_ok();
