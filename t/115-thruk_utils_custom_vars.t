use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

plan tests => 21;

use_ok('Thruk::Utils');

################################################################################
# _normalize_custom_vars
################################################################################

# custom_variable_names / custom_variable_values are merged into custom_variables
{
    my $data = {
        custom_variable_names  => ['CUSTOM_VARIABLE_1', 'OTHER'],
        custom_variable_values => ['CUSTOM_VARIABLE_1_VALUE', 'x'],
    };
    Thruk::Utils::_normalize_custom_vars($data, '');
    is(ref $data->{'custom_variables'}, 'HASH', 'names/values are normalized into a hash');
    is($data->{'custom_variables'}->{'CUSTOM_VARIABLE_1'}, 'CUSTOM_VARIABLE_1_VALUE', 'first custom variable value');
    is($data->{'custom_variables'}->{'OTHER'}, 'x', 'second custom variable value');
}

# custom_variables given as array of [name, value] pairs is converted to a hash
{
    my $data = {
        custom_variables => [ ['CUSTOM_VARIABLE_1', 'CUSTOM_VARIABLE_1_VALUE'], ['OTHER', 'x'] ],
    };
    Thruk::Utils::_normalize_custom_vars($data, '');
    is(ref $data->{'custom_variables'}, 'HASH', 'array of pairs is converted to a hash');
    is($data->{'custom_variables'}->{'OTHER'}, 'x', 'array of pairs value kept');
}

# an existing hash is authoritative and must not be re-merged from names/values
{
    my $data = {
        custom_variables       => { CUSTOM_VARIABLE_1 => 'CUSTOM_VARIABLE_1_CACHED_VALUE' },
        custom_variable_names  => ['CUSTOM_VARIABLE_1'],
        custom_variable_values => ['CUSTOM_VARIABLE_1_NEW_VALUE'],
    };
    Thruk::Utils::_normalize_custom_vars($data, '');
    is_deeply($data->{'custom_variables'}, { CUSTOM_VARIABLE_1 => 'CUSTOM_VARIABLE_1_CACHED_VALUE' }, 'existing hash wins over names/values');
}

# no custom variables at all results in an empty hash
{
    my $data = {};
    Thruk::Utils::_normalize_custom_vars($data, '');
    is(ref $data->{'custom_variables'}, 'HASH', 'empty hash created when no custom variables exist');
    is(scalar keys %{$data->{'custom_variables'}}, 0, 'created hash is empty');
}

# prefix is honored
{
    my $data = {
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    Thruk::Utils::_normalize_custom_vars($data, 'host_');
    is(ref $data->{'host_custom_variables'}, 'HASH', 'prefixed variables normalized into prefixed key');
    is($data->{'host_custom_variables'}->{'CUSTOM_VARIABLE_2'}, 'CUSTOM_VARIABLE_2_VALUE', 'prefixed custom variable value');
}

################################################################################
# get_custom_vars
################################################################################

# service custom variables, add_host disabled
{
    my $data = {
        custom_variable_names       => ['CUSTOM_VARIABLE_1'],
        custom_variable_values      => ['CUSTOM_VARIABLE_1_VALUE'],
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    # add_host is the last argument, 0 here
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, '', 0);
    is($vars->{'CUSTOM_VARIABLE_1'}, 'CUSTOM_VARIABLE_1_VALUE', 'service custom variable returned');
    ok(!exists $vars->{'HOSTCUSTOM_VARIABLE_2'}, 'host custom variable skipped without add_host');
}

# service and host custom variables, add_host enabled
{
    my $data = {
        custom_variable_names       => ['CUSTOM_VARIABLE_1'],
        custom_variable_values      => ['CUSTOM_VARIABLE_1_VALUE'],
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, '', 1);
    is($vars->{'CUSTOM_VARIABLE_1'}, 'CUSTOM_VARIABLE_1_VALUE', 'service custom variable returned with add_host');
    is($vars->{'HOSTCUSTOM_VARIABLE_2'}, 'CUSTOM_VARIABLE_2_VALUE', 'host custom variable returned with add_host');
    ok(!exists $data->{'_hostcustom_variables'}, 'no bogus _hostcustom_variables key created');
}

# only host custom variables
{
    my $data = {
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, '', 1);
    is_deeply($vars, { HOSTCUSTOM_VARIABLE_2 => 'CUSTOM_VARIABLE_2_VALUE' }, 'host custom variables only');
}

# add_host enabled but no host custom variables
{
    my $data = {
        custom_variable_names  => ['CUSTOM_VARIABLE_1'],
        custom_variable_values => ['CUSTOM_VARIABLE_1_VALUE'],
    };
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, '', 1);
    is_deeply($vars, { CUSTOM_VARIABLE_1 => 'CUSTOM_VARIABLE_1_VALUE' }, 'no host custom variables adds nothing');
}

# prefixed lookup
{
    my $data = {
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, 'host_', 0);
    is($vars->{'CUSTOM_VARIABLE_2'}, 'CUSTOM_VARIABLE_2_VALUE', 'prefixed get_custom_vars returns prefixed variables');
}

# an existing custom_variables hash is authoritative
{
    my $data = {
        custom_variables       => { CUSTOM_VARIABLE_1 => 'cached' },
        custom_variable_names  => ['CUSTOM_VARIABLE_1'],
        custom_variable_values => ['from_names'],
    };
    my $vars = Thruk::Utils::get_custom_vars(undef, $data, '', 0);
    is($vars->{'CUSTOM_VARIABLE_1'}, 'cached', 'cached custom_variables hash is authoritative');
}

# repeated calls return the same result
{
    my $data = {
        custom_variable_names       => ['CUSTOM_VARIABLE_1'],
        custom_variable_values      => ['CUSTOM_VARIABLE_1_VALUE'],
        host_custom_variable_names  => ['CUSTOM_VARIABLE_2'],
        host_custom_variable_values => ['CUSTOM_VARIABLE_2_VALUE'],
    };
    my $first  = Thruk::Utils::get_custom_vars(undef, $data, '', 1);
    my $second = Thruk::Utils::get_custom_vars(undef, $data, '', 1);
    is_deeply($second, $first, 'repeated get_custom_vars calls return the same result');
}
