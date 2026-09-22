use warnings;
use strict;
use Test::More;
use utf8;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

use_ok('Thruk::Utils::Filter');

###########################################################
# thruk_escape_html_tags
{
    my $service_render = {
        'custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'custom_variable_values' => ['0'],
    };
    my $service_escape = {
        'custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'custom_variable_values' => ['1'],
    };
    my $host_render = {
        'host_custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'host_custom_variable_values' => ['0'],
    };
    my $host_escape = {
        'host_custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'host_custom_variable_values' => ['1'],
    };

    is(Thruk::Utils::Filter::thruk_escape_html_tags($service_render, 1), 0, 'service override disables escaping');
    is(Thruk::Utils::Filter::thruk_escape_html_tags($service_escape, 0), 1, 'service override enables escaping');
    is(Thruk::Utils::Filter::thruk_escape_html_tags($host_render, 1), 0, 'host override disables escaping for a service');
    is(Thruk::Utils::Filter::thruk_escape_html_tags($host_escape, 0), 1, 'host override enables escaping for a service');
    is(Thruk::Utils::Filter::thruk_escape_html_tags({}, 1), 1, 'no override keeps default (escape)');
    is(Thruk::Utils::Filter::thruk_escape_html_tags({}, 0), 0, 'no override keeps default (render)');
    is(Thruk::Utils::Filter::thruk_escape_html_tags($service_render, undef), 0, 'service override works without explicit default');
    is(Thruk::Utils::Filter::thruk_escape_html_tags({}, undef), 1, 'escaping is the default');

    # a service value takes precedence over the host value
    my $both = {
        %{$service_escape},
        'host_custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'host_custom_variable_values' => ['0'],
    };
    is(Thruk::Utils::Filter::thruk_escape_html_tags($both, 0), 1, 'service value wins over host value');

    # only "0" disables escaping, everything else is treated as escape
    my $other = {
        'custom_variable_names'  => ['THRUK_ESCAPE_HTML_TAGS'],
        'custom_variable_values' => ['2'],
    };
    is(Thruk::Utils::Filter::thruk_escape_html_tags($other, 0), 1, 'any non-zero value escapes');
}

###########################################################
# plugin_output_as_html
{
    # naemon stores multiline output with escaped newlines
    my $html = '<style>\\n.x { color: red; }\\n</style>';
    is(Thruk::Utils::Filter::plugin_output_as_html($html),
       "<style>\n.x { color: red; }\n</style>",
       'escaped newlines are restored in html output');

    is(Thruk::Utils::Filter::plugin_output_as_html("line one\nline two"),
       'line one<br>line two',
       'plain text newlines become line breaks');

    is(Thruk::Utils::Filter::plugin_output_as_html('plain\\ntext'),
       'plain<br>text',
       'escaped newlines become line breaks in plain text');
}

done_testing();
