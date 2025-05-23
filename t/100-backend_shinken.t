use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

    use lib('t');
    require TestUtils;
    import TestUtils;
}

my($res, $c) = ctx_request('/thruk/main.html');
if($c->stash->{'enable_shinken_features'}) {
    plan tests => 47;
} else {
    plan skip_all => 'pure shinken backend required'
}

# get a problem host
my($host,$service) = TestUtils::get_test_service();

my $pages = [
    '/thruk/cgi-bin/status.cgi?hostgroup=all&style=hostdetail',
    '/thruk/cgi-bin/status.cgi?host=all',
    '/thruk/cgi-bin/cmd.cgi?cmd_typ=33&host='.$host,
    '/thruk/cgi-bin/cmd.cgi?cmd_typ=34&host='.$host.'&service='.$service,
];
for my $url (@{$pages}) {
    TestUtils::test_page(
        'url'     => $url,
        'like'    => 'Use expire time',
    );
}
