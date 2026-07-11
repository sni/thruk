use warnings;
use strict;
use Test::More tests => 5;

################################################################################
# check if we have all subs in Provider/Base.pm
my @files = glob("lib/Thruk/Backend/Provider/*.pm");
my @bsubs = get_subs("lib/Thruk/Backend/Provider/Base.pm");
my @dbcommon_subs = get_subs("lib/Thruk/Backend/Provider/DBcommon.pm");
for my $file ( @files ) {
    next if $file =~ m/\/Base\.pm$/;
    next if $file =~ m/\/DBcommon\.pm$/;  # abstract parent, not a standalone provider
    my @fsubs = get_subs($file);
    # for DB-backed providers, merge in inherited subs from DBcommon.pm
    if($file =~ m/\/(?:Mysql|Postgresql)\.pm$/) {
        my %seen;
        @fsubs = grep { !$seen{$_}++ } sort(@fsubs, @dbcommon_subs);
    }
    is_deeply(\@fsubs, \@bsubs, "Base.pm contains all subs from $file");
}

################################################################################
# get_subs
sub get_subs {
    my $file = shift;
    my @subs;
    open(my $fh, '<', $file) or die("cannot open file $file: $!");
    while(<$fh>) {
        if($_ =~ /^\s*sub\s+([\w\d_\_]+)/mx) {
            my $func = $1;
            next if $func =~ m/^_/mx; # skip private subs
            next if $func eq 'propagate_session_file';       # not required
            next if $func eq 'rpc';                          # only available on http
            next if $func eq 'request';                      # only available on http
            next if $func eq 'rest_request';                 # only available on http
            next if $func eq 'check_global_lock';            # only available on mysql
            next if $func eq 'can_use_logcache';             # use from Base.pm
            next if $func eq 'get_logs_start_end_no_filter'; # use from Base.pm
            next if $func eq 'get_existing_caches';          # only available on mysql
            next if $func eq 'cache_version';                # DB-internal accessor, not provider API
            next if $func eq 'db_types';                     # DB-internal accessor, not provider API
            next if $func eq 'db_classes';                   # DB-internal accessor, not provider API
            next if $func eq 'tables';                       # DB-internal accessor, not provider API
            push @subs, $func;
        }
    }
    close($fh);
    return sort @subs;
}
