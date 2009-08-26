package Amazon::Response;
use strict;
use warnings;

use base 'Class::ErrorHandler';

use Amazon::Util qw( is_amazon_error_response );

sub new {
    my $class = shift;
    my $args  = shift || {};
    my $r     = $args->{http_response};
    return $class->error('No HTTP::Response object in http_response')
      unless ref $r && $r->isa('HTTP::Response');
    my $self = bless {}, $class;
    $self->{'http_response'} = $r;
    $self->{'http_status'}   = $r->code;
    $self->{'content'}       = $args->{content};
    $self->{'response_type'} = $args->{response_type};
    return $self;
}

sub type          { return $_[0]->{'response_type'} }
sub http_response { return $_[0]->{'http_response'} }
sub http_status   { return $_[0]->{'http_status'} }
sub content       { return $_[0]->{'content'} }

sub is_success { return !$_[0]->is_error; }

sub is_error {
    return $_[0]->{'is_error_response'}
      if defined $_[0]->{'is_error_response'};    # use cached value
    return $_[0]->{'is_error_response'} =
      is_amazon_error_response($_[0]->{'http_response'});
}

1;

__END__

=begin

=head1 NAME

Amazon::Response - a class representing a generic response
from an AWS service.

=head1 DESCRIPTION

B<This is code is in the early stages of development. Do not
consider it stable. Feedback and patches welcome.>

This is a generic response class for the results of any
request that does not require special handling. The class is
the base class to specialized response classes such as
L<Amazon::ErrorResponse>.

=head1 METHODS

=head2 Amazon::Response->new($args)

Constructs an appropriate AWS response object based on the
L<HTTP::Response> object provided. This method takes a
required HASHREF with two required keys:

=over

=item http_response

A L<HTTP::Response> object or subclass this response from a
request to the service.

=item account

A reference to the AWS account object this response is
associated to.

=back

=item $res->type

A string defining the response type that is determined by
the root element of the XML document that was returned.

=item $res->http_response

Returns the L<HTTP::Response> object used to construct this
response object.

=item $res->http_status

Returns the HTTP status code for the underlying response.

=item $res->content

The parsed XML contents of the response from L<XML::Simple>.

=item $res->is_success

Returns true if a successful response is returned, false if
not.

=item $res->is_error

Returns true if an error response was returned, false if
not.

=head1 SEE ALSO

L<Amazon::ErrorResponse>, L<Amazon::Agent>

=head1 AUTHOR & COPYRIGHT

Please see the L<Amazon::Agent> manpage for author,
copyright, and license information.

=cut

=end
