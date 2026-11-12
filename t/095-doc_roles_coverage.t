use warnings;
use strict;
use Test::More;

use Thruk::Base ();
use Thruk::Constants ();

# ensure that all config options are well documented
my $src = "docs/documentation/cgi-cfg.md";

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};

# Role documentation coverage does not need a running application or backend.
my $docs  = get_docs();
my $roles = $Thruk::Constants::possible_roles;
my $hash  = Thruk::Base::array2hash($roles);
for my $role (@{$roles}) {
    is($docs->{$role}, 1, "documentation entry for: $role");
}

for my $role (`grep ^authorized_for_ cgi.cfg`) {
    $role =~ s/=.*$//gmx;
    chomp($role);
    is($hash->{$role}, $role, "Thruk::Constants::possible_roles entry for: $role");
}

done_testing();


# Collect role headings without their presentation or anchor IDs.
sub get_docs {
    my $doc_roles;
    open(my $ph, '<', $src) or die("cannot open ".$src.": ".$!);
    while(<$ph>) {
        next unless /^#{2,3}\s+(.*)$/;
        my $text = $1;
        $text =~ s/\s+\{#[^}]+\}\s*\z//;
        $text =~ s/`//g;    # strip code ticks
        $text =~ s/\s+\z//;
        next unless $text =~ m/^authorized_for_/;
        $doc_roles->{$text} = 1;
    }
    close($ph);
    return $doc_roles;
}
