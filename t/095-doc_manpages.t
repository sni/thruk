use warnings;
use strict;
use Cwd qw/abs_path getcwd/;
use File::Path qw/make_path/;
use File::Temp qw/tempdir/;
use Test::More;

my $updater = abs_path('script/thruk_update_docs.sh');
my $root = tempdir(CLEANUP => 1);
make_path("$root/bin", "$root/docs/manpages", "$root/script");

sub write_file {
    my($file, $text) = @_;
    open(my $fh, '>', "$root/$file") or die "$file: $!";
    print {$fh} $text;
    close($fh) or die "$file: $!";
}

sub read_file {
    my($file) = @_;
    open(my $fh, '<', "$root/$file") or die "$file: $!";
    local $/;
    return <$fh>;
}

write_file('bin/pandoc', <<'SH');
#!/bin/sh
if [ "$PANDOC_FAIL" = 1 ]; then exit 1; fi
while [ "$1" != -o ]; do shift; done
printf 'converted markdown\n' > "$2"
SH
chmod 0755, "$root/bin/pandoc";
write_file('bin/pod2man', <<'SH');
#!/bin/sh
printf 'converted POD\n'
if [ "$POD_FAIL" = 1 ]; then exit 1; fi
SH
chmod 0755, "$root/bin/pod2man";
write_file('docs/manpages/thruk8.md', "# Manual\n");
write_file('docs/manpages/thruk.8', "original manual\n");
utime 1, 1, "$root/docs/manpages/thruk.8";
for my $name (qw/thruk naglint nagexp nagimp/) {
    write_file("script/$name", "# script\n");
    write_file("docs/manpages/$name.3", "original POD manual\n");
    utime 1, 1, "$root/script/$name";
    utime 2, 2, "$root/docs/manpages/$name.3";
}

my $cwd = getcwd();
chdir $root or die $!;
{
    local $ENV{PATH} = "$root/bin:$ENV{PATH}";
    local $ENV{PANDOC_FAIL} = 1;
    isnt(system('bash', $updater), 0, 'converter failure stops generation');
    is(read_file('docs/manpages/thruk.8'), "original manual\n", 'failure preserves the existing man page');
    is_deeply([glob('docs/manpages/thruk.8.*')], [], 'failure removes the temporary file');

    $ENV{PANDOC_FAIL} = 0;
    is(system('bash', $updater), 0, 'Markdown man page generation succeeds');
    is(read_file('docs/manpages/thruk.8'), "converted markdown\n", 'successful output replaces the old man page');
    is_deeply([glob('docs/manpages/thruk.8.*')], [], 'success leaves no temporary file');

    utime time() + 1, time() + 1, "$root/script/thruk";
    local $ENV{POD_FAIL} = 1;
    isnt(system('bash', $updater), 0, 'POD converter failure stops generation');
    is(read_file('docs/manpages/thruk.3'), "original POD manual\n", 'POD failure preserves the existing man page');
    is_deeply([glob('docs/manpages/thruk.3.*')], [], 'POD failure removes partial output');

    $ENV{POD_FAIL} = 0;
    is(system('bash', $updater), 0, 'POD generation succeeds');
    is(read_file('docs/manpages/thruk.3'), "converted POD\n", 'successful POD output replaces the old manual');
}
chdir $cwd or die $!;
done_testing();
