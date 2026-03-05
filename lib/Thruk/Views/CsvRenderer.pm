package Thruk::Views::CsvRenderer;

=head1 NAME

Thruk::Views::CSVRenderer - Render CSV data

=head1 DESCRIPTION

CSV data renderer

=cut

use warnings;
use strict;
use Time::HiRes qw/gettimeofday tv_interval/;

=head1 METHODS

=head2 register

    register this renderer

=cut
sub register {
    return;
}

=head2 render_csv

    $c->render_csv($data)

=cut
sub render_csv {
    my($c, $data) = @_;

    my $t1 = [gettimeofday];
    require Thruk::Views::ToolkitRenderer;
    my $output = '';
    Thruk::Views::ToolkitRenderer::render($c, $c->stash->{'template'}, undef, \$output);
    $c->{'rendered'} = 1;
    $c->res->content_type('text/csv');
    $c->res->body($output);
    $c->stats->profile(end => "render_csv: ".$c->stash->{'template'});
    my $elapsed = tv_interval($t1);
    $c->stash->{'total_render_waited'} += $elapsed;

    return $output;
}

1;
__END__

=head1 SYNOPSIS

    $c->render_csv();

=head1 DESCRIPTION

This module renders CSV data.
