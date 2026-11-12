use warnings;
use strict;
use Cpanel::JSON::XS ();
use Test::More;

use lib('lib');

use Thruk::Utils::DocsMarkdown qw/md_escape_cell md_unescape md_heading md_slug md_description _parse_attribute_docs _parse_additional_attributes/;

# no explicit count, done_testing() below counts the assertions

# --- cell escape/unescape keeps data --------------------------------------
{
    my $cell = md_escape_cell('a|b');
    is(md_unescape($cell), 'a|b', 'escape keeps the pipe, no data lost');
    is($cell, 'a\\|b', 'table pipes are escaped');

    my $cell2 = md_escape_cell('plain');
    is($cell2, 'plain', 'plain cell is left as is');

    # a pipe inside an inline code span round trips
    my($cell3) = md_escape_cell('a`|`b');
    is(md_unescape($cell3), 'a`|`b', 'pipe in code span round trips');
}

# --- slug / heading --------------------------------------------------------
{
    is(md_slug('POST /hosts/<name>/cmd/note'), 'post-hostsnamecmdnote',
        'slug matches the old asciidoc post- anchor');
    is(md_slug('/hosts'), 'hosts', 'simple path slug');

    my $h = md_heading('POST', '/hosts/<name>/cmd/note');
    like($h, qr/^### `POST \/hosts\/<name>\/cmd\/note` \{#post-hostsnamecmdnote\}$/,
        'endpoint heading carries the explicit post- id');
    # the emitted heading id and the generated cross link use one code path:
    # slug the backtick-wrapped heading text, it must equal the post- anchor
    my($htext) = $h =~ m%^### `(.+?)`%;
    is(md_slug($htext), 'post-hostsnamecmdnote', 'heading text slugs to the cross link target');
}

# --- parser: real ### markdown document -----------------------------------
{
    is(md_description('alias for /contacts?name=<name>'), 'alias for `/contacts?name=<name>`',
        'alias URLs use code spans rather than HTML escaping');
    is(md_description('alias for /logs?type[~]=^(HOST|SERVICE) ALERT&host_name=<name>'),
        'alias for `/logs?type[~]=^(HOST|SERVICE) ALERT&host_name=<name>`',
        'code spans preserve spaces, pipes and query parameters');
    is(md_description('supports wildcards for: <host> and <service>'),
        'supports wildcards for: `<host>` and `<service>`', 'wildcard placeholders use code spans');
    my $description = "alias for `/contacts?name=<name>`\nsupports wildcards for: `<name>`\n[Examples](rest_examples.md)\n";
    is(md_description($description), $description, 'formatting preserves existing code spans and Markdown links');
}

my $doc = <<'EOT';
# REST API

intro text

### `GET /hosts` {#get-hosts}

lists livestatus hosts.

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| host_name | string |          | host name
| plugin_output | string |          | last plugin output during outage
| `panlet_<nr>` | string | | dashboard panlet |

```
| host_name | string | this row is inside a fence and must be ignored |
### `GET /fake` {#get-fake}
```

### `POST /hosts/<name>/cmd/note` {#post-hostsnamecmdnote}

Add host note to core log.

EOT
my $a = _parse_attribute_docs($doc);
is_deeply($a->{'/hosts'}->{GET}{'host_name'}, ['string', '', 'host name'],
    'parses the attribute row under a ### heading');
is_deeply($a->{'/hosts'}->{GET}{'plugin_output'}, ['string', '', 'last plugin output during outage'],
    'parses the second attribute row');
ok(!exists $a->{'/fake'}, 'a heading inside a code fence is not an endpoint');
is($a->{'/hosts'}->{GET}{'host_name'}[2], 'host name',
    'a table row inside a code fence is not parsed');
ok(!exists $a->{'/hosts/<name>/cmd/note'}, 'no table is emitted for the note endpoint');
is_deeply($a->{'/hosts'}->{GET}{'panlet_<nr>'}, ['string', '', 'dashboard panlet'],
    'code-formatted generated attribute names preserve literal angle brackets');

# --- parser: escaped pipe round trips -------------------------------------
my $esc = <<'EOT';
### `GET /hosts` {#get-hosts}

| Attribute | Type | Unit | Description |
|-----------|------|------|-------------|
| host_name | string |          | a \| b
EOT
my $ea = _parse_attribute_docs($esc);
is_deeply($ea->{'/hosts'}->{GET}{'host_name'}, ['string', '', 'a | b'],
    'an escaped pipe is unescaped on the way in');

# --- parser: 2-column additional attribute table --------------------------
my $t2 = <<'EOT';
### `GET /hosts` {#get-hosts}

| Additional Attribute | Description |
|----------------------|-------------|
| `custom_var` | a custom variable
EOT
my $t2r = _parse_attribute_docs($t2);
is_deeply($t2r->{'/hosts'}->{GET}{'custom_var'}, ['', '', 'a custom variable'],
    'a 2-column additional attribute table is parsed by name');

# --- additional attributes line -------------------------------------------
my $add_doc = <<'EOT';
### `GET /contacts` {#get-contacts}

lists livestatus contacts.

Additional attributes added by Thruk:

EOT
my $add = _parse_additional_attributes($add_doc);
is($add->{'/contacts'}->{GET}, "Additional attributes added by Thruk:\n\n",
    'the additional attributes line is found under a ### heading');

my $fenced = <<'EOT';
### `GET /hosts`

````text
```
~~~
### `GET /fake`
Additional attributes added by Thruk:
| Attribute | Type | Unit | Description |
| --- | --- | --- | --- |
| fake | string | | not an attribute |
````

| `Attribute` | `Type` | `Unit` | `Description` |
| --- | --- | --- | --- |
| name | string | | host name |

| Attribute | Description |
| --- | --- |
| custom | extra data |

## Other section

Additional attributes added by Thruk:
EOT
my $fenced_attributes = _parse_attribute_docs($fenced);
is_deeply($fenced_attributes->{'/hosts'}->{GET}{name}, ['string', '', 'host name'],
    'only a matching fence closes a fenced example');
ok(!exists $fenced_attributes->{'/fake'}, 'nested fences cannot leak example endpoints');
is_deeply($fenced_attributes->{'/hosts'}->{GET}{custom}, ['', '', 'extra data'],
    'a two-column table after a four-column table uses its own schema');
is_deeply(_parse_additional_attributes($fenced), {},
    'additional markers inside examples or unrelated sections are ignored');

my $tilde = "~~~~text\n$fenced\n~~~~\n";
is_deeply(_parse_attribute_docs($tilde), {}, 'tilde fences exclude example tables');

{
    open(my $fh, '<', 'docs/documentation/rest_endpoints.md') or die $!;
    local $/;
    my $endpoints = <$fh>;
    like($endpoints, qr/^<!--GENERATED-ENDPOINTS-->$/m, 'the endpoint list is regenerated behind its marker');
    my $attributes = _parse_attribute_docs($endpoints);
    is_deeply($attributes->{'/hosts'}->{GET}{latency}, ['number', '', 'Host check latency in seconds'],
        'parses the maintained REST endpoint reference');
    ok(_parse_additional_attributes($endpoints)->{'/hosts'}->{GET}, 'preserves the maintained additional-attributes marker');
    my $panlet_description = $attributes->{'/thruk/panorama'}->{GET}{'panlet_<nr>'}->[2];
    ok($panlet_description, 'the sample dashboard panlet has a description when REST docs are regenerated');

    my $json_decoder = Cpanel::JSON::XS->new->utf8;
    open(my $sample, '<', 't/scenarios/cli_api/omd/skel/etc/thruk/panorama/1.tab') or die $!;
    my $dashboard = $json_decoder->decode(<$sample>);
    ok(scalar(grep(/(?:^|_)panlet_\d+$/, keys %{$dashboard})), 'the documentation dashboard fixture includes a panlet');

    open(my $reference, '<', 'lib/Thruk/Controller/Rest/V1/docs.pm') or die $!;
    my(undef, $json) = split(/^__DATA__\n/m, <$reference>, 2);
    my $columns = $json_decoder->decode($json)->{'/thruk/panorama'}->{GET}{columns};
    my($panlet) = grep { $_->{name} eq 'panlet_<nr>' } @{$columns};
    is($panlet->{description}, $panlet_description, 'runtime REST documentation uses the same panlet description');
}

done_testing();
