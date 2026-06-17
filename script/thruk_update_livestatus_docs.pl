#!/usr/bin/env perl
use warnings;
use strict;
use Cpanel::JSON::XS qw(encode_json);
use LWP::Simple qw(get);

my $output_file = "lib/Thruk/Controller/Rest/V1/livestatus_docs.pm";
my $source_url  = "https://raw.githubusercontent.com/naemon/naemon.github.io/refs/heads/master/src/documentation/usersguide/livestatus.columns.json";

# ── 1. Fetch Naemon livestatus columns JSON ─────────────────────────────
my $json_text = get($source_url);
die("failed to fetch $source_url\n") unless $json_text;
my $raw = eval { Cpanel::JSON::XS::decode_json($json_text) };
die("failed to parse JSON: $@\n") if $@;

# ── 2. Table → REST path mapping ────────────────────────────────────────
# Each naemon table generates two endpoints: list and single-item
my %table_paths = (
    hosts               =>        ['/hosts',                    '/hosts/<name>'],
    services            =>        ['/services',                 '/services/<host>/<service>'],
    hostgroups          =>        ['/hostgroups',               '/hostgroups/<name>'],
    servicegroups       =>        ['/servicegroups',            '/servicegroups/<name>'],
    contacts            =>        ['/contacts',                 '/contacts/<name>'],
    contactgroups       =>        ['/contactgroups',            '/contactgroups/<name>'],
    comments            =>        ['/comments',                 '/comments/<id>'],
    downtimes           =>        ['/downtimes',                '/downtimes/<id>'],
    timeperiods         =>        ['/timeperiods',              '/timeperiods/<name>'],
    commands            =>        ['/commands',                 '/commands/<name>'],
    hostsbygroup        =>        ['/hostsbygroup',             '/hostsbygroup/<hostgroup>'],
    servicesbygroup     =>        ['/servicesbygroup',          '/servicesbygroup/<servicegroup>'],
    servicesbyhostgroup =>        ['/servicesbyhostgroup',      '/servicesbyhostgroup/<hostgroup>'],
    log                 =>        ['/logs'],
    status              =>        ['/processinfo']
);

# Type mapping: naemon types → thruk types
my %type_map = (
    int    => 'number',
    float  => 'number',
    string => 'string',
    list   => 'array_of_strings',
    dict   => 'string',
);

# ── 3. Parse naemon columns and group by table ──────────────────────────
my %table_columns;
for my $entry (@$raw) {
    my($table, $column, $description, $naemon_type) = @$entry;
    push @{$table_columns{$table}}, {
        name        => $column,
        description => $description,
        naemon_type => $naemon_type,
    };
}

# ── 4. Build the output JSON ────────────────────────────────────────────
my %output;
for my $table (sort keys %table_paths) {
    my @columns = @{$table_columns{$table} // []};
    next unless @columns;

    my $cols = [];
    for my $c (@columns) {
        my $type = $type_map{$c->{naemon_type}} // 'string';
        push @$cols, {
            name        => $c->{name},
            type        => $type,
            unit        => '',
            description => $c->{description},
        };
    }

    for my $path (@{$table_paths{$table}}) {
        $output{$path}{GET}{columns} = $cols;
    }
}

# ── 5. Write the output file ────────────────────────────────────────────
my $header = <<'HEADER';
package Thruk::Controller::Rest::V1::livestatus_docs;

use warnings;
use strict;
use Cpanel::JSON::XS qw/decode_json/;

=head1 NAME

Thruk::Controller::Rest::V1::livestatus_docs - Livestatus table column metadata

=head1 DESCRIPTION

Contains column attributes for Livestatus table endpoints like /hosts and /services.
These are merged with endpoint-specific docs at runtime.

Generated from naemon.github.io livestatus.columns.json

=head1 METHODS

=head2 keys

    keys()

returns raw attributes for livestatus rest endpoints

=cut

##########################################################
sub keys {
    our $doc_data;
    if(!$doc_data) {
        my $data = "";
        while(<DATA>) {
            my $line = $_;
            next if $line =~ m/^\s*\#/mx;
            next if $line =~ m/^\s*$/mx;
            $data .= $line;
        }
        $doc_data = decode_json($data);
    }
    return($doc_data);
}

##########################################################

1;

__DATA__
HEADER

open(my $fh, '>', $output_file) or die "cannot write $output_file: $!";
print $fh $header;

my $encoder = Cpanel::JSON::XS->new->utf8->canonical->pretty->indent_length(1)->space_before(0);
print $fh $encoder->encode(\%output);
close($fh);

print "Generated $output_file\n";
printf "  Tables: %d\n", scalar keys %table_paths;
printf "  Endpoints: %d\n", scalar keys %output;

# Report tables in source but not mapped
for my $table (sort keys %table_columns) {
    if (!exists $table_paths{$table}) {
        printf "  WARNING: unmapped table '%s' (%d columns)\n", $table, scalar @{$table_columns{$table}};
    }
}
