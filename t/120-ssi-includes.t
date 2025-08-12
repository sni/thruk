use warnings;
use strict;
use Test::More;

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};

my $filter = $ARGV[0];

# find pages with missing ssi includes
my $cmd = "grep '::ssi_include' -c lib/Thruk/Controller/*.pm plugins/plugins-available/*/lib/Thruk/Controller/*.pm";

open(my $ph, '-|', $cmd.' 2>&1') or die('cmd '.$cmd.' failed: '.$!);
ok($ph, 'cmd started');
while(<$ph>) {
    my $line = $_;
    chomp($line);

    my($file, $nr) = split(/:/mx, $line, 2);

    next if $nr > 0;

    next if $file =~ m/(
       \/
       |error
       |panorama
       |pansnaps
       |proxy
       |remote
       |rest_v1
       |restricted
       |Root
       |test
       |woshsh
    )\.pm$/mx;

    fail(sprintf("file %s is missing the ssi_include()", $file));
}
close($ph);


done_testing();
