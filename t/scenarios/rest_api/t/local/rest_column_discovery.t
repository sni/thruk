use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 1;

subtest 'Custom-variable column discovery' => sub {
    # testuser2 has all-host/service access through testgroup2, without admin rights.
    for my $path ('/hosts', '/hosts/localhost', '/services', '/hosts/localhost/services', '/services/localhost/Ping',
                  '/thruk/bp/1/objects', '/thruk/bp/1/objects/recursive') {
        my $data = _metadata($path, 'testuser2', 1);
        is_deeply($data->{'data'}, [], $path.' metadata response contains no rows');
        my $columns = { map { $_->{'name'} => $_ } @{$data->{'meta'}->{'columns'}} };
        ok(exists $columns->{'_TEST'}, $path.' exposed variable discovered');
        ok(!exists $columns->{'_PRIVATE'}, $path.' private variable hidden');
        if($path =~ m/services|\/objects/mx) {
            ok(exists $columns->{'description'}, $path.' service columns included');
            ok(exists $columns->{'_HOSTTEST'}, $path.' host variable discovered');
            ok(!exists $columns->{'_HOSTPRIVATE'}, $path.' private host variable hidden');
        }
    }

    my $admin_data = _metadata('/services', 'omdadmin');
    my $admin_columns = { map { $_->{'name'} => $_ } @{$admin_data->{'meta'}->{'columns'}} };
    ok(exists $admin_columns->{'_PRIVATE'}, 'admin discovers all service variables without Grafana header');
    ok(exists $admin_columns->{'_HOSTPRIVATE'}, 'admin discovers all host variables without Grafana header');

    my $contact_data = _metadata('/contacts', 'omdadmin');
    ok(!(grep { $_->{'name'} eq '_TEST' } @{$contact_data->{'meta'}->{'columns'}}), 'contact metadata excludes host and service variables');

    my $data = _metadata('/hosts?columns=name', 'omdadmin');
    is_deeply([map { $_->{'name'} } @{$data->{'meta'}->{'columns'}}], ['name'], 'explicit column selection preserved');
    done_testing();
};

################################################################################
sub _metadata {
    my($path, $user, $grafana) = @_;
    my $test = {
        cmd => '/usr/bin/env curl -fsS -H "X-Thruk-Auth-Key: testkey" -H "X-Thruk-Auth-User: '.$user.'"'
              .' -H "X-Thruk-Output-Metadata-Only: 1"'
              .($grafana ? ' -H "x-thruk-columns: true"' : '')
              .' "http://localhost/demo/thruk/r'.$path.'"',
    };
    TestUtils::test_command($test) or BAIL_OUT('metadata request failed');
    return decode_json($test->{'stdout'});
}
