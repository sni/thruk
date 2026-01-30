use warnings;
use strict;
use Test::More;

plan tests => 14;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}
use_ok 'Thruk::Utils::CLI::Rest';
use_ok 'Thruk::Controller::rest_v1';

_replace_output_tests();

################################################################################
sub _replace_output_tests {
    my $test_result = [{json => {
            "text1"  => "text1",
            "int1"   => 5,
            "float1" => 3.7,
            "total"  => 1,
        }}, {json =>  {
            "text2"  => "text2",
            "int2"   => 2,
            "float2" => 1.7,
            "total"  => 2,
        }}
    ];

    my $totals = Thruk::Utils::CLI::Rest::_calculate_data_totals($test_result, {});
    unshift(@{$test_result}, $totals);

    # simple text
    is(Thruk::Utils::CLI::Rest::_replace_output('text1', $test_result), "text1", "simple text 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('text2', $test_result), "text2", "simple text 2");

    # numbers
    is(Thruk::Utils::CLI::Rest::_replace_output('int1', $test_result), "5", "number 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('int1%d', $test_result), "5", "number 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('float1%0.2f', $test_result), "3.70", "number 3");

    # totals
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total', $test_result), "1", "total 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('2:total', $test_result), "2", "total 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('total', $test_result), "3", "total 3");

    # arithmetic
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total + 2:total', $test_result), "3", "arithmetic 1");
    is(Thruk::Utils::CLI::Rest::_replace_output('2:total - 1:total', $test_result), "1", "arithmetic 2");
    is(Thruk::Utils::CLI::Rest::_replace_output('1:total / 2:total%0.2f', $test_result), "0.50", "arithmetic 3");
    is(Thruk::Utils::CLI::Rest::_replace_output('total / 3', $test_result), "1", "arithmetic 4");
}
