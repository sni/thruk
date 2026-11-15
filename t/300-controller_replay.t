use warnings;
use strict;
use Cpanel::JSON::XS ();
use HTML::Entities qw/decode_entities/;
use Test::More;
use URI::Escape qw/uri_escape_utf8/;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' && !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    use lib 't';
    require TestUtils;
    import TestUtils;
}

for my $params ('', '&host=unknownhost', '&start=-1h&end=now', '&start=100&end=100', '&q=invalid%20query%20%3D') {
    TestUtils::test_page(
        url => '/thruk/cgi-bin/status.cgi?style=replay'.$params,
        like => 'Status Replay',
        fail_message_ok => $params =~ m/invalid/mx ? 1 : 0,
    );
}
my($host, $service) = TestUtils::get_test_service();
my $json = Cpanel::JSON::XS->new;
for my $filter (
    '&dfl_s0_type=host&dfl_s0_op=%3D&dfl_s0_value='.uri_escape_utf8($host),
    '&q='.uri_escape_utf8('host_name = "'.$host.'" and description = "'.$service.'"'),
) {
    my $page = TestUtils::test_page(
        url => '/thruk/cgi-bin/status.cgi?style=replay&start=-1h&end=now'.$filter,
        like => [qr/mainTableHeader.*?Display Filter/s, qr/id="replay-time"\s+class="text-default textTH tracking-wide"/, 'Attempt', 'table-layout:fixed', 'jquery.flot.selection.js', 'id="replay-zoom-reset"', 'role="slider"', 'id="replay-event"', 'id="replay-event-prev"', 'id="replay-event-next"', 'id="replay-keyboard-mode"', 'id="replay-help-button"', 'role="separator"', 'fa-grip-lines', qr/mainTableFooter[^<]*>.*?id="replay-object-summary"/s, qr/<script[^>]+status-replay\.js"\s+defer/],
        unlike => ['id="replay-zoom-in"', 'id="replay-zoom-out"', '<h1[^>]*>Status Replay</h1>', 'id="replay-prev-event"', 'id="replay-next-event"', 'id="replay-prev-time"', 'id="replay-next-time"', 'id="replay-time-step"'],
    );
    my($data_replay) = $page->{'content'} =~ m/data-replay="([^"]+)"/mx;
    like($page->{'content'}, qr/id="replay-play".*?for="replay-speed".*?id="replay-speed".*?id="replay-keyboard-mode"/s, 'speed selector follows play button');
    like($page->{'content'}, qr/id="replay-summary"\s+class="[^"]*whitespace-nowrap"\s+role="status"/, 'event counter is a status element');
    my $data = $json->decode(decode_entities($data_replay));
    ok(@{$data->{'objects'}} > 0, 'display filter selects objects');
    is_deeply([grep { $_->{'host'} ne $host } @{$data->{'objects'}}], [], 'host filter applies to all replay objects');
    if($filter =~ m/^&q=/mx) {
        is_deeply([grep { !$_->{'hidden'} && $_->{'service'} ne $service } @{$data->{'objects'}}], [], 'lexical service filter applies to replay');
    }
}
for my $params ('type=1&host='.uri_escape_utf8($host),
                'type=2&host='.uri_escape_utf8($host).'&service='.uri_escape_utf8($service)) {
    TestUtils::test_page(url => '/thruk/cgi-bin/extinfo.cgi?'.$params, like => 'style=replay');
}
my $filtered_page = TestUtils::test_page(
    url => '/thruk/cgi-bin/status.cgi?style=replay&start=-1h&end=now&pattern=SERVICE%20ALERT&exclude_pattern=SOFT',
    like => ['Log Filter', 'name="pattern"', 'name="exclude_pattern"', 'value="SERVICE ALERT"', 'value="SOFT"'],
);
for my $params ('pattern=%5B', 'exclude_pattern=%5B', 'pattern=%23%28') {
    TestUtils::test_page(
        url => '/thruk/cgi-bin/status.cgi?style=replay&'.$params,
        like => 'Please correct the log filter pattern',
        fail_message_ok => 1,
    );
}
done_testing();
