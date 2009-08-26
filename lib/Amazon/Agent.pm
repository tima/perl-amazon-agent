package Amazon::Agent;
use strict;
use warnings;

use base qw( Class::ErrorHandler );

use XML::Simple;
use Data::Dumper;

use Amazon::Util qw( is_amazon_error_response );

our $VERSION = '0.01';

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
                'response_type' => $res->header('Content-Type'),
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
sub response_history      { return @{$_[0]->{history}}; }

sub errors {
    grep { $_->is_error } @{$_[0]->{history}};
}

1;

__END__

=begin

=head1 NAME

Amazon::Agent - A generic user agent for making and
receiving requests from Amazon web services.

=head1 SYNOPSIS

=head1 DESCRIPTION

B<This is code is in the early stages of development. Do not
consider it stable. Feedback and patches welcome.>

Testing and further development of this package will be as
packages for working with various AWS services are developed.

=head1 METHODS

=item Amazon::Agent->new

=item $agent->request

=item $agent->last_response

=item $agent->last_error

=item $agent->response_history

=item $agent->dump_response_history

=item $agent->errors

=head1 DEPENDENCIES

L<Class::ErrorHandler>, L<XML::Simple>, L<Data::Dumper>

=head1 TO DO

=over

=item Create generate_query routine in Amazon::Request.

=item Fix error response handling to handle different forms
of error responses from AWS services.

=item Testing plan needs additional work. What is the best
way to test this without calling actual services?

=item Decide if S3 support can be worked or if special agent for Amazon::S3

=item AWS account object handling support once developed

=item Expiration time can use relative codes

=item Configurable history "count" with constants - silent
(0), default(10), debug(100), verbose(1000).

=item Add a hook of some type to log/store history

=head1 KNOWN ISSUES

=over

=item If last_error object falls out of the history calling
errors won't produce anything. Probably should fix this.

=back

=head1 PARTICIPATION

I welcome and accept patches in diff format. If you wish to
hack on this code, please fork the git repository found at:
L<http://github.com/tima/perl-amazon-agent/>. If you have
something to push back to my repository, just use the "pull
request" button on the github site.

=head1 LICENSE

The software is released under the Artistic License. The
terms of the Artistic License are described at
L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, Amazon::Agent is Copyright
2009, Timothy Appnel, tima@cpan.org. All rights reserved.

=cut

=end