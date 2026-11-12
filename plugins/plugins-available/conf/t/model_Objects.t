use warnings;
use strict;
use Test::More;

use lib 'plugins/plugins-available/conf/lib/';

use Monitoring::Config::Object ();

plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

use_ok 'Monitoring::Config::Multi';
use_ok 'Monitoring::Config';

Monitoring::Config->new({});
my $host = Monitoring::Config::Object->new(
    type     => 'host',
    coretype => 'nagios',
    conf     => { host_name => 'localhost', use => ['generic-host'] },
);
my $computed = {
    host_name => 'localhost',
    address   => '127.0.0.1',
    alias     => 'Local <host> &lt;test&gt;',
    contacts  => ['admin', 'operator'],
};
my $text = $host->as_text($computed);
like($text, qr/^define host \{\n/, 'exports a Naemon object definition');
like($text, qr/^\s+address\s+127\.0\.0\.1$/m, 'exports computed attributes');
like($text, qr/^\s+contacts\s+admin,operator$/m, 'exports lists as comma-separated values');
like($text, qr/^\s+alias\s+Local <host> &lt;test&gt;$/m, 'preserves special characters');
unlike($text, qr/^\s+use\s/m, 'computed export does not reference templates');
is_deeply($host->{'conf'}, { host_name => 'localhost', use => ['generic-host'] }, 'export leaves the original config unchanged');
like(scalar $host->as_text(), qr/^\s+use\s+generic-host$/m, 'normal export still includes templates');

done_testing();
