use warnings;
use strict;
use Test::More;

my @cmds = (
    './script/thruk bp all >/dev/null',
    './script/thruk_update_docs_rest.pl',
    'diff -Bbwu docs/documentation/rest_endpoints.md docs/documentation/rest_endpoints.md.tst',
    'diff -Bbwu docs/documentation/rest_commands.md docs/documentation/rest_commands.md.tst',
    'diff -Bbwu docs/documentation/commands.md docs/documentation/commands.md.tst',
    'diff -Bbwu lib/Thruk/Controller/Rest/V1/cmd.pm cmd.pm.tst',
);

# the markdown writer and parser are unit tested in t/095-doc_markdown.t
# without a backend, this integration test only needs the generator and a
# running backend to fetch the endpoint columns
BEGIN {
    plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan skip_all => 'local tests only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
}
plan tests => scalar(@cmds) * 3;

# the full generator needs a running backend to fetch endpoint columns
$ENV{'TEST_MODE'} = 1;
for my $cmd (@cmds) {
    open(my $ph, '-|', $cmd.' 2>&1') or die('cmd '.$cmd.' failed: '.$!);
    ok($ph, $cmd.' started');
    my $errors = "";
    while(<$ph>) {
        chomp(my $line = $_);
        next if $line =~ m/fetching\ keys\ for/mx;
        $errors .= $line."\n";
    }
    if($errors) {
        fail("cmd: ".$cmd." failed\n".$errors);
    } else {
        ok(1, "no errors");
    }
    close($ph);
    is($?, 0, "cmd exited with 0");
}

END {
    unlink('docs/documentation/rest_endpoints.md.tst');
    unlink('docs/documentation/rest_commands.md.tst');
    unlink('docs/documentation/commands.md.tst');
    unlink('cmd.pm.tst');
};
