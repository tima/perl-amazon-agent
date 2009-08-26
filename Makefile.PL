use ExtUtils::MakeMaker;
use strict;

WriteMakefile(
    'NAME'             => 'Amazon::Agent',
    'VERSION_FROM'     => 'lib/Amazon/Agent.pm',
    'ABSTRACT_FROM'    => "lib/Amazon/Agent.pm",
    'MIN_PERL_VERSION' => '5.006',
    'LICENSE'          => 'perl',
    'AUTHOR'           => 'Timothy Appnel <tima@cpan.org>',
    'PREREQ_PM'        => {
        'Class::ErrorHandler' => 0,
        'Data::Dumper'        => 0,
        'Digest::HMAC_SHA1'   => 0,
        'Exporter'            => 0,
        'HTTP::Date'          => 0,
        'HTTP::Request'       => 0,
        'HTTP::Response'      => 0,
        'LWP::UserAgent'      => 0,
        'MIME::Base64'        => 0,
        'XML::Simple'         => 2.0,
    },
    'META_MERGE' => {
        'resources' => {
            'license'    => 'http://dev.perl.org/licenses/',
            'repository' => 'http://github.com/tima/perl-amazon-agent',
        },
    },
);

# bugtracker =>   'http://rt.cpan.org/NoAuthBugs.html?Dist=ExtUtils-MakeMaker',
