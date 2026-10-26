#!/usr/bin/env perl

`touch Makefile`;

##################################
# patch our makefile
my $new_makefile = '';
open(my $fh, '<', 'Makefile') or die("cannot open Makefile");
my $found_make_create_distdir = 0;
while(<$fh>) {
    my $line = $_;
    if($line =~ m/^install\s*:/mx) {
        $line = <<EOT;
install :: local_install
EOT
    }
    # search the create_distdir part
    if($line =~ m/create_distdir\s*:/mx) {
        $found_make_create_distdir = 1;
    }
    if($found_make_create_distdir and $line =~ m/^\s*$/mx) {
        $found_make_create_distdir = 0;
        my $cp_option;
        $cp_option = "-d" if $^O eq 'linux';
        $cp_option = "-R" if $^O eq 'freebsd';
        $cp_option = "-R" if $^O eq 'darwin';
        $line = "\t".'for file in `cat MANIFEST`; do if [ -d $$file -a -L $$file ]; then $(CP) '.$cp_option.' $$file $(DISTVNAME)/`dirname $$file`/; fi; done'."\n".$line if defined $cp_option;
    }

    # set tests
    if($line =~ m/^TEST_FILES\s*=/mx) {
        $line = "TEST_FILES = t/*.t t/xt/*/*.t\n";
    }
    # keep the MakeMaker test target as test_legacy (builds blib, runs from blib)
    # and add a new test target that runs the suite from lib/ like quicktest
    # (with TEST_AUTHOR + HARNESS_TIMER), so 'make test' does not build blib
    # (pm_to_blib/manifypods)
    if($line =~ m/^test\s*::\s*\$\(TEST_TYPE\)\s*$/mx) {
        $line = "test_legacy :: \$(TEST_TYPE)\n";
        $new_makefile .= $line;
        $line = <$fh> or last; # old recipe line, now belongs to test_legacy
        $new_makefile .= $line;
        $line = "test:\n\tHARNESS_TIMER=1 TEST_AUTHOR=1 PERL_DL_NONLAZY=1 perl \"-MExtUtils::Command::MM\" \"-e\" \"test_harness(0, 'inc', 'lib/')\" \$(TEST_FILES)\n";
    }
    if($line =~ m/^\#\#\#\ THRUK/mx) {
        last;
    }
    $new_makefile .= $line;
}
close($fh);
open($fh, '>', 'Makefile') or die("cannot open Makefile for writing");
print $fh $new_makefile;
close($fh);
`cat script/Makefile.options >> Makefile` if -e 'script/Makefile.options';
`cat script/Makefile.thruk   >> Makefile`;
print "patched Makefile\n";

exit;
