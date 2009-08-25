package Amazon::Request;
use strict;
use warnings;

use base 'HTTP::Request Class::ErrorHandler';

use Amazon::Util qw( amazon_timestamp amazon_signature);

sub new {
    my $class         = shift;
    my $params        = shift || {};    
    my $self          = bless {}, $class;
    return $self->init(%$params);
}

sub init {
    my $self = shift;
    my %sign_hash = @_;
    my $url           = delete $params->{'endpoint'};
    my $secret        = delete $params->{'secret_key'};  
    delete $sign_hash{'Signature'}; # safety
    unless ($sign_hash{'Timestamp'} || $sign_hash{'Expires'}) {
        $sign_hash{'Timestamp'} = amazon_timestamp();
    }
    $sign_hash{'Signature'} = amazon_signature($sign_hash);
    
}

1;

__END__

generate_query ???? internal method the validates 
    #   Action
    #   AWSAccessKeyID
    #   Version
    #   Signature (this is appending right before the request)
    #   SignatureVersion
    #   Timestamp
    #   Expires (Not sure about SimpleDB)
    # should this validation/defaults be in request
    # version, signature version check. required.
    # access key and secret key or bezos object
    my $secret_access_key  = delete $sign_hash{AWSSecretKey}; 
    # or expires (grab from cache manager)
    $sign_hash{Timestamp}  = amazon_timestamp(); # deal with expires
