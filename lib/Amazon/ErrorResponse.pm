package Amazon::ErrorResponse;
use strict;
use warnings;

use base 'Amazon::Response';

sub code    { return $_[0]->{content}->{Response}{Errors}{Error}{Code} }
sub message { return $_[0]->{content}->{Response}{Errors}{Error}{Message} }

sub is_error   { return 1; }
sub is_success { return 0; }

1;

__END__

=begin pod

=head1 NAME

Amazon::ErrorResponse - a class representing a generic error
response from an Amazon Web Service service.

=head1 DESCRIPTION

B<This is code is in the early stages of development. Do not
consider it stable. Feedback and patches welcome.>

This is a subclass L<Amazon::Response>. See its manpage for
more.

=head1 METHODS

=item Amazon::ErrorResponse->new($args)

Constructor. It is recommended that you use
C<Amazon::Response->new($http_response)> instead of calling
this directly. It will determine if request ended in an
error from SimpleDB and will construct an object out of this
class.

=item $res->code

Returns the AWS error code (a string). See the service
documentation for a list of all error codes.

=item $res->message

Returns a human-readable message describing the error.

=head1 TO DO

=over

=item Fix code and message methods to look in multiple
locations. AWS error messages are communicated differently
depending on the service.

=back

=head1 SEE ALSO

L<Amazon::Agent>

=head1 AUTHOR & COPYRIGHT

Please see the L<Amazon::Agent> manpage for author,
copyright, and license information.

=cut

=end pod
