#!/usr/bin/env perl

use warnings;
use strict;
use File::Temp qw/tempdir/;
use Test::More;

use lib('plugins/plugins-available/conf/lib');

plan skip_all => 'internal test only' if defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};

use_ok('Monitoring::Config::File') or BAIL_OUT($@);

my $tmpdir = tempdir(CLEANUP => 1);
my $nr     = 0;

# a misconfigured boolean must be reported as a parse error, never as a perl
# warning, so any warning raised while parsing fails the test
my @warnings;
$SIG{__WARN__} = sub { push @warnings, $_[0] };

##########################################################
# writes the given object config and returns the parsed file
sub _parse {
    my($text) = @_;
    my $path  = $tmpdir.'/test'.($nr++).'.cfg';
    open(my $fh, '>', $path) or die("cannot write $path: $!");
    print $fh $text;
    close($fh);
    @warnings = ();
    my $file = Monitoring::Config::File->new($path, [], 'nagios');
    $file->update_objects();
    return($file);
}

##########################################################
# returns the parsed file for a host object with the given register line
sub _parse_register {
    my($value) = @_;
    my $line = defined $value ? 'register       '.$value : 'register';
    return(_parse("define host {\n  host_name      testhost\n  ".$line."\n}\n"));
}

##########################################################
# only 0 and 1 are valid, everything else is reported and treated as a
# regular object
my $cases = [
    # register value  errors  is_template  description
    [ '0',            0,      1,           'valid template marker' ],
    [ '1',            0,      0,           'valid registered object' ],
    [ '0v',           1,      0,           'trailing character typo' ],
    [ 'foo',          1,      0,           'non numeric value' ],
    [ 'yes',          1,      0,           'boolean like word' ],
    [ '00',           1,      0,           'numerically zero but written differently' ],
    [ '0.0',          1,      0,           'numerically zero as float' ],
    [ '-0',           1,      0,           'numerically zero with sign' ],
    [ undef,          1,      0,           'attribute without any value' ],
];

for my $case (@{$cases}) {
    my($value, $exp_errors, $exp_template, $descr) = @{$case};
    my $file = _parse_register($value);
    is(scalar @{$file->{'parse_errors'}}, $exp_errors, $descr.': number of parse errors')
        or diag(join("\n", @{$file->{'parse_errors'}}));
    my $obj = $file->{'objects'}->[0];
    isa_ok($obj, 'Monitoring::Config::Object::Host', $descr.': object parsed');
    is($obj->is_template(), $exp_template, $descr.': is_template');
    # checked last on purpose, so it covers evaluating the value as well as
    # parsing it. a numeric comparison anywhere would show up here.
    is(scalar @warnings, 0, $descr.': raised no perl warnings')
        or diag(join("\n", @warnings));
}

##########################################################
# the error names the attribute and the offending value
my $file = _parse_register('0v');
like($file->{'parse_errors'}->[0], qr/invalid\ boolean\ value\ for\ register/mx, 'error names the attribute');
like($file->{'parse_errors'}->[0], qr/'0v'/mx,                                   'error contains the offending value');

##########################################################
# the invalid value is reported, not repaired: it must survive parsing
# untouched so it stays in the file on disk
my $obj = $file->{'objects'}->[0];
ok(exists $obj->{'conf'}->{'register'}, 'invalid attribute has not been removed');
is($obj->{'conf'}->{'register'}, '0v',  'invalid value is unchanged');

##########################################################
# every place which inspects register must agree, an invalid value is not a
# template anywhere
is($obj->is_template(), 0,             'invalid value is not a template');
is($obj->get_primary_name(), 'testhost', 'invalid value keeps its primary name');
is($obj->get_template_name(), undef,   'invalid value has no template name');
is(scalar @warnings, 0, 'inspecting an invalid value raises no perl warnings')
    or diag(join("\n", @warnings));

##########################################################
# validation is not specific to register
$file = _parse("define host {\n  host_name      testhost\n  active_checks_enabled  maybe\n}\n");
is(scalar @{$file->{'parse_errors'}}, 1, 'other boolean attributes are validated too')
    or diag(join("\n", @{$file->{'parse_errors'}}));
is(scalar @warnings, 0, 'other boolean attributes raise no perl warnings')
    or diag(join("\n", @warnings));
like($file->{'parse_errors'}->[0], qr/invalid\ boolean\ value\ for\ active_checks_enabled/mx, 'error names the attribute');

##########################################################
# disabled objects stay exempt from parse errors
$file = _parse("#define host {\n#  host_name      testhost\n#  register       0v\n#}\n");
is(scalar @{$file->{'parse_errors'}}, 0, 'disabled objects report no parse errors')
    or diag(join("\n", @{$file->{'parse_errors'}}));
is(scalar @warnings, 0, 'disabled objects raise no perl warnings')
    or diag(join("\n", @warnings));

done_testing();
