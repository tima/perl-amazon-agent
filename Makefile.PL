use ExtUtils::MakeMaker;
use strict;

WriteMakefile(
    'NAME'	=> 'Amazon::Agent',
    'VERSION_FROM' => 'lib/Amazon/Agent.pm',
    'PREREQ_PM'    => {
        Class::ErrorHandler => 1.19,
        Data::Dumper     => 0,
		Digest::HMAC_SHA1 => 0,
        Exporter => 0,
        HTTP::Date => 0,
        HTTP::Request       => 0,
        HTTP::Response       => 0,
        LWP::UserAgent   => 0,
		MIME::Base64 => 0,
        XML::Simple 	 => 2.0,
    },
);
