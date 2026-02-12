package Thruk::Agents::SNClient::Checks::DriveIO;

use warnings;
use strict;

use Thruk::Agents::SNClient ();
use Thruk::Utils::Agents ();

=head1 NAME

Thruk::Agents::SNClient::Checks::DriveIO - returns drive io related checks for snclient

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

    return unless $inventory->{'drive_io'};

    my $disabled_config = Thruk::Agents::SNClient::get_disabled_config($c, 'drive_io');

    for my $drive (@{$inventory->{'drive_io'}}) {
        my $prefix = "drive io";
        my $def_opts = Thruk::Agents::SNClient::default_opt($c, 'drive_io') // '';
        push @{$checks}, {
            'id'       => 'drive_io.'.Thruk::Utils::Agents::to_id($drive->{'drive'}),
            'name'     => $prefix.' '.$drive->{'drive'},
            'check'    => 'check_drive_io',
            'args'     => [ "drive='".$drive->{'drive'}."'", $def_opts ],
            'parent'   => 'agent version',
            'info'     => $drive,
            'disabled' => !$drive->{'drive'} ? 'drive has no name' : Thruk::Utils::Agents::check_disable($drive, $disabled_config, ['drive_io', $prefix]),
        };
    }

    return $checks;
}

##########################################################

1;
