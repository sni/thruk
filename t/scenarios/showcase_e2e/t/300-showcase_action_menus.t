use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;
use URI::Escape qw/uri_escape/;

BEGIN {
    plan skip_all => 'external scenario test only' unless defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    use lib('t');
    require TestUtils;
    import TestUtils;
}

TestUtils::set_test_user_token();

my($host,$service) = ('localhost', 'Sticky Logfile');

# the json based action menu must be rendered on the demo service details page
TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/extinfo.cgi?type=2&host='.uri_escape($host).'&service='.uri_escape($service),
    'like' => ['server://showcase_restart', 'server://showcase_fail', 'showcase_note_input'],
);

# the javascript based action menu must be rendered on the host details page
TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/extinfo.cgi?type=1&host='.uri_escape($host),
    'like' => ['showcase_js_menu', 'showcase_js_menu_services'],
);

# a failing server action must report an error
my $r = TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/status.cgi?serveraction=1&json=1',
    'post' => { 'link' => 'server://showcase_fail', 'host' => $host, 'service' => $service },
);
my $data = decode_json($r->{'content'});
isnt($data->{'rc'}, 0, 'failing server action returns error');
like($data->{'msg'}, qr/simulated\s+failure/mx, 'failing server action message is displayed');

# the form based server action must succeed
$r = TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/status.cgi?serveraction=1&json=1',
    'post' => { 'link' => 'server://showcase_note/demo note', 'host' => $host, 'service' => $service },
);
$data = decode_json($r->{'content'});
is($data->{'rc'}, 0, 'note server action succeeded');
like($data->{'msg'}, qr/saved/mx, 'note server action message is displayed');

# the sticky logfile check create action must succeed
$r = TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/status.cgi?serveraction=1&json=1',
    'post' => { 'link' => 'server://showcase_create', 'host' => $host, 'service' => $service },
);
$data = decode_json($r->{'content'});
is($data->{'rc'}, 0, 'create server action succeeded');
like($data->{'msg'}, qr/created/mx, 'create server action message is displayed');

# the sticky logfile check reset action must succeed
$r = TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/status.cgi?serveraction=1&json=1',
    'post' => { 'link' => 'server://showcase_reset', 'host' => $host, 'service' => $service },
);
$data = decode_json($r->{'content'});
is($data->{'rc'}, 0, 'reset server action succeeded');
like($data->{'msg'}, qr/reset/mx, 'reset server action message is displayed');

# the restart service action must succeed
$r = TestUtils::test_page(
    'url'  => '/thruk/cgi-bin/status.cgi?serveraction=1&json=1',
    'post' => { 'link' => 'server://showcase_restart', 'host' => $host, 'service' => $service },
);
$data = decode_json($r->{'content'});
is($data->{'rc'}, 0, 'restart server action succeeded');

done_testing();
