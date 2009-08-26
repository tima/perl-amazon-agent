package Amazon::Request;
use strict;
use warnings;

use base qw(HTTP::Request Class::ErrorHandler);

use Amazon::Util qw( amazon_timestamp amazon_signature);

sub new {
    my $class  = shift;
    my $params = shift || {};
    my $self   = bless {}, $class;
    return $self->init(%$params);
}

sub init {
    my $self      = shift;
    my %sign_hash = @_;
    my $url       = delete $sign_hash{'endpoint'};
    my $secret    = delete $sign_hash{'secret_key'};
    delete $sign_hash{'Signature'};    # safety
    unless ($sign_hash{'Timestamp'} || $sign_hash{'Expires'}) {
        $sign_hash{'Timestamp'} = amazon_timestamp();
    }
    $sign_hash{'Signature'} = amazon_signature(\%sign_hash);

# ????
}

1;

__END__

=begin pod

=head1 NAME

Amazon::Request - a class representing a generic request
to an Amazon Web Service service.

=head1 SYNOPSIS

=head1 DESCRIPTION

B<This is code is in the early stages of development. Do not
consider it stable. Feedback and patches welcome.>

This is a subclass L<HTTP::Request> and
L<Class::ErrorHandler>. See their manpage for more.

=head1 METHODS

=item Amazon::Request->new

=item $request->init

=head1 DEPENDENCIES

L<Module::Name>

=head1 SEE ALSO

L<Amazon::Agent>

=head1 AUTHOR & COPYRIGHT

Please see the L<Amazon::Agent> manpage for author,
copyright, and license information.

=cut

=end pod
