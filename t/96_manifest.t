#!perl

# Test that our MANIFEST file is accurate

use strict;
use warnings;
use Test::More;

# $ENV{MANIFEST_WARN_ONLY} = 1;
# export MANIFEST_WARN_ONLY=1;

my $MODULE = 'Test::DistManifest';

# Don't run tests for installs
unless ( $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING} ) {
	plan( skip_all => "Author tests not required for installation" );
}

# Load the testing module
eval "use $MODULE";
if ( $@ ) {
	$ENV{RELEASE_TESTING}
	? die( "Failed to load required release-testing module $MODULE" )
	: plan( skip_all => "$MODULE not available for testing" );
}
manifest_ok('MANIFEST', 'MANIFEST.SKIP');
