package Thruk::Utils::Reports;

=head1 NAME

Thruk::Utils::Reports - Utilities Collection for Reporting

=head1 DESCRIPTION

Utilities Collection for Reporting

=cut

use warnings;
use strict;
use Carp;
use Cwd qw/abs_path/;
use Data::Dumper;
use Encode qw(encode_utf8 decode_utf8 encode);
use File::Copy;
use MIME::Lite;
use POSIX ();
use Time::HiRes qw/sleep time/;

use Thruk::Action::AddDefaults ();
use Thruk::Utils::External ();
use Thruk::Utils::Log qw/:all/;
use Thruk::Utils::Reports::Render ();
use Thruk::Utils::Status ();
use Thruk::Views::ToolkitRenderer ();

##########################################################

=head1 METHODS

=head2 get_report_list

  get_report_list($c, [$noauth], [$nr])

return list of all reports for this user

=cut
sub get_report_list {
    my($c, $noauth, $number_filter) = @_;

    $c->stats->profile(begin => "Utils::Reports::get_report_list(".($number_filter//'all').")");

    my $reports = [];
    for my $rfile (glob($c->config->{'var_path'}.'/reports/*.rpt')) {
        if($rfile =~ m/\/(\d+)\.rpt/mx) {
            my $nr = $1;
            next if $number_filter && $nr ne $number_filter;
            my $r  = read_report_file($c, $nr, undef, $noauth, 1);
            next unless $r;
            if($r->{'var'} and $r->{'var'}->{'job'}) {
                my($is_running,$time,$percent,$message,$forward) = Thruk::Utils::External::get_status($c, $r->{'var'}->{'job'});
                $r->{'var'}->{'job_data'} = {
                    time    => $time,
                    percent => $percent,
                    message => $message,
                } if defined $time;
            }
            push @{$reports}, $r;
        }
    }

    # sort by name
    @{$reports} = sort { $a->{'name'} cmp $b->{'name'} } @{$reports};

    $c->stats->profile(end => "Utils::Reports::get_report_list(".($number_filter//'all').")");
    return $reports;
}

##########################################################

=head2 get_report

  get_report_list($c, $nr, [$noauth])

return report for given id

=cut
sub get_report {
    my($c, $nr, $noauth) = @_;

    my $reports = get_report_list($c, $noauth, $nr);
    if(!$reports->[0]) {
        die("no such report: ".$nr);
    }
    return $reports->[0];
}

##########################################################

=head2 report_show

  report_show($c, $nr)

generate and show the report

=cut
sub report_show {
    my($c, $nr, $refresh) = @_;

    my $report = read_report_file($c, $nr);
    if(!defined $report) {
        Thruk::Utils::set_message( $c, 'fail_message', 'no such report' );
        return $c->redirect_to('reports2.cgi');
    }

    my $report_file = $c->config->{'var_path'}.'/reports/'.$nr.'.dat';
    if($refresh || ! -f $report_file) {
        generate_report($c, $nr);
    }

    if(defined $report_file and -f $report_file) {
        $c->stash->{'template'} = 'passthrough.tt';
        if($c->req->parameters->{'html'}) {
            my $html_file   = $c->config->{'var_path'}.'/reports/'.$nr.'.html';
            if(!-e $html_file) {
                $html_file = $c->config->{'var_path'}.'/reports/'.$nr.'.dat';
            }
            my $report_text = decode_utf8(Thruk::Utils::IO::read($html_file));
            $report_text    =~ s/^<body>/<body class="preview">/mx;
            $report_text    =~ s/^<html>/<html class="preview">/mx;
            $c->stash->{'text'} = $report_text;
        }
        elsif($report->{'var'}->{'attachment'} && (!$report->{'var'}->{'ctype'} || $report->{'var'}->{'ctype'} ne 'html2pdf')) {
            my $name = $report->{'var'}->{'attachment'};
            $name    =~ s/\s+/_/gmx;
            $name    =~ s/[^\wöäüÖÄÜß\-_\.]+//gmx;
            $c->res->headers->header( 'Content-Disposition', 'attachment; filename="'.$name.'"' );
            if($report->{'var'}->{'ctype'}) {
                if($report->{'var'}->{'ctype'} eq 'text/html') {
                    $c->res->content_type("text/html; charset=utf-8");
                } else {
                    $c->res->content_type($report->{'var'}->{'ctype'});
                }
            }
            my $fh;
            if($report->{'var'}->{'ctype'} eq 'text/html') {
                open($fh, '<', $c->config->{'var_path'}.'/reports/'.$nr.'.html');
            } else {
                open($fh, '<', $report_file);
            }
            binmode $fh;
            $c->res->body($fh);
            $c->{'rendered'} = 1;
            return 1;
        } else {
            my $name = $report->{'name'};
            $name    =~ s/\s+/_/gmx;
            $name    =~ s/[^\wöäüÖÄÜß\-_\.]+//gmx;
            $c->res->headers->content_type('application/pdf');
            $c->res->headers->header( 'Content-Disposition', 'filename='.$name.'.pdf' );
            open(my $fh, '<', $report_file);
            binmode $fh;
            $c->res->body($fh);
            $c->{'rendered'} = 1;
            return 1;
        }
    } else {
        if($Thruk::Utils::Reports::error) {
            Thruk::Utils::set_message( $c, 'fail_message', 'generating report failed: '.$Thruk::Utils::Reports::error );
        } else {
            Thruk::Utils::set_message( $c, 'fail_message', 'generating report failed' );
        }
        return $c->redirect_to('reports2.cgi');
    }
    return 1;
}

##########################################################

=head2 report_send

  report_send($c, $nr, [$skip_generate, $to, $cc, $subject, $desc])

generate and send the report

return values are:

   -2 : nothing to do, report runs on another cluster node already
    0 : report failed
    1 : report sucessful and mail was sent
    2 : report generated, no mail send because of thresholds not hit

=cut
sub report_send {
    my($c, $nr, $skip_generate, $to, $cc, $subject, $desc) = @_;
    $c->stats->profile(begin => "Utils::Reports::report_send()");

    if($c->config->{'demo_mode'}) {
        Thruk::Utils::set_message( $c, 'fail_message', 'sending mails disabled in demo mode');
        return $c->redirect_to('reports2.cgi');
    }

    my $report = read_report_file($c, $nr);
    if(!defined $report) {
        Thruk::Utils::set_message( $c, 'fail_message', 'no such report' );
        return $c->redirect_to('reports2.cgi');
    }
    # make report available in template
    $report->{'desc'} = $desc if $to;
    $c->stash->{'r'} = $report;

    my $attachment;
    if($skip_generate) {
        $attachment = $c->config->{'var_path'}.'/reports/'.$report->{'nr'}.'.dat';
        if(!-s $attachment) {
            Thruk::Utils::set_message( $c, 'fail_message', 'report not yet generated' );
            return $c->redirect_to('reports2.cgi');
        }
    } else {
        $attachment = generate_report($c, $nr);
    }
    $report = read_report_file($c, $nr); # update report data, attachment would be wrong otherwise
    _initialize_report_templates($c, $report);
    if(!defined $attachment) {
        Thruk::Utils::set_message( $c, 'fail_message', 'failed to send report' );
        return 0;
    }
    if($attachment eq "-2") {
        return(-2);
    }

    # mail should not be sent
    if(defined $report->{'var'}->{'send_mail_threshold_reached'} && !$report->{'var'}->{'send_mail_threshold_reached'}) {
        return 2;
    }

    $c->stash->{'block'}       = 'mail';
    $c->stash->{'plugin_name'} = Thruk::Utils::get_plugin_name(__FILE__, __PACKAGE__);
    my $mailtext;
    eval {
        $c->stash->{'start'} = '' unless defined $c->stash->{'start'};
        Thruk::Views::ToolkitRenderer::render($c, 'reports/'.$report->{'template'}, undef, \$mailtext);
    };
    if($@) {
        _error($@);
        return $c->detach('/error/index/13');
    }
    $mailtext = Thruk::Base::trim_whitespace($mailtext);
    # remove empty lines from the end
    $mailtext =~ s/\n+\Z/\n/sgmx;

    # extract mail header
    my $mailbody    = "";
    my $bodystarted = 0;
    my $mailheader  = {};
    # fill some configured mail headers from config file into here
    my $configured_mailheaders = $c->config->{'Thruk::Plugin::Reports2'}->{'default_mail_headers'};
    if($configured_mailheaders && ref($configured_mailheaders) eq 'HASH') {
        # just discard unless hash format from config
        $mailheader = { map { lc($_) => $configured_mailheaders->{$_} } keys %{$configured_mailheaders} };
    }
    for my $line (split/\n/mx, $mailtext) {
        # header lines consist of printable ascii chars (no ':') followed by ':' (RFC5322)
        if($line !~ m/^$/mx and $line !~ m/^[[:graph:]]+?:/mx) {
            $bodystarted = 1;
        }
        if($bodystarted) {
            $mailbody .= $line."\n";
        } elsif($line =~ m/^([[:graph:]]+?):\s*(.*)$/mx) {
            $mailheader->{lc($1)} = $2;
        }
        if($line =~ m/^$/mx) {
            $bodystarted = 1;
        }
    }
    my $bcc  = '';
    my $from = $report->{'from'} || $mailheader->{'from'} || $c->config->{'Thruk::Plugin::Reports2'}->{'report_from_email'};
    if(!$to) {
        $to      = $report->{'to'}      || $mailheader->{'to'};
        $cc      = $report->{'cc'}      || $mailheader->{'cc'};
        $bcc     = $report->{'bcc'}     || $mailheader->{'bcc'};
        $subject = $report->{'subject'} || $mailheader->{'subject'} || 'Thruk Report';
    }
    my $subj_prepend = $c->config->{'Thruk::Plugin::Reports2'}->{'report_subject_prepend'};
    if($subj_prepend && $subject !~ /^\s*\Q$subj_prepend\E/mx) {
        $subject = $subj_prepend . $subject;
    }

    $subject  = _replace_report_macros($c, $subject);
    $mailbody = _replace_report_macros($c, $mailbody);

    my $msg = MIME::Lite->new();
    $msg->build(
             From    => $from // '',
             To      => $to   // '',
             Cc      => $cc   // '',
             Bcc     => $bcc  // '',
             Subject => encode("MIME-B", decode_utf8($subject)),
             Type    => 'multipart/mixed',
    );
    for my $key (keys %{$mailheader}) {
        my $value = $mailheader->{$key};
        $key = lc($key);
        next if $key eq 'from';
        next if $key eq 'to';
        next if $key eq 'cc';
        next if $key eq 'bcc';
        next if $key eq 'subject';
        $msg->add($key => $mailheader->{$key});
    }
    $msg->attach(Type     => 'text/plain; charset=utf-8',
                 Data     => $mailbody,
    );

    # url reports as html
    if(defined $report->{'params'}->{'pdf'} && $report->{'params'}->{'pdf'} eq 'no') {
        $attachment = $c->config->{'var_path'}.'/reports/'.$report->{'nr'}.'.html';
        if(!-s $attachment) {
            $attachment = $c->config->{'var_path'}.'/reports/'.$report->{'nr'}.'.dat';
        }
        my $ctype = 'text/html';
        if($report->{'var'}->{'ctype'} && $report->{'var'}->{'ctype'} ne 'html2pdf') {
            $ctype = $report->{'var'}->{'ctype'};
        }
        $msg->attach(Type    => $ctype,
                 Path        => $attachment,
                 Filename    => encode_utf8($report->{'var'}->{'attachment'}),
                 Disposition => 'attachment',
                 Encoding    => 'base64', # default encoding 8bit adds linebreaks after 1000chars which breaks csv reports
        );
    }
    elsif($report->{'var'}->{'attachment'} && (!$report->{'var'}->{'ctype'} || $report->{'var'}->{'ctype'} ne 'html2pdf')) {
        $msg->attach(Type    => $report->{'var'}->{'ctype'},
                 Path        => $attachment,
                 Filename    => encode_utf8($report->{'var'}->{'attachment'}),
                 Disposition => 'attachment',
        );
    } else {
        $msg->attach(Type    => 'application/pdf',
                 Path        => $attachment,
                 Filename    => 'report.pdf',
                 Disposition => 'attachment',
        );
    }

    if($report->{'var'}->{'json_file'} && -e $report->{'var'}->{'json_file'}) {
        $msg->attach(Type    => 'text/json',
                 Path        => $report->{'var'}->{'json_file'},
                 Filename    => encode_utf8(Thruk::Base::basename($report->{'var'}->{'json_file'})),
                 Disposition => 'attachment',
                 Encoding    => 'base64',
        );
    }

    if($ENV{'THRUK_MAIL_TEST'}) {
        $msg->send_by_testfile($ENV{'THRUK_MAIL_TEST'});
        $c->stats->profile(end => "Utils::Reports::report_send()");
        return 1;
    }

    my @send_args = ();
    my $send_type = $c->config->{'Thruk::Plugin::Reports2'}->{mail_type};
    if($send_type) {
        @send_args = ($send_type);
        my $send_scalar_args = $c->config->{'Thruk::Plugin::Reports2'}->{mail_args};
        if($send_scalar_args) {
            push @send_args, @{Thruk::Base::list($send_scalar_args)};
        }
        my $send_named_args = $c->config->{'Thruk::Plugin::Reports2'}->{mail_named_args};
        if($send_named_args) {
            if(ref($send_named_args) eq 'HASH') {
                push @send_args, %{$send_named_args};
            }
            elsif(ref $send_named_args) {
                # what to do?
                die 'cant handle mail arg of ref ' . ref($send_named_args);
            }
            else {
                push @send_args, $send_named_args;
            }
        }
    }
    my $rc;
    eval {
        $rc = $msg->send(@send_args);
    };
    my $err = $@;
    if($err) {
        chomp($err);
        my $logfile = $c->config->{'var_path'}.'/reports/'.$nr.'.log';
        _report_die($c, $nr, "sending email failed: $err", $logfile);
        return(0);
    }
    $c->stats->profile(end => "Utils::Reports::report_send()");

    return $rc ? 1 : 0;
}

##########################################################

=head2 report_save

  report_save($c, $nr, $data)

save a report

=cut
sub report_save {
    my($c, $nr, $data) = @_;

    Thruk::Utils::IO::mkdir($c->config->{'var_path'}.'/reports/');
    my $file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    my $old_report;
    if($nr ne 'new' && -f $file) {
        $old_report = read_report_file($c, $nr);
        return unless defined $old_report;
        return if $old_report->{'readonly'};
    }
    my $report        = get_new_report($c, $data);
    $report->{'var'}  = $old_report->{'var'}  if defined $old_report->{'var'};
    my $fields = _get_required_fields($c, $report);
    if(!$fields) {
        Thruk::Utils::set_message( $c, 'fail_message', 'invalid report template');
        $report->{'var'}->{'opt_errors'} = ['invalid report template'];
        return;
    }
    $report->{'user'} = $c->stash->{'remote_user'};
    $report->{'user'} = $old_report->{'user'} if defined $old_report->{'user'};
    if($c->check_user_roles('authorized_for_admin') && $data->{'user'}) {
        $report->{'user'} = $data->{'user'};
    }
    _verify_fields($c, $fields, $report);
    return store_report_data($c, $nr, $report);
}

##########################################################

=head2 report_remove

  report_remove($c, $nr)

remove report

=cut
sub report_remove {
    my($c, $nr) = @_;

    my $report = read_report_file($c, $nr);
    return unless defined $report;
    return unless defined $report->{'readonly'};
    return if $report->{'var'}->{'is_running'};
    return unless $report->{'readonly'} == 0;

    unlink($c->config->{'var_path'}.'/reports/'.$nr.'.rpt');
    clean_report_tmp_files($c, $nr);

    my $index_file = $c->config->{'var_path'}.'/reports/.index';
    Thruk::Utils::IO::json_lock_patch($index_file, { $nr => undef }, { pretty => 1, allow_empty => 1 });

    # remove cron entries
    update_cron_file($c);

    return 1;
}

##########################################################

=head2 generate_report

  generate_report($c, $nr)

generate a new report

=cut
sub generate_report {
    my($c, $nr) = @_;
    $Thruk::Utils::PDF::attachment     = '';
    $Thruk::Utils::PDF::ctype          = 'html2pdf';
    $c->stash->{'report_tmp_files_to_delete'} = [];

    Thruk::Utils::IO::mkdir($c->config->{'var_path'}.'/reports/');
    my $report_file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    my $attachment  = $c->config->{'var_path'}.'/reports/'.$nr.'.dat';
    $c->stash->{'attachment'} = $attachment;

    # set waiting flag on queued reports
    $c->stats->profile(begin => "Utils::Reports::generate_report()");
    my $options = read_report_file($c, $nr);
    unless(defined $options) {
        $Thruk::Utils::Reports::error = 'got no report options';
        return;
    }

    set_waiting($c, $nr, 0);

    # don't run report twice per minute
    if($ENV{'THRUK_CRON'} && !($options->{'var'}->{'is_running'} == $$ && $options->{'var'}->{'running_node'} eq $Thruk::Globals::NODE_ID)) {
        if($options->{'var'}->{'start_time'}) {
            if(POSIX::strftime("%Y-%m-%d %H:%M", localtime($options->{'var'}->{'start_time'})) eq POSIX::strftime("%Y-%m-%d %H:%M", localtime())) {
                $Thruk::Utils::Reports::error = '['.$nr.'.rpt] report has been calculated on '.$c->cluster->node_name($options->{'var'}->{'running_node'}).' already';
                return -2;
            }
        }
    }

    set_running($c, $nr, $$, time()) unless $options->{'var'}->{'is_running'} > 0;

    # report is already beeing generated, check if the other process is alive
    if($options->{'var'}->{'is_running'} > 0 && ($options->{'var'}->{'is_running'} != $$ || $options->{'var'}->{'running_node'} ne $Thruk::Globals::NODE_ID)) {
        # if started by cron, just exit, some other node is doing the report already
        if($ENV{'THRUK_CRON'}) {
            $Thruk::Utils::Reports::error = '['.$nr.'.rpt] report is running on '.$c->cluster->node_name($options->{'var'}->{'running_node'}).' already';
            return -2;
        }

        # just wait till its finished and return
        while($options->{'var'}->{'is_running'}) {
            sleep 1;
            return unless -f $report_file; # report may have been deleted meanwhile
            $options = read_report_file($c, $nr);
        }
        if(-e $attachment) {
            return $attachment;
        }
    }

    # update report runtime data
    set_running($c, $nr, $$, time());

    my $default_time_locale = POSIX::setlocale(POSIX::LC_TIME);

    $c->req->parameters->{'debug'} = 1 if $ENV{'THRUK_REPORT_DEBUG'};

    # report should always run in the report owner context
    if(!$c->user_exists || ($options->{'user'} ne $c->user->{'username'})) {
        Thruk::Utils::set_user($c,
            username     => $options->{'user'},
            auth_src     => "report",
            force        => 1,
            keep_session => 1,
        );
    }

    $c->stash->{'refresh_rate'}   = 0;
    $c->stash->{'no_auto_reload'} = 1;
    $c->stash->{'inject_stats'}   = 0;

    # clean up first
    clean_report_tmp_files($c, $nr);

    if($options->{'var'}->{'debug_file'}) {
        unlink($options->{'var'}->{'debug_file'});
        undef($options->{'var'}->{'debug_file'});
    }
    if($options->{'var'}->{'json_file'}) {
        unlink($options->{'var'}->{'json_file'});
        undef($options->{'var'}->{'json_file'});
    }

    # empty logfile
    my $logfile = $c->config->{'var_path'}.'/reports/'.$nr.'.log';
    open(my $fh, '>', $logfile);
    Thruk::Utils::IO::close($fh, $logfile);

    # check for exposed custom variables
    my $allowed = Thruk::Utils::get_exposed_custom_vars($c->config);
    for my $key (qw/hostnameformat_cust servicenameformat_cust/) {
        if($options->{'params'}->{$key}) {
            if(!Thruk::Utils::check_custom_var_list($options->{'params'}->{$key}, $allowed)) {
                return(_report_die($c, $nr, "report contains custom variable ".$options->{'params'}->{$key}." which is not exposed by: show_custom_vars or expose_custom_vars", $logfile));
            }
        }
    }

    # do we have errors in our options, ex.: missing required fields?
    if(defined $options->{'var'}->{'opt_errors'}) {
        return(_report_die($c, $nr, join("\n", @{$options->{'var'}->{'opt_errors'}}), $logfile));
    }

    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 1, 'starting') if $ENV{'THRUK_JOB_DIR'};
    delete $options->{'var'}->{'send_mail_threshold_reached'};

    if(defined $options->{'backends'}) {
        $options->{'backends'} = ref $options->{'backends'} eq 'ARRAY' ? $options->{'backends'} : [ $options->{'backends'} ];
    }
    local $ENV{'THRUK_BACKENDS'} = join(';', @{$options->{'backends'}}) if(defined $options->{'backends'} and scalar @{$options->{'backends'}} > 0);

    # need to update defaults backends
    my($disabled_backends,$has_groups);
    eval {
        ($disabled_backends,$has_groups) = Thruk::Action::AddDefaults::set_enabled_backends($c);
        Thruk::Action::AddDefaults::set_possible_backends($c, $disabled_backends);
    };
    if($@) {
        return(_report_die($c, $nr, $@, $logfile));
    }

    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 2, 'getting backends') if $ENV{'THRUK_JOB_DIR'};

    # check backend connections
    my $processinfo = $c->db->get_processinfo();
    if($options->{'backends'}) {
        my @failed;
        for my $b (keys %{$disabled_backends}) {
            next unless $disabled_backends->{$b} == 0;
            if($c->stash->{'failed_backends'}->{$b}) {
                push @failed, $c->db->get_peer_by_key($b)->peer_name().': '.$c->stash->{'failed_backends'}->{$b};
            }
        }
        if($options->{'failed_backends'} eq 'cancel') {
            if(scalar @failed > 0) {
                my $error = "Some backends are not connected, cannot create report!\n".join("\n", @failed)."\n";
                return(_report_die($c, $nr, $error, $logfile));
            }
        }
    }
    $c->stash->{'selected_backends'} = [];
    for my $b (keys %{$disabled_backends}) {
        next unless $disabled_backends->{$b} == 0;
        push @{$c->stash->{'selected_backends'}}, $b;
    }

    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 3, 'setting defaults') if $ENV{'THRUK_JOB_DIR'};

    # set some defaults
    Thruk::Utils::Reports::Render::set_unavailable_states([qw/DOWN UNREACHABLE CRITICAL UNKNOWN/]);
    $c->req->parameters->{'show_log_entries'}           = 1;
    $c->req->parameters->{'assumeinitialstates'}        = 'yes';
    #$c->req->parameters->{'initialassumedhoststate'}    = 3; # UP
    #$c->req->parameters->{'initialassumedservicestate'} = 6; # OK
    $c->req->parameters->{'initialassumedhoststate'}    = 0; # Unspecified
    $c->req->parameters->{'initialassumedservicestate'} = 0; # Unspecified

    if(!defined $options->{'template'}) {
        return(_report_die($c, $nr, 'template reports/'.$options->{'template'}.' does not exist', $logfile));
    }

    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 4, 'initializing') if $ENV{'THRUK_JOB_DIR'};
    _initialize_report_templates($c, $options);

    # disable tt cache to read custom templates every time
    my $orig_stat_ttl = $c->app->{'tt'}->context->{'LOAD_TEMPLATES'}->[0]->{'STAT_TTL'};
    $c->app->{'tt'}->context->{'LOAD_TEMPLATES'}->[0]->{'STAT_TTL'} = 0;

    $c->stash->{'plugin_name'} = Thruk::Utils::get_plugin_name(__FILE__, __PACKAGE__);

    # prepare stage, functions here could still change stash
    eval {
        Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 5, 'preparing') if $ENV{'THRUK_JOB_DIR'};
        $c->stash->{'block'} = 'prepare';
        my $discard;
        Thruk::Views::ToolkitRenderer::render($c, 'reports/'.$options->{'template'}, undef, \$discard);
    };
    my $err = $@;
    if($err) {
        return(_report_die($c, $nr, $err, $logfile));
    }

    # replace macros in name and description
    for my $key (qw/name desc/) {
        $c->stash->{'r'}->{$key} = _replace_report_macros($c, $c->stash->{'r'}->{$key});
    }
    Thruk::Utils::IO::json_lock_patch($report_file, { var => {
        name => $c->stash->{'r'}->{'name'},
        desc => $c->stash->{'r'}->{'desc'},
    }}, { pretty => 1 });

    # render report
    $c->stash->{'param'}->{'mail_max_level_count'} = 0;
    my $reportdata;
    eval {
        Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 80, 'rendering') if $ENV{'THRUK_JOB_DIR'};
        $c->stash->{'block'} = 'render';
        Thruk::Views::ToolkitRenderer::render($c, 'reports/'.$options->{'template'}, undef, \$reportdata);
    };
    $err = $@;
    if($err) {
        return(_report_die($c, $nr, $err, $logfile));
    }
    POSIX::setlocale(POSIX::LC_TIME, $default_time_locale);

    # convert to pdf
    if($Thruk::Utils::PDF::ctype eq 'text/html') {
        my $htmlfile = $c->config->{'var_path'}.'/reports/'.$nr.'.html';
        if(!$options->{'params'}->{'pdf'} || $options->{'params'}->{'pdf'} eq 'yes') {
            $Thruk::Utils::PDF::ctype = "html2pdf";
            move($attachment, $htmlfile);
            Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 90, 'converting') if $ENV{'THRUK_JOB_DIR'};
            _convert_to_pdf($c, $reportdata, $attachment, $nr, $logfile);
        } else {
            copy($attachment, $htmlfile);
        }
    }
    elsif($Thruk::Utils::PDF::ctype eq 'html2pdf') {
        Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 90, 'converting') if $ENV{'THRUK_JOB_DIR'};
        _convert_to_pdf($c, $reportdata, $attachment, $nr, $logfile, 1);
    }

    # set error if not already set
    if(!-f $attachment && !$Thruk::Utils::Reports::error) {
        $Thruk::Utils::Reports::error = Thruk::Utils::IO::read($logfile);
    }
    _error($Thruk::Utils::Reports::error);

    # check backend errors from during report generation
    if($options->{'backends'}) {
        my @failed;
        for my $b (@{$options->{'backends'}}) {
            if($c->stash->{'failed_backends'}->{$b}) {
                push @failed, $c->db->get_peer_by_key($b)->peer_name().': '.$c->stash->{'failed_backends'}->{$b};
            }
        }
        if($options->{'failed_backends'} eq 'cancel' and scalar @failed > 0) {
            unlink($attachment);
            my $error = "Some backends threw errors, cannot create report!\n".join("\n", @failed)."\n";
            return(_report_die($c, $nr, $error, $logfile));
        }
    }

    if($c->req->parameters->{'attach_json'} && lc($c->req->parameters->{'attach_json'}) ne 'no') {
        my $json_attachment = $c->config->{'var_path'}.'/reports/'.$nr.'.json';
        my $json = {};
        $json->{'outages'}      = $c->stash->{'last_outages'} if $c->stash->{'last_outages'};
        $json->{'availability'} = $c->stash->{'last_availability'} if $c->stash->{'last_availability'};
        Thruk::Utils::IO::json_lock_store($json_attachment, $json);
        Thruk::Utils::IO::json_lock_patch($report_file, { var => { json_file => $json_attachment } }, { pretty => 1 });
    }

    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 95, 'clean up') if $ENV{'THRUK_JOB_DIR'};

    # clean up tmp files
    for my $file (@{$c->stash->{'report_tmp_files_to_delete'}}) {
        unlink($file);
    }

    if($c->stash->{'debug_info'}) {
        my $debug_file = Thruk::Action::AddDefaults::save_debug_information_to_tmp_file($c);
        if($debug_file) {
            my $rpt_debug_file = $c->config->{'var_path'}.'/reports/'.$nr.'.dbg';
            if(-s $debug_file > 1000000) {
                Thruk::Utils::IO::cmd("gzip $debug_file >/dev/null 2>&1");
                if(!-s $debug_file && -s $debug_file.'.gz') {
                    $rpt_debug_file = $c->config->{'var_path'}.'/reports/'.$nr.'.dbg.gz';
                    move($debug_file.'.gz', $rpt_debug_file);
                }
            } else {
                move($debug_file, $rpt_debug_file);
            }
            my $patch = {};
            Thruk::Utils::IO::json_lock_patch($report_file, { var => { debug_file => $rpt_debug_file } }, { pretty => 1 });
        }
    }

    # restore tt cache settings
    $c->app->{'tt'}->context->{'LOAD_TEMPLATES'}->[0]->{'STAT_TTL'} = $orig_stat_ttl;

    $c->stats->profile(end => "Utils::Reports::generate_report()");

    my $send_mail_threshold_reached = 1;
    if(defined $c->stash->{'param'}->{'mail_max_level'} && $c->stash->{'param'}->{'mail_max_level'} != -1) {
        $send_mail_threshold_reached = 0;
        if($c->stash->{'param'}->{'mail_max_level_count'} > 0) {
            $send_mail_threshold_reached = 1;
        }
        Thruk::Utils::IO::json_lock_patch($report_file, { var => { send_mail_threshold_reached => $send_mail_threshold_reached } }, { pretty => 1 });
    }

    if($options->{'var'}->{'send_mails_next_time'} && $send_mail_threshold_reached) {
        report_send($c, $nr, 1);
    }
    Thruk::Utils::IO::json_lock_patch($report_file, { var => { send_mails_next_time => undef } }, { pretty => 1 });


    # update report runtime data
    Thruk::Utils::External::update_status($ENV{'THRUK_JOB_DIR'}, 100, 'finished') if $ENV{'THRUK_JOB_DIR'};
    set_running($c, $nr, 0, undef, time());

    check_for_waiting_reports($c);
    return $attachment;
}

##########################################################

=head2 queue_report

  queue_report($c, $nr, [$mail])

queue a report for update.
returns true if report got queued.

=cut
sub queue_report {
    my($c, $nr, $with_mails) = @_;

    my $options = read_report_file($c, $nr);
    if(!$c->stash->{'remote_user'}) {
        $c->stash->{'remote_user'} = $options->{'user'};
    }
    return if $options->{'var'}->{'is_running'};

    # don't queue report if it has been run this minute already
    if($ENV{'THRUK_CRON'}) {
        if($options->{'var'}->{'start_time'}) {
            if(POSIX::strftime("%Y-%m-%d %H:%M", localtime($options->{'var'}->{'start_time'})) eq POSIX::strftime("%Y-%m-%d %H:%M", localtime())) {
                return;
            }
        }
    }

    set_waiting($c, $nr, time(), $with_mails);
    return 1;
}

##########################################################

=head2 queue_report_if_busy

  queue_report_if_busy($c, $nr, [$mail])

Queue a report for update. Queue will only be used if all slots are busy.
Returns 1 if queue is used or undef if there are free slots.

=cut
sub queue_report_if_busy {
    my($c, $nr, $with_mails) = @_;

    my $options = read_report_file($c, $nr);
    return   if $options->{'var'}->{'is_running'} == $$;
    return 1 if $options->{'var'}->{'is_running'};

    my $max_concurrent_reports = $c->config->{'Thruk::Plugin::Reports2'}->{'max_concurrent_reports'} || 2;
    my($running, $waiting) = get_running_reports_number($c);

    # free slots on current host?
    if($running >= $max_concurrent_reports) {
        if(queue_report($c, $nr,$with_mails)) {
            return(1);
        }
    }

    return;
}

##########################################################

=head2 generate_report_background

  generate_report_background($c, $report_nr, $with_mails, $report, $force, $debug)

start a report in the background and queue it if all slots are busy

=cut
sub generate_report_background {
    my($c, $report_nr, $with_mails, $report, $force, $debug) = @_;

    # using queue
    if(!$force && queue_report_if_busy($c, $report_nr)) {
        return;
    }

    $report = read_report_file($c, $report_nr) unless $report;

    # report should always run in the report owner context
    if(!$c->user_exists || ($report->{'user'} ne $c->user->{'username'})) {
        Thruk::Utils::set_user($c,
            username     => $report->{'user'},
            auth_src     => "report",
            force        => 1,
            keep_session => 1,
        );
    }

    set_running($c, $report_nr, $$, time());
    my $cmd = _get_report_cmd($c, $report->{'nr'}, 0);
    clean_report_tmp_files($c, $report_nr);
    delete $c->config->{'no_external_job_forks'}; # always start in background
    my $job = Thruk::Utils::External::cmd($c, {
                                               'cmd'        => $cmd,
                                               'background' => 1,
                                               'no_shell'   => 1,
                                               'env'        => {
                                                                THRUK_REPORT_DEBUG => $debug,
                                                                THRUK_REPORT_PARENT => $$,
                                                            },
                                            });

    set_running($c, $report_nr, undef, undef, undef, $job);
    return unless $job;

    # wait up to 3 seconds till background job is really started
    my $index_file = $c->config->{'var_path'}.'/reports/.index';
    for (1..30) {
        Time::HiRes::sleep(0.1);
        my $index   = Thruk::Utils::IO::json_lock_retrieve($index_file);
        if(!$index->{$report_nr} || !$index->{$report_nr}->{'is_running'} || $index->{$report_nr}->{'is_running'} ne $$) {
            last;
        }
    }

    return $job;
}

##########################################################

=head2 get_report_data_from_param

  get_report_data_from_param($params)

return report data for given params

=cut
sub get_report_data_from_param {
    my($params) = @_;
    my $p = {};

    # nested variables
    my $nested_keys = {};
    for my $key (keys %{$params}) {
        next unless $key =~ m/^params\.([\w]+)\.([\w]+)$/mx;
        $p->{$1}->{$2} = Thruk::Base::list($params->{$key});
        $nested_keys->{$1} = 1;
    }
    for my $key (sort keys %{$nested_keys}) {
        my $raw      = $p->{$key};
        my $sorted   = [];
        my $firstkey = (keys %{$raw})[0];
        for my $nr (1..scalar @{$raw->{$firstkey}}-1) {
            my $entry   = {};
            for my $name (sort keys %{$raw}) {
                $entry->{$name} = $raw->{$name}->[$nr] // '';
            }
            push @{$sorted}, $entry;
        }
        $p->{$key} = $sorted;
    }

    # normal variables
    for my $key (keys %{$params}) {
        next if $key =~ m/^params\.([\w]+)\.([\w]+)$/mx;
        next unless $key =~ m/^params\.([\w\.]+)$/mx;
        if(ref $params->{$key} eq 'ARRAY') {
            # remove empty elements
            @{$params->{$key}} = grep(!/^$/mx, @{$params->{$key}});
        }
        if($1 eq 'sla') { $params->{$key} =~ s/,/./gmx }
        $p->{$1} = $params->{$key};
    }

    for my $key (keys %{$params}) {
        # complex filter
        if($key =~ m/^filter\.(.*)$/mx) {
            my $name    = $1;
            my $prefix  = $params->{$key};
            $p->{$name} = {};
            for my $k (keys %{$params}) {
                if($k =~ m/^$prefix(.*$)/mx) {
                    my $fk = $1;
                    $p->{$name}->{'dfl_'.$fk} = $params->{$k};
                }
            }
        }
    }

    # optional variables
    for my $key (keys %{$params}) {
        next unless $key =~ m/^optional\.([\w\.]+)$/mx;
        if(!$params->{'enabled.'.$1}) {
            $p->{$1} = -1;
        }
    }
    for my $key (qw/t1 t2/) {
        $p->{$key} = $params->{$key} if defined $params->{$key};
    }

    # only save backends if checkbox checked
    if(!$params->{'backends_toggle'} && !$params->{'report_backends_toggle'}) {
        $params->{'report_backends'} = [];
    }

    # extract permission
    my $permissions = [];
    for my $key (sort keys %{$params}) {
        if($key =~ m/^p_(\d+)_perm$/mx) {
            my $nr = $1;
            my $type = $params->{'p_'.$nr.'_ts'} // "";
            if($type eq 'contact')         { $type = "user";  }
            elsif($type eq 'contactgroup') { $type = "group"; }
            else { confess("invalid type"); }
            my $perm = $params->{'p_'.$nr.'_perm'} // "";
            if($perm ne 'ro' && $perm ne 'rw') { confess("invalid permission"); }
            my $names = [split(/\s*,\s*/mx, $params->{'p_'.$nr.'_value'} // "")];
            if(scalar @{$names} == 0) { next; }
            push @{$permissions}, {
                'type' => $type,
                'name' => $names,
                'perm' => $perm,
            };
        }
    }

    my $send_types = Thruk::Utils::get_cron_entries_from_param($params);
    my $data = {
        'name'            => $params->{'name'}            || 'New Report',
        'desc'            => $params->{'desc'}            || '',
        'template'        => $params->{'template'}        || 'sla.tt',
        'to'              => $params->{'to'}              || '',
        'cc'              => $params->{'cc'}              || '',
        'backends'        => $params->{'report_backends'} || [],
        'failed_backends' => $params->{'failed_backends'} || 'cancel',
        'permissions'     => $permissions,
        'params'          => $p,
        'send_types'      => $send_types,
        'user'            => $params->{'owner'},
    };

    return($data);
}

##########################################################

=head2 update_cron_file

  update_cron_file($c)

update reporting cronjobs

=cut
sub update_cron_file {
    my($c) = @_;

    # gather reporting send types from all reports
    my $combined_entries = {};
    my $reports = get_report_list($c, 1);
    @{$reports} = sort { $a->{'nr'} <=> $b->{'nr'} } @{$reports};

    for my $r (@{$reports}) {
        next unless defined $r->{'send_types'};
        next unless scalar @{$r->{'send_types'}} > 0;
        for my $st (@{$r->{'send_types'}}) {
            my $time = Thruk::Utils::get_cron_time_entry($st);
            next unless defined $time;
            $combined_entries->{$time} = [] unless $combined_entries->{$time};
            push @{$combined_entries->{$time}}, $r->{'nr'};
        }
    }
    my $cron_entries = [];
    for my $time (sort keys %{$combined_entries}) {
        my $cmd = _get_report_cmd($c, $combined_entries->{$time});
        push @{$cron_entries}, [$time, $cmd];
    }

    Thruk::Utils::update_cron_file($c, 'reports', $cron_entries);
    return 1;
}

##########################################################

=head2 set_running

  set_running($c, $nr, [$val])

    $val can be
        * 0 to indicate the report is finished
        * pid of the report generating process

update running state of report

=cut
sub set_running {
    my($c, $nr, $val, $start, $end, $job) = @_;

    my $update = {};
    if(defined $val) {
        my $index_file = $c->config->{'var_path'}.'/reports/.index';
        $update->{'var'}->{'is_running'} = $val;
        if($val == 0) {
            Thruk::Utils::IO::json_lock_patch($index_file, { $nr => undef }, { pretty => 1, allow_empty => 1 });
        } else {
            $update->{'var'}->{'running_node'} = $Thruk::Globals::NODE_ID;
            Thruk::Utils::IO::json_lock_patch($index_file, { $nr => {
                                        is_running   => $val,
                                        running_node => $Thruk::Globals::NODE_ID,
                                        is_waiting   => undef,
                                    }}, { pretty => 1, allow_empty => 1 });
        }
    }
    $update->{'var'}->{'start_time'} = $start if defined $start;
    $update->{'var'}->{'end_time'}   = $end   if defined $end;
    $update->{'var'}->{'is_waiting'} = undef  if defined $val;
    $update->{'var'}->{'job'}        = $ENV{'THRUK_JOB_ID'} if defined $ENV{'THRUK_JOB_ID'};
    $update->{'var'}->{'job'}        = $job   if defined $job;
    $update->{'var'}->{'attachment'} = $Thruk::Utils::PDF::attachment if $Thruk::Utils::PDF::attachment;
    $update->{'var'}->{'ctype'}      = $Thruk::Utils::PDF::ctype      if $Thruk::Utils::PDF::ctype;

    my $report_file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    Thruk::Utils::IO::json_lock_patch($report_file, $update, { pretty => 1 });
    return;
}

##########################################################

=head2 set_waiting

  set_waiting($c, $nr, $with_mails)

set waiting status of job

=cut
sub set_waiting {
    my($c, $nr, $waiting, $with_mails) = @_;
    my $index_file = $c->config->{'var_path'}.'/reports/.index';

    my $update = {};
    $update->{'var'}->{'is_waiting'} = ($waiting || undef);
    Thruk::Utils::IO::json_lock_patch($index_file, { $nr => { is_waiting => ($waiting||undef) }}, { pretty => 1, allow_empty => 1 }) if defined $waiting;
    if(defined $with_mails) {
        $update->{'var'}->{'send_mails_next_time'} = $with_mails ? 1 : undef;
    }
    my $report_file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    Thruk::Utils::IO::json_lock_patch($report_file, $update, { pretty => 1 });
    return;
}

##########################################################

=head2 clean_report_tmp_files

  clean_report_tmp_files($c, $nr)

remove any tmp files from this report

=cut
sub clean_report_tmp_files {
    my($c, $nr) = @_;
    unlink $c->config->{'var_path'}.'/reports/'.$nr.'.dat';
    unlink $c->config->{'var_path'}.'/reports/'.$nr.'.log';
    unlink $c->config->{'var_path'}.'/reports/'.$nr.'.html';
    unlink $c->config->{'var_path'}.'/reports/'.$nr.'.dbg';
    return;
}

##########################################################

=head2 get_report_templates

  get_report_templates($c)

return available report templates

=cut
sub get_report_templates {
    my($c) = @_;
    $c->stats->profile(begin => "Utils::Reports::get_report_templates()");
    my $templates = {};
    for my $path (@{$c->get_tt_template_paths()}) {
        for my $file (glob($path.'/reports/*.tt')) {
            my $name;
            my $path = $file;
            ($file, $name) = _get_report_tt_name($file);
            my $deprecated = Thruk::Utils::get_template_variable($c, 'reports/'.$file, 'deprecated', { block => 'edit' }, 1);
            $templates->{$file} = {
                file        => $file,
                name        => $name,
                path        => $path,
                deprecated  => $deprecated || 0,
            };
        }
    }
    $c->stats->profile(end => "Utils::Reports::get_report_templates()");
    return($templates);
}

##########################################################
sub _get_report_tt_name {
    my($file) = @_;
    $file =~ s/^.*\/(.*)$/$1/mx;
    my $name = $file;
    $name    =~ s/\.tt$//gmx;
    $name    = join(' ', map(ucfirst, split(/_/mx, $name)));
    $name    =~ s/Sla/SLA/gmx;
    return($file, $name);
}

##########################################################

=head2 get_report_languages

  get_report_languages($c)

return available report languages

=cut
sub get_report_languages {
    my($c) = @_;
    my $languages = {};
    for my $path (@{$c->get_tt_template_paths()}) {
        for my $file (glob($path.'/reports/locale/*.tt')) {
            $file    =~ s/^.*\/(.*)$/$1/mx;
            next if $file =~ m/_custom\.tt/mx;
            my $name = _get_locale_name($c, $file) || 'unknown';
            my $abrv = $file;
            $abrv    =~ s/\.tt$//gmx;
            $languages->{$name} = {
                file => $file,
                name => $name,
                abrv => $abrv,
            };
        }
    }
    return($languages);
}

##########################################################

=head2 add_report_defaults

  add_report_defaults($c, [$fields], $report)

add report defaults

=cut
sub add_report_defaults {
    my($c, $fields, $report) = @_;
    $fields = _get_required_fields($c, $report) unless defined $fields;
    for my $f (@{$fields}) {
        $f = normalize_required_field($c, $f);
        my $key = $f->{'name'};
        # fill in default
        if($f->{'required'} && $f->{'default'} ne '' && (!defined $report->{'params'}->{$key} || $report->{'params'}->{$key} =~ /^\s*$/mx)) {
            $report->{'params'}->{$key} = $f->{'default'};
        }

        # unavailable states may be empty when switching from hosts to services templates
        if($f->{'type'} eq 'hst_unavailable' or $f->{'type'} eq 'svc_unavailable') {
            my %default = map {$_ => 1} @{$f->{'default'}};
            $report->{'params'}->{$key} = [$report->{'params'}->{$key}] unless ref $report->{'params'}->{$key} eq 'ARRAY';
            my @used    = grep {$default{$_}} @{$report->{'params'}->{$key}};
            if(scalar @used == 0) {
                push @{$report->{'params'}->{$key}}, @{$f->{'default'}};
            }
        }
    }
    return;
}

##########################################################

=head2 get_running_reports_number

  get_running_reports_number($c)

returns list ($running, $waiting)

=cut
sub get_running_reports_number {
    my($c) = @_;
    my $index_file = $c->config->{'var_path'}.'/reports/.index';
    return(0,0) unless -s $index_file;
    my $index   = Thruk::Utils::IO::json_lock_retrieve($index_file);
    my $running = 0;
    my $waiting = 0;
    for my $nr (keys %{$index}) {
        if($index->{$nr}->{'is_waiting'}) {
            $waiting++;
        } elsif(($index->{$nr}->{'is_running'}//0) != 0 && ($index->{$nr}->{'running_node'}//'') eq $Thruk::Globals::NODE_ID) {
            $running++;
        }
    }
    return($running, $waiting);
}

##########################################################
sub _get_locale_name {
    my($c, $template) = @_;
    return Thruk::Utils::get_template_variable($c, 'reports/locale/'.$template, 'locale_name');
}

##########################################################

=head2 get_new_report

  get_new_report($c, [$data])

returns default report data

=cut
sub get_new_report {
    my($c, $data) = @_;
    $data = {} unless defined $data;
    my $r = {
        'name'            => 'New Report',
        'desc'            => 'Description',
        'nr'              => 'new',
        'template'        => '',
        'params'          => {},
        'var'             => {},
        'to'              => '',
        'cc'              => '',
        'is_public'       => 0,
        'user'            => $c->stash->{'remote_user'},
        'permissions'     => [],
        'backends'        => [],
        'send_types'      => [],
        'failed_backends' => 'cancel',
    };
    for my $key (keys %{$data}) {
        $r->{$key} = $data->{$key};
    }
    return $r;
}

##########################################################

=head2 store_report_data

  store_report_data($c, $nr, $data)

writes report to disk

=cut
sub store_report_data {
    my($c, $nr, $r) = @_;
    my $report = Thruk::Utils::IO::dclone($r);
    Thruk::Utils::IO::mkdir($c->config->{'var_path'}.'/reports/');
    my $file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    if($nr eq 'new') {
        # find next free number
        $nr = 1;
        $file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
        while(-e $file) {
            $nr++;
            $file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
        }
    }
    delete $report->{'readonly'};
    delete $report->{'nr'};
    delete $report->{'error'};
    delete $report->{'long_error'};
    delete $report->{'failed'};

    if($report->{'template'} !~ m/^[0-9a-zA-Z]+[\w]*\.tt$/mx) {
        return;
    }

    # save backends as hash with name
    $report->{'backends'} = Thruk::Utils::backends_list_to_hash($c, ($report->{'backends_hash'} || $report->{'backends'}));
    delete $report->{'backends_hash'};

    # sanity checks
    if(!$report->{'user'}) {
        confess("tried to save report without user");
    }
    if($report->{'desc'} eq 'Description' && $report->{'name'} eq 'New Report' && !$report->{'params'}->{'timeperiod'} && $report->{'template'} eq 'sla_report.tt') {
        confess("tried to save empty report");
    }

    if($report->{'params'}->{'timeperiod'} && $report->{'params'}->{'timeperiod'} ne 'custom') {
        delete $report->{'params'}->{'t1'};
        delete $report->{'params'}->{'t2'};
    }

    Thruk::Utils::IO::json_store($file, $report, { pretty => 1 });

    $report->{'backends_hash'} = $report->{'backends'};

    $report->{'nr'} = $nr;
    return $report;
}

##########################################################

=head2 read_report_file

  read_report_file($c, $nr, [$rdata, $noauth, $simple])

returns report

=cut
sub read_report_file {
    my($c, $nr, $rdata, $noauth, $simple) = @_;

    my $index_file = $c->config->{'var_path'}.'/reports/.index';
    if(!defined $nr || $nr !~ m/^\d+$/mx) {
        _error("not a valid report number");
        $c->stash->{errorMessage}       = "report does not exist";
        $c->stash->{errorDescription}   = "not a valid report number.";
        return $c->detach('/error/index/99');
    }
    my $file = $c->config->{'var_path'}.'/reports/'.$nr.'.rpt';
    unless(-f $file) {
        _error("report does not exist: $!\n");
        $c->stash->{errorMessage}       = "report does not exist";
        $c->stash->{errorDescription}   = "please make sure this report exists.";
        return $c->detach('/error/index/99');
    }

    my($report_fh, $lock_fh) = Thruk::Utils::IO::file_lock($file);
    my $report = Thruk::Utils::IO::json_retrieve($file, $report_fh);
    $report->{'nr'} = $nr;
    $report = get_new_report($c, $report);

    my $log        = $c->config->{'var_path'}.'/reports/'.$nr.'.log';
    my $needs_save = 0;
    my $available_templates = $c->stash->{'available_templates'} || get_report_templates($c);
    if(!$report->{'template'}) {
        $report->{'template'} = $c->req->parameters->{'template'} || $c->config->{'Thruk::Plugin::Reports2'}->{'default_template'} || 'sla_report.tt';
        $needs_save = 1;
        Thruk::Utils::set_message( $c, 'fail_message', 'No Report Template set in \''.$report->{'name'}.'\', using default: \''.$available_templates->{$report->{'template'}}->{'name'}.'\'' );
    }
    $c->stash->{'available_templates'} = $available_templates;

    # add defaults
    add_report_defaults($c, undef, $report) unless $simple;
    $report->{'failed_backends'} = 'cancel' unless $report->{'failed_backends'};

    unless($noauth) {
        $report->{'readonly'}   = 1;
        my $authorized = _is_authorized_for_report($c, $report);
        Thruk::Utils::IO::file_unlock($file, $report_fh, $lock_fh);
        return unless $authorized;
        $report->{'readonly'}   = 0 if $authorized == 1;
    }

    # migrate some options
    if($report->{'params'}) {
        if(defined $report->{'params'}->{'max_outages_pages'} && $report->{'params'}->{'max_outages_pages'} eq "0") { $report->{'params'}->{'max_outages_pages'} = "-1"; }
        if(defined $report->{'params'}->{'max_worst_pages'}   && $report->{'params'}->{'max_worst_pages'}   eq "0") { $report->{'params'}->{'max_worst_pages'}   = "-1"; }
        if(defined $report->{'params'}->{'max_outages_pages'} && $report->{'params'}->{'max_outages_pages'} eq "0") { $report->{'params'}->{'max_outages_pages'} = "-1"; }
    }

    # add some runtime information
    my $rfile = $c->config->{'var_path'}.'/reports/'.$nr.'.dat';
    $report->{'var'}->{'file_exists'} = 0;
    $report->{'var'}->{'file_exists'} = 1  if -f $rfile;
    $report->{'var'}->{'is_running'}  = 0  unless defined $report->{'var'}->{'is_running'};
    $report->{'var'}->{'start_time'}  = 0  unless defined $report->{'var'}->{'start_time'};
    $report->{'var'}->{'end_time'}    = 0  unless defined $report->{'var'}->{'end_time'};
    $report->{'var'}->{'ctype'}       = '' unless defined $report->{'var'}->{'ctype'};
    $report->{'var'}->{'attachment'}  = '' unless defined $report->{'var'}->{'attachment'};
    $report->{'desc'}       = '' unless defined $report->{'desc'};
    $report->{'to'}         = '' unless defined $report->{'to'};
    $report->{'cc'}         = '' unless defined $report->{'cc'};
    $report->{'permissions'} = [] unless defined $report->{'permissions'};
    if($report->{'is_public'}) {
        unshift @{$report->{'permissions'}}, {
            'type' => 'user',
            'name' => ['*'],
            'perm' => 'ro',
        };
    }
    # set is_public flag for backwards compatibility
    PERM: for my $p (@{$report->{'permissions'}}) {
        for my $n (@{$p->{'name'}}) {
            if($n eq '*') {
                $report->{'is_public'} = 1;
                last PERM;
            }
        }
    }
    $report->{'is_public'} = 0 unless defined $report->{'is_public'};

    # make permissions uniq
    my $uniq_perm = {};
    my $new_perm  = [];
    for my $p (@{$report->{'permissions'}}) {
        my $u = sprintf("%s;%s;%s", $p->{'type'}, $p->{'perm'}, join('|', @{$p->{'name'}}));
        if(!defined $uniq_perm->{$u}) {
            $uniq_perm->{$u} = $p;
            push @{$new_perm}, $p;
        }
    }
    $report->{'permissions'} = $new_perm;

    # check if its really running
    if($report->{'var'}->{'is_running'} == -1 && $report->{'var'}->{'start_time'} < time() - 10) {
        $report->{'var'}->{'is_running'} = 0;
        Thruk::Utils::IO::json_lock_patch($index_file, { $nr => undef }, { pretty => 1, allow_empty => 1 });
        $needs_save = 1;
    }
    if($report->{'var'}->{'is_running'} > 0 && $c->cluster->kill($c, $report->{'var'}->{'running_node'}, 0, $report->{'var'}->{'is_running'}) != 1) {
        $report->{'var'}->{'is_running'} = 0;
        Thruk::Utils::IO::json_lock_patch($index_file, { $nr => undef }, { pretty => 1, allow_empty => 1 });
        $needs_save = 1;
    }
    if($ENV{'THRUK_REPORT_PARENT'} && $report->{'var'}->{'is_running'} == $ENV{'THRUK_REPORT_PARENT'}) {
        $report->{'var'}->{'is_running'} = $$;
        $report->{'var'}->{'running_node'} = $Thruk::Globals::NODE_ID;
        Thruk::Utils::IO::json_lock_patch($index_file, { $nr => { is_running => $$, running_node => $Thruk::Globals::NODE_ID, is_waiting => undef }}, { pretty => 1, allow_empty => 1 });
        $needs_save = 1;
    }
    if($report->{'var'}->{'end_time'} < $report->{'var'}->{'start_time'}) {
        $report->{'var'}->{'end_time'} = $report->{'var'}->{'start_time'};
        $needs_save = 1;
    }

    if(!$report->{'var'}->{'is_running'} && $report->{'var'}->{'job'} && !Thruk::Utils::External::is_running($c, $report->{'var'}->{'job'}, 1)) {
        my $jobid = delete $report->{'var'}->{'job'};
        my($out,$err,$time, $dir,$stash,$rc,$profile) = Thruk::Utils::External::get_result($c, $jobid, 1);
        if($err && $err !~ m/\Qno such job:\E/mx) {
            # append job error to report logfile
            Thruk::Utils::IO::write($log, $err, undef, 1);
        }
        $report->{'var'}->{'profile'} = $profile;
        $needs_save = 1;
    }
    if($report->{'var'}->{'debug_file'} && !-e $report->{'var'}->{'debug_file'}) {
        delete $report->{'var'}->{'debug_file'};
        $needs_save = 1;
    }
    if($report->{'var'}->{'json_file'} && !-e $report->{'var'}->{'json_file'}) {
        delete $report->{'var'}->{'json_file'};
        $needs_save = 1;
    }

    # failed?
    $report->{'failed'} = 0;
    if(-s $log) {
        $report->{'error'} = Thruk::Utils::IO::read($log);

        # strip performance debug output
        $report->{'error'}  =~ s%^\[.*INFO.*Req:.*$%%gmx;
        if($report->{'error'} =~ m%\S+%mx) {
            $report->{'failed'} = 1;
            $report->{'var'}->{'is_running'} = 0;
            Thruk::Utils::IO::json_lock_patch($index_file, { $nr => undef }, { pretty => 1, allow_empty => 1 });
        }

        # nice error message
        if($report->{'error'} =~ m/\[ERROR\]\s+(.*?)\s+at\s+[\w\/\.\-]+\.pm\s+line\s+\d+\./gmx) {
            $report->{'long_error'} = $report->{'error'};
            $report->{'error'} = $1;
            $report->{'error'} =~ s/^'//mx;
            $report->{'error'} =~ s/\\'/'/gmx;
        }
        elsif($report->{'error'} =~ m/\[ERROR\]\s+(internal\s+server\s+error)/gmx) {
            $report->{'long_error'} = $report->{'error'};
            $report->{'error'} = $1;
        }
        $report->{'error'} =~ s/^\Qundef error - \E//mx;
        if(!$report->{'long_error'} && $report->{'error'} =~ m/\n/mx) {
            ($report->{'error'}, $report->{'long_error'}) = split(/\n/mx, $report->{'error'}, 2);
        }
    }

    if($report->{'template'} && !defined $available_templates->{$report->{'template'}}) {
        my $err = sprintf("report template '%s' not available\n", $report->{'template'});
        if(!$report->{'error'} || $report->{'error'} ne $err) {
            $report->{'failed'} = 1;
            $report->{'error'}  = $err;
        }
    }

    # preset values from data
    if(defined $rdata) {
        for my $key (keys %{$rdata}) {
            $report->{$key} = $rdata->{$key};
        }
    }

    store_report_data($c, $nr, $report) if $needs_save;

    $report->{'backends_hash'} = $report->{'backends'};
    $report->{'backends'}      = Thruk::Utils::backends_hash_to_list($c, $report->{'backends'});

    Thruk::Utils::IO::file_unlock($file, $report_fh, $lock_fh);
    return $report;
}

##########################################################
# returns:
#     undef    no access
#     1        private report, readwrite access
#     2        public report, readonly access
sub _is_authorized_for_report {
    my($c, $report) = @_;

    # super user have permission for all reports
    if($c->check_user_roles('admin')) {
        return 1;
    }

    return 1 if Thruk::Base->mode eq 'CLI';

    if(defined $c->stash->{'remote_user'}) {
        if(defined $report->{'user'} && $report->{'user'} eq $c->stash->{'remote_user'}) {
            return 1;
        }

        my $perm;
        for my $p (@{$report->{'permissions'}}) {
            if($p->{'type'} eq 'user') {
                for my $n (@{$p->{'name'}}) {
                    if($n eq '*' || $c->stash->{'remote_user'} eq $n) {
                        if($p->{'perm'} eq 'rw') {
                            return(1);
                        }
                        if($p->{'perm'} eq 'ro') {
                            $perm = 2;
                        }
                    }
                }
            }
            if($p->{'type'} eq 'group') {
                for my $n (@{$p->{'name'}}) {
                    if($n eq '*' || $c->user->has_group($n)) {
                        if($p->{'perm'} eq 'rw') {
                            return(1);
                        }
                        if($p->{'perm'} eq 'ro') {
                            $perm = 2;
                        }
                    }
                }
            }
        }
        return($perm) if $perm;
    }

    if(defined $report->{'is_public'} and $report->{'is_public'} == 1) {
        return 2;
    }
    _debug("user: ".(defined $c->stash->{'remote_user'} ? $c->stash->{'remote_user'} : '?')." is not authorized for report: ".$report->{'nr'});
    return;
}

##########################################################
sub _get_report_cmd {
    my($c, $numbers) = @_;
    Thruk::Utils::IO::mkdir($c->config->{'var_path'}.'/reports/');
    my $thruk_bin = $c->config->{'thruk_bin'};
    my $nice      = '/usr/bin/nice';
    my $niceval   = $c->config->{'Thruk::Plugin::Reports2'}->{'report_nice_level'} || $c->config->{'report_nice_level'} || 5;
    if(-e '/bin/nice') { $nice = '/bin/nice'; }
    if($niceval > 0) {
        $thruk_bin = $nice.' -n '.$niceval.' '.$thruk_bin;
    }
    $numbers = Thruk::Base::list($numbers);
    my $cmd = sprintf("cd %s && %s '%s report \"%s\"' >/dev/null 2>%s/reports/%d.log",
                            $c->config->{'project_root'},
                            $c->config->{'thruk_shell'},
                            $thruk_bin,
                            join('|', @{$numbers}),
                            $c->config->{'var_path'},
                            $numbers->[0],
                    );
    return $cmd;
}

##########################################################
sub _get_required_fields {
    my($c, $report) = @_;
    return unless $report->{'template'};
    my $fields = Thruk::Utils::get_template_variable($c, 'reports/'.$report->{'template'}, 'required_fields', { block => 'edit' }, 1);
    return unless(defined $fields && ref $fields eq 'ARRAY');
    # normalize fields
    for my $f (@{$fields}) {
        normalize_required_field($c, $f);
    }
    return $fields;
}

##########################################################

=head2 normalize_required_field

  normalize_required_field($c, $field)

returns normalized field structure, convert old array list into hash structure

=cut
sub normalize_required_field {
    my($c, $f) = @_;
    if(ref $f eq 'HASH' && $f->{'type'}) {
        # already normalized hash form
        if($f->{'childs'}) {
            for my $child (@{$f->{'childs'}}) {
                normalize_required_field($c, $child);
            }
        }
        _set_required_field_defaults($f);
        return($f);
    }
    if(ref $f eq 'HASH' && scalar keys %{$f} == 1) {
        my $name = (keys %{$f})[0];
        confess("no name in required field: ".Dumper($f)) unless $name;
        my($desc, $type, $default, $details, $required, $extra) = @{$f->{$name}};
        confess("no type in required field: ".Dumper($f)) unless $type;
        $f = {
            name     => $name,
            type     => $type,
            desc     => $desc,
            details  => $details,
            default  => $default,
            required => $required,
            extra    => $extra,
        };
        _set_required_field_defaults($f);

        # remove report themes from required_fields if there is none to select
        $c->stash->{'report_themes'} = get_report_themes($c) unless $c->stash->{'report_themes'};
        if($type eq 'report_theme' && scalar @{$c->stash->{'report_themes'}} <= 0) {
            $f->{'hidden'} = 1;
        }

        return($f);
    }
    confess("unknown form of required field: ".Dumper($f));
}

##########################################################
sub _set_required_field_defaults {
    my($f) = @_;
    $f->{'desc'}      = $f->{'desc'}      // '';
    $f->{'details'}   = $f->{'details'}   // '';
    $f->{'required'}  = $f->{'required'}  // 0;
    $f->{'default'}   = $f->{'default'}   // ($f->{'type'} eq 'formlist' ? {} : '');
    $f->{'extra'}     = $f->{'extra'}     // '';
    $f->{'multiple'}  = $f->{'multiple'}  // 0;
    $f->{'draggable'} = $f->{'draggable'} // 0;

    $f->{'default'}  = [$f->{'default'}] if($f->{'multiple'} && ref $f->{'default'} ne 'ARRAY');
    return;
}

##########################################################
sub _verify_fields {
    my($c, $fields, $report) = @_;
    return unless defined $fields;
    return unless ref $fields eq 'ARRAY';
    delete $report->{'var'}->{'opt_errors'};
    my @errors;

    # add defaults first
    add_report_defaults($c, $fields, $report);

    for my $d (@{$fields}) {
        my $f = normalize_required_field($c, $d);
        my $key = $f->{'name'};

        # required fields
        if($f->{'required'} && $f->{'default'} eq '' && (!defined $report->{'params'}->{$key} || $report->{'params'}->{$key} =~ m/^\s*$/mx)) {
            push @errors, $f->{'desc'}.': required field';
        }

        # regular expressions
        if($f->{'type'} eq 'pattern' && !Thruk::Utils::is_valid_regular_expression($c, $report->{'params'}->{$key})) {
            push @errors, $f->{'desc'}.': invalid regular expression';
        }
    }
    if(scalar @errors > 0) {
        Thruk::Utils::set_message( $c, 'fail_message', 'Found errors in report options:', \@errors );
        $report->{'var'}->{'opt_errors'} = \@errors;
    }
    return;
}

##########################################################
sub _convert_to_pdf {
    my($c, $reportdata, $attachment, $nr, $logfile, $is_report) = @_;
    $c->stats->profile(begin => "_convert_to_pdf()");

    my $htmlfile = $c->config->{'var_path'}.'/reports/'.$nr.'.html';

    my $htmlonly = 0;

    # skip pdf creator for ondemand html preview
    if($c->req->parameters->{'html'} and $c->req->parameters->{'refreshreport'}) {
        $htmlonly = 1;
    }

    unless($htmlonly) {
        $c->stash->{'param'}->{'js'} = 1;
        $reportdata = Thruk::Utils::Reports::Render::replace_css_and_images($reportdata);
    }

    # write out result
    open(my $fh, '>', $htmlfile);
    binmode $fh;
    print $fh $reportdata;
    Thruk::Utils::IO::close($fh, $htmlfile);

    if($htmlonly) {
        Thruk::Utils::IO::touch($attachment);
        $c->stats->profile(end => "_convert_to_pdf()");
        return;
    }

    my $cmd = $c->config->{home}.'/script/html2pdf.sh "file://'.abs_path($htmlfile).'" "'.$attachment.'.pdf" "'.$logfile.'" "'.($is_report//0).'"';
    _debug("converting to pdf: ".$cmd);
    my($rc, $out) = Thruk::Utils::IO::cmd($cmd.' 2>&1');

    if(!-e $attachment.'.pdf') {
        my $error = Thruk::Utils::IO::read($logfile);
        if($error eq "") { $error = $out; }
        if($error =~ m/internal\/modules\/cjs\/loader\.js/mx) {
            $error =~ s/^.*?internal\/modules\/cjs\/loader(\.js:\d+|:\d*)\s*throw\s*err;\s*\^\s*Error:/Node Error:/sgmx; # remove useless info from node errors
            Thruk::Utils::IO::write($logfile, $error);
        } else {
            Thruk::Utils::IO::write($logfile, $error, undef, 1) unless -s $logfile;
        }
        die('report failed: '.$error);
    }

    move($attachment.'.pdf', $attachment) or die('move '.$attachment.'.pdf to '.$attachment.' failed: '.$!);
    Thruk::Utils::IO::ensure_permissions('file', $attachment);

    $c->stats->profile(end => "_convert_to_pdf()");
    return;
}

##########################################################
sub _initialize_report_templates {
    my($c, $options) = @_;

    # add default params
    add_report_defaults($c, undef, $options);

    $c->stash->{'param'}              = $options->{'params'};
    $c->stash->{'r'}                  = $options;
    $c->stash->{'show_empty_outages'} = 1;
    $c->stash->{'report_themes'}      = get_report_themes($c) unless $c->stash->{'report_themes'};
    apply_report_parameters($c, $c->req->parameters, $options->{'params'});

    # set some render helper
    for my $s (@{Thruk::Config::get_functions_for_class('Thruk::Utils::Reports::Render')}) {
        $c->stash->{$s} = \&{'Thruk::Utils::Reports::Render::'.$s};
    }
    # set custom render helper
    my $custom = [];
    eval {
        require Thruk::Utils::Reports::CustomRender;
        Thruk::Utils::Reports::CustomRender->import;
        $custom = Thruk::Config::get_functions_for_class('Thruk::Utils::Reports::CustomRender');
    };
    # show errors if module was found
    if($@ and $@ !~ m|Can\'t\ locate\ Thruk/Utils/Reports/CustomRender\.pm\ in|mx) {
        $Thruk::Utils::Reports::error = $@;
        _error($@);
    }
    for my $s (@{$custom}) {
        $c->stash->{$s} = \&{'Thruk::Utils::Reports::CustomRender::'.$s};
    }

    # initialize localization
    if($options->{'params'}->{'language'}) {
        $c->stash->{'loc'} = $c->stash->{'_locale'};
        $Thruk::Utils::Reports::Render::locale = Thruk::Utils::get_template_variable($c, 'reports/locale/'.$options->{'params'}->{'language'}.'.tt', 'translations');
        my $overrides = {};
        for my $path (@{$c->get_tt_template_paths()}) {
            if(-e $path.'/reports/locale/'.$options->{'params'}->{'language'}.'_custom.tt') {
                $overrides = Thruk::Utils::get_template_variable($c, 'reports/locale/'.$options->{'params'}->{'language'}.'_custom.tt', 'translations_overrides');
                last;
            }
        }
        if($overrides) {
            for my $key (keys %{$overrides}) {
                $Thruk::Utils::Reports::Render::locale->{$key} = $overrides->{$key};
            }
        }
    }

    return;
}

##########################################################

=head2 check_for_waiting_reports

  check_for_waiting_reports($c)

works on next queued report

returns nothing

=cut
sub check_for_waiting_reports {
    my($c) = @_;
    my $index_file = $c->config->{'var_path'}.'/reports/.index';
    return unless -s $index_file;
    my $index   = Thruk::Utils::IO::json_lock_retrieve($index_file);
    for my $nr (keys %{$index}) {
        if($index->{$nr}->{'is_waiting'}) {
            generate_report_background($c, $nr, undef, undef, 1);
            return;
        }
    }
    return;
}

##########################################################
sub _report_die {
    my($c, $nr, $err, $logfile) = @_;

    # redirect from $c->detach_error
    if($c->stash->{'error_data'} && $c->{'detached'}) {
        $err  = ($c->stash->{'raw_error_data'}->{'msg'}   // $c->stash->{'error_data'}->{'msg'})."\n";
        $err .= ($c->stash->{'raw_error_data'}->{'descr'} // $c->stash->{'error_data'}->{'descr'})."\n" if $c->stash->{'error_data'}->{'descr'};
    }

    _debug("stack:");
    _debug(Carp::longmess("report failed"));
    _error($err);
    Thruk::Utils::IO::write($logfile, $err, undef, 1);
    $Thruk::Utils::Reports::error = $err;
    set_running($c, $nr, 0, undef, time()) if $nr;
    check_for_waiting_reports($c);
    if($ENV{'THRUK_CRON'} || (Thruk::Base->mode eq 'CLI')) {
        return;
    }

    return $c->detach('/error/index/13');
}

##########################################################

=head2 apply_report_parameters

  apply_report_parameters($c, $to, $from)

set report parameters into target hash

returns target hash

=cut
sub apply_report_parameters {
    my($c, $to, $from) = @_;

    for my $p (keys %{$from}) {
        if($p eq 'filter') {
            my($hostfilter, $servicefilter) = Thruk::Utils::Status::do_filter($c, undef, $from->{$p}, 1);
            if($from->{'filter_type'} eq 'Both') {
                $to->{'s_filter'} = $servicefilter;
                $to->{'include_host_services'} = 1;
            }
            elsif($from->{'filter_type'} eq 'Services') {
                $to->{'s_filter'} = $servicefilter;
            }
            elsif($from->{'filter_type'} eq 'Hosts') {
                $to->{'h_filter'} = $hostfilter;
            }
        } else {
            $to->{$p} = $from->{$p};
        }
    }

    return($to);
}

##########################################################

=head2 get_report_themes

  get_report_themes($c)

returns list of themes which have a 'stylesheets/*reports.css' file.

=cut
sub get_report_themes {
    my($c) = @_;

    my $report_themes = [];
    for my $dir (sort glob($c->config->{'themes_dir'})) {
        my @files = glob($dir.'/stylesheets/*reports.css');
        next if scalar @files == 0;
        my $name = $dir;
        $name =~ s/\/$//gmx;
        $name =~ s/^.*\///gmx;
        for my $f (@files) {
            $f =~ s|^$dir/?||gmx;
        }
        push @{$report_themes}, {
            path         => $dir,
            name         => $name,
            reportstyles => \@files,
        };
    }
    return($report_themes);
}

##########################################################
# replaces {{...}} macros in report
sub _replace_report_macros {
    my($c, $value) = @_;

    $value =~ s/(\{\{)
                (.*?)
                (\}\})
               /&_replace_report_macro($c, $1,$2,$3)/gemxis;

    return($value);
}

##########################################################
sub _replace_report_macro {
    my($c, $pre,$macro,$post) = @_;

    my $r = $c->stash->{'r'};
    if($macro =~ m/^\s*(\w+)\s*:\s*(.*)\s*$/gmx) {
        my($name, $args) = ($1, $2);
        if($name eq 'date') {
            my @args = split(/\s*,\s*/mx, $args);
            my($type, $format) = @args;
            $type   = 'now' unless $type;
            $format = '%d %b %Y, %H:M:%S' unless $format;
            my $ts;
            if($type eq 'now') {
                $ts = time();
            } elsif($type eq 'start') {
                $ts = $c->stash->{'start'}; # set in Avail.pm
            } elsif($type eq 'end') {
                $ts = $c->stash->{'end'};
            } else {
                return("unsupported date type, choose from: start, end, now");
            }
            $format =~ s/^"(.*)"$/$1/gmx;
            $format =~ s/^'(.*)'$/$1/gmx;
            return(POSIX::strftime($format, localtime($ts)));
        } else {
            return("unsupported macro");
        }
    } else {
        return("invalid macro syntax");
    }

    return($macro);
}

##########################################################

1;
