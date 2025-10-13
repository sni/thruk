use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 55;

$ENV{'THRUK_TEST_AUTH'}               = 'omdadmin:omd';
$ENV{'PLACK_TEST_EXTERNALSERVER_URI'} = 'http://127.0.0.1/demo';

###########################################################
# hostgroup details for a single hostgroup
TestUtils::test_page(
    url  => '/thruk/cgi-bin/status.cgi?style=hostdetail&grd_s0_type=hostgroup&grd_s0_val_pre=&grd_s0_op=%3D&grd_s0_value=hostgroup_04',
    like => ['Host Status Details For Host Group \'hostgroup_04\'', 'demo_host_003', '20</span> of 20 Items Displayed' ],
);
# hostgroup overview for a single hostgroup
TestUtils::test_page(
    url  => '/thruk/cgi-bin/status.cgi?style=hostoverview&dfl_s0_type=hostgroup&dfl_s0_val_pre=&dfl_s0_op=%3D&dfl_s0_value=hostgroup_04',
    like => ['Service Overview For Host Group \'hostgroup_04\'', 'hostgroup_alias_04', 'demo_host_003', '1</span> of 1 Items Displayed' ],
);
# hostgroup summary
TestUtils::test_page(
    url  => '/thruk/cgi-bin/status.cgi?style=hostsummary&ovr_s0_type=hostgroup&ovr_s0_val_pre=&ovr_s0_op=%3D&ovr_s0_value=hostgroup_04',
    like => ['Status Summary For Host Group \'hostgroup_04\'', 'hostgroup_alias_04', 'Hosts Summary', '1</span> of 1 Items Displayed' ],
);
# hostgroup grid for a single hostgroup
TestUtils::test_page(
    url  => '/thruk/cgi-bin/status.cgi?style=hostgrid&dfl_s0_type=hostgroup&dfl_s0_val_pre=&dfl_s0_op=%3D&dfl_s0_value=hostgroup_04',
    like => ['Service Grid', 'hostgroup_alias_04', 'demo_host_003', '1</span> of 1 Items Displayed' ],
);

###########################################################
