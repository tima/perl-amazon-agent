package Amazon::Agent;
use strict;
use warnings;

use base qw( Class::ErrorHandler );

use XML::Simple;
use Data::Dumper;

use Amazon::Util qw( is_amazon_error_response );

our $VERSION = '0.01';

# create generate_query name routine in Request. Add to class processing.

# fix error response to handle different known error structures
# testing plan. best way? via file://
# CAVEAT: if last_error object falls out of the history calling errors won't produce anything.

# TO DO in P2
# S3 Support or special agent for Amazon::S3
# Default to Determined Agent?
# Bezos support if not P1
# Expires using relative codes.
# History "count" with constants - silent (0), default(10), debug(100), verbose(1000);
#
# P3+
# hook to log/store history

sub new {
    my ($class, %param) = @_;
    my $self = bless \%param, $class;
    die "No aws_access_key_id"     unless $self->{aws_access_key_id};
    die "No aws_secret_access_key" unless $self->{aws_secret_access_key};
    die "No aws_endpoint"          unless $self->{aws_endpoint};
    unless ($self->{user_agent}) {
        require LWP::UserAgent;
        $self->{user_agent} = LWP::UserAgent->new;
    }
    $self->{request_class}  ||= 'Amazon::Request';
    $self->{response_class} ||= 'Amazon::Response';
    $self->{error_class}    ||= 'Amazon::ErrorResponse';
    $self->{user_agent}->agent(join '/', $class, $class->VERSION)
      if $self->{user_agent}->agent =~ /^libwww-perl/;
    $self->{xml_force_array} ||= [];
    push @{$self->{xml_force_array}},
      'Errors';    # dups ok or do we have to check?
    $self->{history} = [];
    $self;
}

sub request {
    my ($self, %params) = @_;
    my $request_class  = delete $params{request_class};
    my $response_class = delete $params{response_class};
    my $error_class    = delete $params{error_class};
    $request_class       ||= $self->{request_class};
    $response_class      ||= $self->{response_class};
    $error_class         ||= $self->{error_class};
    # $params{http_method} ||= 'GET';
    # add access and secret
    eval "use $request_class;";
    return $self->error($@) if $@;
    my $req     = $request_class->new(%params);
    my $ua      = $self->{user_agent};
    my $res     = $ua->request($req);
    my $content = $res->content;
    if (defined($content) && $content ne '') {
        my $tree;
        eval {
            $tree =
              XMLIn(
                    $content,
                    'ForceArray' => $self->{xml_force_array},
                    'KeepRoot'   => 1,
              );
        };
        return $self->error($@) if $@;
        $content = $tree;
    }
    my $use_class =
      is_amazon_error_response($res)
      ? $error_class
      : $response_class;
    eval "use $use_class;";
    return $self->error($@) if $@;
    my $args = {
                'http_response' => $res,
                'content'       => $content,
                'response_type' => $res->header('Content-Type');
    };
    my $fetch = $use_class->new($args);
    unshift @{$self->{history}}, $fetch;
    while (exists $self->{history}->[10]) {   # 10 needs to be a config variable
        pop @{$self->{history}};
    }
    $self->{last_error} = $fetch if $use_class eq $error_class;
    return $fetch;
}

#--- history management methods

sub last_response         { return $_[0]->{history}->[0]; }
sub last_error            { return $_[0]->{last_error}; }
sub dump_response_history { return Dumper($_[0]->{history}); }
sub response_history      { return @{$self->{history}}; }

sub errors {
    grep { $_->is_error } @{$_[0]->{history}};
}

1;

__END__

=head1 NAME

URI::Fetch - Smart URI fetching/caching

=head1 SYNOPSIS

    use URI::Fetch;

    ## Simple fetch.
    my $res = URI::Fetch->fetch('http://example.com/atom.xml')
        or die URI::Fetch->errstr;

    ## Fetch using specified ETag and Last-Modified headers.
    my $res = URI::Fetch->fetch('http://example.com/atom.xml',
            ETag => '123-ABC',
            LastModified => time - 3600,
    )
        or die URI::Fetch->errstr;

    ## Fetch using an on-disk cache that URI::Fetch manages for you.
    my $cache = Cache::File->new( cache_root => '/tmp/cache' );
    my $res = URI::Fetch->fetch('http://example.com/atom.xml',
            Cache => $cache
    )
        or die URI::Fetch->errstr;

=head1 DESCRIPTION

I<URI::Fetch> is a smart client for fetching HTTP pages, notably
syndication feeds (RSS, Atom, and others), in an intelligent,
bandwidth- and time-saving way. That means:

=over 4

=item * GZIP support

If you have I<Compress::Zlib> installed, I<URI::Fetch> will automatically
try to download a compressed version of the content, saving bandwidth (and
time).

=item * I<Last-Modified> and I<ETag> support

If you use a local cache (see the I<Cache> parameter to I<fetch>),
I<URI::Fetch> will keep track of the I<Last-Modified> and I<ETag> headers
from the server, allowing you to only download pages that have been
modified since the last time you checked.

=item * Proper understanding of HTTP error codes

Certain HTTP error codes are special, particularly when fetching syndication
feeds, and well-written clients should pay special attention to them.
I<URI::Fetch> can only do so much for you in this regard, but it gives
you the tools to be a well-written client.

The response from I<fetch> gives you the raw HTTP response code, along with
special handling of 4 codes:

=head1 USAGE

=head2 Amazon::Agent->fetch($uri, %param)

Fetches a page identified by the URI I<$uri>.

Returns a I<Amazon::Response> object that can be inspected
for success or failure of an Amazon API call. If the method
returns C<undef> an internal client error has occured. Check
the C<errstr> method for more information.

I<%param> can contain:

=over 4

=item * UserAgent

Optional.  You may provide your own LWP::UserAgent instance.  Look
into L<LWPx::ParanoidUserAgent> if you're fetching URLs given to you
by possibly malicious parties.

=back

=head1 LICENSE

I<URI::Fetch> is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, I<URI::Fetch> is Copyright 2004 Benjamin
Trott, ben+cpan@stupidfool.org. All rights reserved.

=cut
