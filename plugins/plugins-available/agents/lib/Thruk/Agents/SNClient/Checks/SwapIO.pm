package Thruk::Agents::SNClient::Checks::SwapIO;

use warnings;
use strict;

use Thruk::Agents::SNClient ();

=head1 NAME

Thruk::Agents::SNClient::Checks::SwapIO - returns swap io related checks for snclient

=head1 METHODS

=cut

##########################################################

=head2 get_checks

    get_checks()

returns snclient checks

=cut
sub get_checks {
    my($self, $c, $inventory, $hostname, $password, $section) = @_;
    my $checks = [];

    return unless $inventory->{'swap_io'};
    return unless scalar @{$inventory->{'swap_io'}} > 0;

    my $disabled_config = Thruk::Agents::SNClient::get_disabled_config($c, 'swap_io');

    my $def_opts = Thruk::Agents::SNClient::default_opt($c, 'swap_io') // '';
    push @{$checks}, {
        'id'       => 'swap_io',
        'name'     => 'swap io',
        'check'    => 'check_swap_io',
        'args'     => [ $def_opts ],
        'parent'   => 'agent version',
        'info'     => $inventory->{'swap_io'}->[0],
    };

    return $checks;
}

##########################################################

1;
