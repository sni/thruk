use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 16;

use_ok('Thruk::Utils');
use_ok('Thruk::Utils::Filter');
use_ok('Thruk::Views::ToolkitRenderer');

################################################################################

my $c        = TestUtils::get_c();
subtest 'host action and notes link HTML' => sub {
    my $url = q{/pnp4nagios/graph' class='tips' rel='/popup};
    my $template = '[% PROCESS _blocks.tt; PROCESS _status_host_attributes %]';
    my $host = { (map { $_ => 0 } qw/is_executing notifications_enabled check_type active_checks_enabled accept_passive_checks is_flapping acknowledged scheduled_downtime_depth icon_image_expanded/),
                 name => 'test', peer_key => 'test', action_url_expanded => $url, notes_url_expanded => $url };
    my $stash = { %{$c->stash}, host => $host, hostprefix => '', paneprefix => '', loop_index => 0, host_comment_count => 0, with_status => 0 };
    my $render = sub {
        my $html = '';
        Thruk::Views::ToolkitRenderer::render($c, \$template, $stash, \$html);
        return $html;
    };
    my $raw = "href='$url'";
    my $escaped = "href='".Thruk::Utils::Filter::escape_html($url)."'";
    my $html = $render->();
    is(() = $html =~ /\Q$escaped\E/g, 2, 'both links escaped by default');
    {
        local $c->config->{'escape_action_url_html'} = 0;
        like($render->(), qr/\Q$raw\E.*?Show Performance Chart.*?\Q$escaped\E/s, 'legacy PNP attributes only on action link');
    }
    {
        local $c->config->{'escape_notes_url_html'} = 0;
        like($render->(), qr/\Q$escaped\E.*?Show Performance Chart.*?\Q$raw\E/s, 'notes opt-out is independent');
    }
    for my $base ('/grafana/d/', '/histou.js?') {
        my $link = Thruk::Utils::get_action_url($c, 2, 1, $base."O'Brien", {});
        unlike($link, qr/O'Brien/, 'quotes escaped in graph and popup URLs');
        like($link, qr/' class='histou_tips' rel='/, 'generated popup attributes preserved');
    }
    my $base = '/mon/pnp4nagios/index.php';
    for my $service ('_HOST_', "Disk O'Brien+") {
        my $query = "?host=server&srv=$service";
        $host->{action_url_expanded} = "$base/graph$query' class='tips' rel='$base/popup$query";
        my $srv = $service eq '_HOST_' ? '_HOST_' : 'Disk%20O%27Brien%2B';
        my $attrs = "href='$base/graph?host=server&amp;srv=$srv&amp;theme=smoothness' class='tips' rel='$base/popup?host=server&amp;srv=$srv'";
        like($render->(), qr/\Q$attrs\E/, "stock PNP graph and SSI popup for $service");
    }
    $host->{action_url_expanded} .= "' title='other";
    unlike($render->(), qr/' class='tips' rel='/, 'extra backend attributes are not recognized as a stock popup');
};
$c->db->{'sections_depth'} = 0; # avoid some warnings
my $backends = ["abcd", "1234"];
my $hash     = Thruk::Utils::backends_list_to_hash($c, $backends);
my $expect   = { 'backends' => [ { 'abcd' => undef }, { '1234' => undef } ] };
is_deeply($hash, $expect, "got hash");

my $list     = Thruk::Utils::backends_hash_to_list($c, $hash);
is_deeply($list, $backends, "got same list of backends");

################################################################################

my $res;
$res = Thruk::Utils::Filter::duration(7, 6);
is($res, "7s", "duration is ok");

$res = Thruk::Utils::Filter::duration(107, 6);
is($res, "1m 47s", "duration is ok");

$res = Thruk::Utils::Filter::duration(712, 6);
is($res, "11m 52s", "duration is ok");

$res = Thruk::Utils::Filter::duration(-712, 6);
is($res, "-11m 52s", "duration is ok");

$res = Thruk::Utils::Filter::duration(1.212, 6);
is($res, "1.2s", "duration is ok");

$res = Thruk::Utils::Filter::duration(0.212, 6);
is($res, "212ms", "duration is ok");

$res = Thruk::Utils::Filter::duration(0.212, 4);
is($res, "0s", "duration is ok");

$res = Thruk::Utils::Filter::duration(-0.212, 4);
is($res, "0s", "duration is ok");

################################################################################
{
    # -or combined
    my $f = (Thruk::Utils::combine_filter(
        '-or', [
            {'description' => 'h1' },
            {'description' => 'h2' },
        ],
    ));
    is_deeply($f,  { '-or' => [ { 'description' => 'h1' }, { 'description' => 'h2' } ] }, "got expected filter");

    # strip unused filter from -or
    $f = (Thruk::Utils::combine_filter(
        '-or', [
            {'description' => '' }, # match nothing
            {'description' => 'test' },
        ],
    ));
    is_deeply($f, {'description' => 'test'}, "got expected filter");
};

################################################################################
