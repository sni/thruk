use warnings;
use strict;
use Test::More;

BEGIN {
    plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 185;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}
use_ok 'Thruk::Controller::error';

$ENV{'TEST_ERROR'} = 1;
for(0..25) {
    my $nr = $_;
    my $test = {
        'url'     => '/thruk/cgi-bin/error.cgi?error='.$nr,
        'fail'    => 1,
        'unlike'  => [],
    };
    TestUtils::test_page(%{$test});
}

my $url = '/thruk/cgi-bin/error.cgi?error=A%20%26%20B%20%3C%20C';
like(request($url)->content, qr{<h1\b[^>]*>unknown error: A &amp; B &lt; C</h1>}, 'unknown error is escaped in HTML');
is(Cpanel::JSON::XS::decode_json(request($url.'&json=1')->content)->{'message'}, 'unknown error: A & B < C', 'unknown error stays plain text in JSON');

delete $ENV{'TEST_ERROR'};
