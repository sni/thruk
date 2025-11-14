use warnings;
use strict;
use Cpanel::JSON::XS;
use HTML::Entities;
use Test::More;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 290;
}


BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

###############################################################################
# fetch backend ids
my $test = TestUtils::test_page(
    'url'    => '/thruk/cgi-bin/extinfo.cgi?type=0&view_mode=json',
    'like'   => [
                'peer_addr',
                'https://127.0.0.3:60443/demo/thruk/',
                'data_source_version',
            ],
);
my $procinfo = Cpanel::JSON::XS::decode_json($test->{'content'});
my $ids      = {map { $_->{'peer_name'} => $_->{'peer_key'} } values %{$procinfo}};
is(scalar keys %{$ids}, 12, 'got backend ids') || die("all backends required");
ok(defined $ids->{'tier1a'}, 'got backend ids II');

###############################################################################
# make sure all proxies work
{
    my $like = ["Service Status Details For All Host"];
    for my $backend (sort keys %{$ids}) {
        push @{$like}, '/thruk/cgi-bin/proxy.cgi/'.$ids->{$backend}.'/demo/';
    }
    my $test = TestUtils::test_page(
        'url'    => '/thruk/cgi-bin/status.cgi?host=all',
        'like'   => $like,
    );
    my @matches = $test->{'content'} =~ m|'/thruk/cgi-bin/proxy\.cgi/[^']+'|gmx;
    map { $_ =~ s|&amp;|&|gmx; $_ =~ s|'||gmx } @matches;
    @matches = grep(/(srv|service|)=Load/mx, @matches);
    @matches = grep(!/\/popup/mx, @matches);
    @matches = grep(!/-solo\//, @matches);
    is(scalar @matches, 11, 'got all proxy links');
    for my $url (sort @matches) {
        $url =~ s|'||gmx;
        next if $url =~ m/tier1d/mx; # does not work with basic auth
        next if $url =~ m/tier2d/mx; # does not work with basic auth
        TestUtils::test_page(
            'waitfor'        => '(grafanaBootData|grafana\-app|\/pnp4nagios\/index\.php\/image)',
            'url'            => $url,
            'skip_html_lint' => 1,
        );
        TestUtils::test_page(
            'url'            => $url,
            'unlike'         => ['/does not exist/'],
            'skip_html_lint' => 1,
        );
    }

    for my $backend (sort keys %{$ids}) {
        my $url = '/thruk/cgi-bin/proxy.cgi/'.$ids->{$backend}.'/demo/thruk/cgi-bin/tac.cgi';
        next if $backend eq 'tier1d'; # does not work with basic auth
        next if $backend eq 'tier2d'; # does not work with basic auth
        my $test = TestUtils::test_page(
            'url'    => $url,
            'like'   => ['Tactical Monitoring Overview', 'class="proxy_header"'],
        );
    }
}

###############################################################################
# test proxying grafana
{
    # viewing host tier3b on by proxy on tier2a
    TestUtils::test_page(
        'url'            => '/thruk/cgi-bin/proxy.cgi/c21da/demo/thruk/cgi-bin/status.cgi?style=detail&host=tier3b',
        'like'           => ['Service Status Details For Host', 'tier3b', 'Ping', 'Load'],
    );

    # view service Load on host tier3b on by proxy on tier2a
    TestUtils::test_page(
        'url'            => '/thruk/cgi-bin/proxy.cgi/c21da/demo/thruk/cgi-bin/extinfo.cgi?type=2&host=tier3b&service=Load&backend=e984d',
        'like'           => ['Load', 'total load average', 'Performance Graph'],
    );

    # request histou template for grafana
    TestUtils::test_page(
        'url'            => '/thruk/cgi-bin/proxy.cgi/c21da/demo/thruk/cgi-bin/proxy.cgi/e984d/demo/grafana/dashboard-solo/script/histou.js?host=tier3b&service=Load&theme=light&annotations=true&from=1763033126000&to=1763123126000&panelId=1',
        'like'           => ['<base href="/thruk/cgi-bin/proxy.cgi/c21da/demo/thruk/cgi-bin/proxy.cgi/e984d/demo/grafana/"'],
        'skip_html_lint' => 1,
        'skip_doctype'   => 1,
    );

    # request histou data for grafana
    TestUtils::test_page(
        'url'            => '/thruk/cgi-bin/proxy.cgi/c21da/demo/thruk/cgi-bin/proxy.cgi/e984d/demo/histou/index.php?host=tier3b&service=Load',
        'like'           => ['tier3b-Load', 'nagflux', 'rawQuery'],
        'skip_html_lint' => 1,
        'skip_doctype'   => 1,
    );
}

###############################################################################
