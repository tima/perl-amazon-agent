package Amazon::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK =
  qw( amazon_timestamp amazon_signature is_amazon_error_response );

use HTTP::Date qw(time2isoz);
use Digest::HMAC_SHA1;
use MIME::Base64 qw(encode_base64);

sub amazon_timestamp {
    my $ts = time2isoz();
    chop $ts;
    $ts .= '.000Z';
    $ts =~ s{\s+}{T}g;
    return $ts;
}

sub amazon_signature {
    my ($self, $secret_access_key, %sign_hash) =
      @_;    # no reference to avoid corruption during signing.
    my $sign_this;
    for my $key (sort { lc($a) cmp lc($b) } keys %sign_hash) {
        $sign_this .= $key . $sign_hash{$key};
    }
    my $hashed = Digest::HMAC_SHA1->new($secret_access_key); # secret_access_key
    $hashed->add($sign_this);
    return encode_base64($hashed->digest, '');               # encoded signature
}

# Won't this die if a hash or like reference got pssed in? do we care?
sub is_amazon_error_response {
    my $r = shift;
    die 'A valid response object was not passed in.' unless ref $r;
    my $is_amazon =
        $r->isa('Amazon::Response') ? 1
      : $r->isa('HTTP::Response')   ? 0
      : die 'A valid response object was not passed in.';
    my $is_http_error = $is_amazon ? $r->http_response->is_error : $r->is_error;
    return 1 if $is_http_error;
    my $content = $is_amazon ? $r->http_response->content : $r->content;
    return 0 unless defined $content && $content ne '';
    my ($root) =
      keys %$content;    # there should only be one key, the XML root element.
    return 1 if exists $r->{'content'}->{$root}{Errors};
    return 1 if exists $r->{'content'}->{$root}{Error};
    return 0;
}

1;

__END__
