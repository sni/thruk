package Thruk::Utils::DocsMarkdown;

use warnings;
use strict;

use parent 'Exporter';
our @EXPORT_OK = qw/
    md_escape_cell md_unescape md_heading md_slug md_description
    _parse_attribute_docs _parse_additional_attributes
/;

## no critic (RegularExpressions::RequireExtendedFormatting, RegularExpressions::RequireLineBoundaryMatching, References::ProhibitDoubleSigils)
# the markdown helpers deal in literal 'backtick' characters,
# the individual lines below are whitelisted for t/092-backticks.t
sub md_escape_cell {
    my($cell) = @_;
    $cell = '' unless defined $cell;
    $cell =~ s/\|/\\\|/g;
    return $cell;
}

sub md_unescape {
    my($cell) = @_;
    $cell = '' unless defined $cell;
    $cell =~ s/\\\|/|/g;
    return($cell);
}

# split a table row on unescaped pipes; a row starts with a pipe and may lack
# a trailing pipe. an escaped pipe (\|) is kept inside the cell.
sub _md_cells {
    my($line) = @_;
    return unless $line =~ m%^\s*\|(.*)\z%;
    my $body = $1;
    $body =~ s/\s+\z//;
    my @cells = split(/(?<!\\)\|/, $body);
    # a missing trailing pipe leaves a single trailing empty cell, drop it
    pop(@cells) if @cells > 1 && $cells[-1] eq '';
    for my $cell (@cells) {
        $cell =~ s/^\s+//;
        $cell =~ s/\s+$//;
    }
    return \@cells;
}

# the heading id a vitepress heading gets, ex.:
# "POST /hosts/<name>/cmd/note" -> "post-hostsnamecmdnote"
# path separators and angle brackets are dropped, the proto/path boundary
# becomes a single dash (matches the old asciidoc post- anchors)
sub md_slug {
    my($text) = @_;
    $text =~ s/^#{1,6}\s+//;
    $text =~ s/\{#[a-z0-9_\-]+\}\s*\z//;
    $text =~ s/`//g; # NO CRITIC BACKTICKS
    my $s = lc $text;
    $s =~ s/[<>\/]+//g;
    $s =~ s/\s+/ /g;
    $s =~ s/ /-/g;
    $s =~ s/[^a-z0-9_\-]//g;
    $s =~ s/^-+//;
    $s =~ s/-+$//;
    return $s;
}

# endpoint heading, the explicit {#id} keeps the slug stable and is the link
# target of the generic cmd sections
sub md_heading {
    my($proto, $url) = @_;
    return "### `".uc($proto)." $url` {#".md_slug($proto.' '.$url)."}";
}

# Keep literal REST URLs and wildcard placeholders out of Markdown's HTML parser.
sub md_description {
    my($description) = @_;
    $description =~ s{^alias for (/[^\n]+)$}{alias for `$1`}gm; # NO CRITIC BACKTICKS
    $description =~ s{^(supports wildcards for:[^\n]*)$}{
        my $line = $1;
        $line =~ s{(?<!`)(<\w+>)(?!`)}{`$1`}g; # NO CRITIC BACKTICKS
        $line;
    }gme;
    return $description;
}

# Strip Markdown presentation from endpoint headings and table headers.
sub _heading_text {
    my($line) = @_;
    $line =~ s/^\s{0,3}#{1,6}\s+//;
    $line =~ s/\{#[a-z0-9_\-]+\}\s*\z//;
    $line =~ s/`//g; # NO CRITIC BACKTICKS
    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    return $line;
}

sub _prose_lines {
    my($content) = @_;
    my(@lines, $fence, $length);
    for my $line (split(/\n/, $content)) {
        if($fence) {
            if($line =~ m/^ {0,3}\Q$fence\E{$length,}\s*$/) {
                undef $fence;
            }
        }
        elsif($line =~ m/^ {0,3}(`{3,}|~{3,})/) { # NO CRITIC BACKTICKS
            ($fence, $length) = (substr($1, 0, 1), length($1));
        }
        else {
            push @lines, $line;
        }
    }
    return @lines;
}

sub _parse_attribute_docs {
    my($content) = @_;
    my $attributes = {};
    my($url, $proto, $in_table, $ncols);
    for my $line (_prose_lines($content)) {
        if($line =~ m%^\s{0,3}#{1,6}\s+%) {
            # a heading ends the current table and sets the current endpoint
            ($url, $proto, $in_table, $ncols) = (undef, undef, 0, undef);
            my $text = _heading_text($line);
            if($text =~ m%^(\w+)\s+(/\S+)\z%) {
                ($proto, $url) = (uc $1, $2);
            }
            next;
        }
        next unless $url && $proto;
        my $cells = _md_cells($line);
        if(!$cells) {
            $in_table = 0;
            next;
        }
        my @header = map { lc _heading_text($_) } @$cells;
        if(join('|', @header) eq 'attribute|type|unit|description') {
            ($in_table, $ncols) = (1, 4);
            next;
        }
        if(@header == 2 && $header[0] =~ /^(?:additional )?attribute$/ && $header[1] eq 'description') {
            ($in_table, $ncols) = (1, 2);
            next;
        }
        next unless $in_table;
        # the separator row follows the header row
        next if $line =~ m%^\s*\|(?:\s*:?-+:?\s*\|)+\s*\z%;
        if($ncols == 4 && @$cells >= 4) {
            my($name, $typ, $unit) = map { md_unescape($_) } @{$cells}[0, 1, 2];
            # the name is the table key, strip code ticks
            $name =~ s/`//g; # NO CRITIC BACKTICKS
            my $desc = md_unescape(join('|', @{$cells}[3 .. $#{$cells}]));
            $attributes->{$url}->{$proto}->{$name} = [$typ, $unit, $desc];
        }
        elsif($ncols == 2 && @$cells >= 2) {
            # the attribute name is inside the first cell, ex.: "host_name: desc"
            my $name = $cells->[0];
            $name =~ s/:.*\z// if $name =~ m/^\S+:/;
            $name = md_unescape($name);
            $name =~ s/`//g; # NO CRITIC BACKTICKS
            $attributes->{$url}->{$proto}{$name} = ["", "", md_unescape($cells->[1])];
        }
    }
    return $attributes;
}

# the "Additional attributes added by Thruk:" line is re-emitted in front of
# the regenerated table for the endpoint it appears under
sub _parse_additional_attributes {
    my($content) = @_;
    my $additional = {};
    my($last_url, $last_proto);
    for my $line (_prose_lines($content)) {
        if($line =~ m%^\s{0,3}#{1,6}\s+%) {
            ($last_proto, $last_url) = (undef, undef);
            my $text = _heading_text($line);
            next unless $text =~ m%^(\w+)\s+(/\S+)\z%;
            ($last_proto, $last_url) = (uc $1, $2);
        }
        # beware this line if its present, then add it to description
        next unless $last_url && $last_proto;
        if($line eq 'Additional attributes added by Thruk:') {
            $additional->{$last_url}->{$last_proto} = $line."\n\n";
        }
    }
    return $additional;
}

## use critic
1;

__DATA__

=head1 NAME

Thruk::Utils::DocsMarkdown - Markdown helpers for the docs generators

=head1 DESCRIPTION

Writes and parses the markdown tables and headings used by the rest api
documentation generators.

=head1 METHODS

=head2 md_escape_cell

    my($escaped) = md_escape_cell($cell);

Escapes pipe characters in a table cell so markdown keeps them inside the
cell. Returns an empty string for undefined cells.

=head2 md_unescape

    my($cell) = md_unescape($escaped);

Reverses md_escape_cell. Returns an empty string for undefined cells.

=head2 md_slug

    my($slug) = md_slug($heading_text);

Computes the heading anchor a vitepress heading gets. Heading markers,
backticks and explicit ids are stripped, path separators and angle brackets
are dropped, the rest is lowercased and spaces become dashes.

=head2 md_heading

    my($heading) = md_heading($proto, $url);

Renders an endpoint heading like "### POST /hosts" and adds an explicit
{#id} so the anchor stays stable.

=head2 md_description

    my($description) = md_description($text);

Wraps literal REST urls and wildcard placeholders in backticks so markdown
does not feed them to its html parser.

=cut
