#!perl

# Testing of utility function importing

use strict;
use warnings;
use Test::More tests => 6;

use Amazon::Util
  qw(amazon_timestamp amazon_signature is_amazon_error_response);

ok defined &main::amazon_timestamp, 'amazon_timestamp is exported';
ok defined &main::amazon_signature, 'amazon_signature is exported';
ok defined &main::is_amazon_error_response,
  'is_amazon_error_response is exported';

ok \&main::amazon_timestamp == \&Amazon::Util::amazon_timestamp,
  'amazon_timestamp is Amazon::Util';
ok \&main::amazon_signature == \&Amazon::Util::amazon_signature,
  'amazon_signature is Amazon::Util';
ok \&main::is_amazon_error_response
  == \&Amazon::Util::is_amazon_error_response,
  'is_amazon_error_response is Amazon::Util';

# not testing not imported than again isn't that the job of Exporter?
