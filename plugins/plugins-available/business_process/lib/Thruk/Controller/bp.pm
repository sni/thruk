package Thruk::Controller::bp;

use warnings;
use strict;

use Thruk::Action::AddDefaults ();
use Thruk::BP::Components::BP ();
use Thruk::BP::Components::Node ();
use Thruk::Utils::Auth ();
use Thruk::Utils::Status ();

=head1 NAME

Thruk::Controller::bp - Thruk Controller

=head1 DESCRIPTION

Thruk Controller.

=head1 METHODS

=cut

##########################################################

=head2 index

=cut
sub index {
    my ( $c ) = @_;

    return unless Thruk::Action::AddDefaults::add_defaults($c, Thruk::Constants::ADD_CACHED_DEFAULTS);

    if(!$c->config->{'bp_modules_loaded'}) {
        require Data::Dumper;
        require Thruk::BP::Utils;
        # loading Clone makes BPs with filters lot faster
        eval {
            require Clone;
        };
        $c->config->{'bp_modules_loaded'} = 1;
    }

    my $action = $c->req->parameters->{'action'} || 'show';
    my $style  = $c->req->parameters->{'style'};
    if($style && $action ne 'list_objects') {
        return if Thruk::Utils::Status::redirect_view($c, $style);
    }

    $c->stash->{'inject_stats'} = $c->req->parameters->{'minimal'} ? 0 : 1;

    $c->stash->{title}                 = 'Business Process';
    $c->stash->{page}                  = 'status';
    $c->stash->{template}              = 'bp.tt';
    $c->stash->{subtitle}              = 'Business Process';
    $c->stash->{infoBoxTitle}          = 'Business Process';
    $c->stash->{'plugin_name'}         = Thruk::Utils::get_plugin_name(__FILE__, __PACKAGE__);
    $c->stash->{'has_jquery_ui'}       = 1;
    $c->stash->{'disable_backspace'}   = 1;
    $c->stash->{editmode}              = 0;
    $c->stash->{testmode}              = $c->req->parameters->{'testmode'} || 0;
    $c->stash->{debug}                 = $c->req->parameters->{'debug'} || 0;
    $c->stash->{highlight_node}        = $c->req->parameters->{'node'} || '';
    $c->stash->{testmodes}             = {};
    $c->stash->{'objects_templates_file'} = $c->config->{'Thruk::Plugin::BP'}->{'objects_templates_file'} || '';
    $c->stash->{'objects_save_file'}      = $c->config->{'Thruk::Plugin::BP'}->{'objects_save_file'}      || '';
    $c->stash->{'read_only'}           = $c->config->{'Thruk::Plugin::BP'}->{'read_only'} // 0;
    my $format = $c->config->{'Thruk::Plugin::BP'}->{'objects_save_format'} || 'nagios';
    if($format ne 'icinga2') { $format = 'nagios'; }
    $c->stash->{'objects_save_format'}  = $format;
    my $bp_backend_id;
    my $id = $c->req->parameters->{'bp'} || '';
    if($id =~ m/^([^:]+):(\d+)$/mx) { $bp_backend_id = $1; $id = $2; }
    if($id !~ m/^\d+$/mx and $id ne 'new') { $id = ''; }

    # backend id is only relevant if there are multiple backends (or one none-local connection)
    if(scalar @{$c->db->get_peers} == 1 && $c->db->get_peers->[0]->{'type'} eq 'livestatus') {
        $bp_backend_id = undef;
    }

    my $nodeid = $c->req->parameters->{'node'} || '';
    if($nodeid !~ m/^node\d+$/mx and $nodeid ne 'new') { $nodeid = ''; }

    $c->stash->{show_top_pane} = $id ? 0 : 1;
    $c->stash->{hidetop} = 1 if(!defined $c->stash->{hidetop} && $action ne 'show');

    Thruk::Utils::ssi_include($c);

    # check roles
    my $allowed_for_edit = 0;
    if( $c->check_user_roles( "authorized_for_business_processes")) {
        $allowed_for_edit = 1;
    }
    $c->stash->{allowed_for_edit} = $allowed_for_edit;
    $c->stash->{allowed_for_edit} = 0 if $c->req->parameters->{'readonly'};
    $c->stash->{allowed_for_edit} = 0 if $c->stash->{'read_only'};
    $c->stash->{no_menu}          = $c->req->parameters->{'no_menu'} ? 1 : 0;

    $c->stash->{fav_custom_fun} = $c->config->{'Thruk::Plugin::BP'}->{'favorite_custom_function'} ? [split(/\s*;\s*/mx, $c->config->{'Thruk::Plugin::BP'}->{'favorite_custom_function'})] : [];

    # json actions
    if($allowed_for_edit) {
        if($action eq 'templates') {
            my $host_templates    = [];
            my $service_templates = [];
            # simple / fast template grep
            if($c->stash->{'objects_templates_file'} and -e $c->stash->{'objects_templates_file'}) {
                my $lasttype;
                open(my $fh, '<', $c->stash->{'objects_templates_file'}) or die("failed to open ".$c->stash->{'objects_templates_file'}.": ".$!);
                while(my $line = <$fh>) {
                    if($line =~ m/^\s*template\s+(Service|Host)\s+"([^"]+)"\s*\{/mx) {
                        $lasttype = lc($1);
                        if($lasttype eq 'host') {
                            push @{$host_templates}, $2;
                        }
                        if($lasttype eq 'service') {
                            push @{$service_templates}, $2;
                        }
                        next;
                    }
                    if($line =~ m/^\s*define\s+(.*?)(\s|{)/mx) {
                        $lasttype = $1;
                    }
                    if($line =~ m/^\s*name\s+(.*?)\s*(;|$)+$/mx) {
                        if($lasttype eq 'host') {
                            push @{$host_templates}, $1;
                        }
                        if($lasttype eq 'service') {
                            push @{$service_templates}, $1;
                        }
                    }
                }
            }
            my $json = [ { 'name' => "host templates", 'data' => $host_templates }, { 'name' => "service templates", 'data' => $service_templates } ];
            return $c->render(json => $json);
        }
    }

    # read / write actions
    if($id and $allowed_for_edit and ($action ne 'details' and $action ne 'refresh')) {
        $c->stash->{editmode} = 1;
        my $bps = Thruk::BP::Utils::load_bp_data($c, { id => $id, edit => $c->stash->{editmode}, backend => $bp_backend_id });
        if(scalar @{$bps} == 0) {
            my $proxyurl = Thruk::Utils::proxifiy_me($c, $bp_backend_id);
            if($proxyurl) {
                $proxyurl =~ s/bp=[^:]*:/bp=/gmx;
                return $c->redirect_to($proxyurl);
            }
            if($c->config->{'Thruk::Plugin::BP'}->{'result_backend'}) {
                $proxyurl = Thruk::Utils::proxifiy_me($c, $c->config->{'Thruk::Plugin::BP'}->{'result_backend'});
                if($proxyurl) {
                    $proxyurl =~ s/bp=[^:]*:/bp=/gmx;
                    return $c->redirect_to($proxyurl);
                }
            }
            Thruk::Utils::set_message( $c, { style => 'fail_message', msg => 'no such business process or no permissions', code => 404 });
            return _bp_start_page($c);
        }
        my $bp = $bps->[0];
        $c->stash->{'bp'} = $bp;

        if($action eq 'commit') {
            if($c->config->{'demo_mode'}) {
                Thruk::Utils::set_message( $c, { style => 'fail_message', msg => 'save is disabled in demo mode.' });
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id);
            }
            return unless Thruk::Utils::check_csrf($c);
            $bp->commit($c);
            $bps = Thruk::BP::Utils::load_bp_data($c);
            my($rc,$msg) = Thruk::BP::Utils::save_bp_objects($c, $bps);
            if($rc != 0) {
                Thruk::Utils::set_message( $c, { style => 'fail_message', msg => "reload command failed\n$msg" });
                $bp->revert($c) && Thruk::BP::Utils::save_bp_objects($c, Thruk::BP::Utils::load_bp_data($c));
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id.'&edit=1');
            }

            # check if new objects really exits (wait up to 10seconds)
            my $success;
            for (1..10) {
                my $services = $c->db->get_services( filter => [ { 'host_name' => $bp->{'name'} } ], columns => [qw/description/] );
                if($services && scalar @{$services} > 0) {
                    $success = 1;
                    last;
                }
                sleep(1);
            }
            if(!$success) {
                Thruk::Utils::set_message( $c, { style => 'fail_message', msg => "reload command succeeded, but services are missing" });
                $bp->revert($c) && Thruk::BP::Utils::save_bp_objects($c, Thruk::BP::Utils::load_bp_data($c));
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id.'&edit=1');
            }

            Thruk::BP::Utils::update_cron_file($c); # check cronjob
            Thruk::Utils::set_message( $c, { style => 'success_message', msg => "business process updated sucessfully\n".$msg }) unless $rc != 0;
            $bp->commit_cleanup();
            my $bps = Thruk::BP::Utils::load_bp_data($c, { id => $id }); # load new process, otherwise we would update in edit mode
            $bps->[0]->update_status($c);

            return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id);
        }
        elsif($action eq 'revert') {
            return unless Thruk::Utils::check_csrf($c);
            unlink($bp->{'editfile'});
            unlink($bp->{'datafile'}.'.edit');
            Thruk::Utils::set_message( $c, { style => 'success_message', msg => 'changes canceled' });
            if(-e $bp->{'file'}) {
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id);
            } else {
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi");
            }
        }
        elsif($action eq 'remove') {
            return unless Thruk::Utils::check_csrf($c);
            $bp->remove($c);
            $bps = Thruk::BP::Utils::load_bp_data($c);
            my($rc,$msg) = Thruk::BP::Utils::save_bp_objects($c, $bps);
            if($rc != 0) {
                Thruk::Utils::set_message( $c, { style => 'fail_message', msg => "reload command failed\n".$msg });
            }
            Thruk::BP::Utils::update_cron_file($c); # check cronjob
            Thruk::Utils::set_message( $c, { style => 'success_message', msg => 'business process sucessfully removed' }) unless $rc != 0;
            return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi");
        }
        elsif($action eq 'clone') {
            my($new_file, $newid) = Thruk::BP::Utils::next_free_bp_file($c);
            my $label = Thruk::BP::Utils::make_uniq_label($c, 'Clone of '.$bp->{'name'});
            $bp->set_label($c, $label);
            $bp->get_node('node1')->{'label'} = $label;
            $bp->set_file($c, $new_file);
            $bp->save($c);
            Thruk::Utils::set_message( $c, { style => 'success_message', msg => 'business process sucessfully cloned' });
            return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&edit=1&bp=".$newid);
        }
        elsif($action eq 'rename_node' and $nodeid) {
            if(!$bp->{'nodes_by_id'}->{$nodeid}) {
                my $json = { rc => 1, 'message' => 'ERROR: no such node' };
                return $c->render(json => $json);
            }
            my $label = Thruk::BP::Utils::clean_nasty($c->req->parameters->{'label'} || 'none');
            # first node renames business process itself too
            if($nodeid eq 'node1' and $bp->get_node('node1')->{'label'} ne $label) {
                $label = Thruk::BP::Utils::make_uniq_label($c, $label, $bp->{'id'});
                $bp->set_label($c, $label);
            }
            $bp->{'nodes_by_id'}->{$nodeid}->{'label'} = $label;
            $bp->save($c);
            my $json = { rc => 0, 'message' => 'OK' };
            return $c->render(json => $json);
        }
        elsif($action eq 'remove_node' and $nodeid) {
            if(!$bp->{'nodes_by_id'}->{$nodeid}) {
                my $json = { rc => 1, 'message' => 'ERROR: no such node' };
                return $c->render(json => $json);
            }
            $bp->remove_node($nodeid);
            $bp->save($c);
            $bp->update_status($c, 1);
            my $json = { rc => 0, 'message' => 'OK' };
            return $c->render(json => $json);
        }
        elsif($action eq 'clone_node' and $nodeid) {
            my $node = $bp->get_node($nodeid); # node from the 'node' parameter
            if(!$node) {
                my $json = { rc => 1, 'message' => 'ERROR: no such node' };
                return $c->render(json => $json);
            }
            my $data  = $node->TO_JSON();
            $data->{'id'} = undef;
            my $clone = Thruk::BP::Components::Node->new($data);
            $bp->add_node($clone);
            for my $id (@{$node->{'parents'}}) {
                my $parent = $bp->get_node($id);
                $parent->append_child($clone);
            }
            $bp->save($c);
            $bp->update_status($c, 1);
            my $json = { rc => 0, 'message' => 'OK' };
            return $c->render(json => $json);
        }
        elsif($action eq 'edit_node' and $nodeid) {
            my $type = lc($c->req->parameters->{'bp_function'} || '');
            my $node = $bp->get_node($nodeid); # node from the 'node' parameter
            if(!$node) {
                my $json = { rc => 1, 'message' => 'ERROR: no such node' };
                return $c->render(json => $json);
            }

            my @arg;
            for my $x (1..10) {
                $arg[$x-1] = $c->req->parameters->{'bp_arg'.$x.'_'.$type} if defined $c->req->parameters->{'bp_arg'.$x.'_'.$type};
            }
            my $function_args = \@arg;
            if($type eq 'statusfilter') {
                my $filter          = Thruk::Utils::Status::get_search_from_param($c, 'dfl_s0', 1);
                $function_args->[2] = [$filter]; # make it a list, maybe we support multiple filter somewhere in the future
            }

            # check create first
            my $new = 0;
            if($c->req->parameters->{'bp_node_id'} eq 'new') {
                $new = 1;
                my $parent = $node;
                $node = Thruk::BP::Components::Node->new({
                                    'label'    => Thruk::BP::Utils::clean_nasty($c->req->parameters->{'bp_label_'.$type}),
                                    'function' => $type,
                                    'depends'  => [],
                });
                die('could not create node: '.Data::Dumper::Dumper($c->req->parameters)) unless $node;
                die('got no parent'.Data::Dumper::Dumper($c->req->parameters)) unless $parent;
                $bp->add_node($node);
                $parent->append_child($node);
            }

            # update children
            $node->{'depends'} = Thruk::Base::list($c->req->parameters->{'bp_'.$id.'_selected_nodes'} || []);

            # save object creating attributes
            for my $key (qw/host service template notification_period event_handler max_check_attempts/) {
                $node->{$key} = $c->req->parameters->{'bp_'.$key} || '';
            }
            # node array options
            for my $key (qw/contactgroups contacts/) {
                $node->{$key} = [split(/\s*,\s*/mx, $c->req->parameters->{'bp_'.$key} || '')];
            }
            $node->{'create_obj'} = $c->req->parameters->{'bp_create_link'} || 0;

            # save node filter
            $node->{'filter'} = [];
            $bp->{'filter'}   = [];
            for my $f (grep(/^bp_filter_/mx, keys %{$c->req->parameters})) {
                my $val = $c->req->parameters->{$f};
                $f =~ s/^bp_filter_//gmx;
                if($val eq 'on') {
                    push @{$node->{'filter'}}, $f;
                }
                if($val eq 'global') {
                    push @{$bp->{'filter'}}, $f;
                }
            }

            my $label = Thruk::BP::Utils::clean_nasty($c->req->parameters->{'bp_label_'.$type} || 'none');
            # first node renames business process itself too
            if(!$new && $nodeid eq 'node1') {
                if($bp->get_node('node1')->{'label'} ne $label) {
                    $label = Thruk::BP::Utils::make_uniq_label($c, $label, $bp->{'id'});
                    $bp->set_label($c, $label);
                }
                $bp->{'template'} = $c->req->parameters->{'bp_host_template'} || '';
            }
            $node->{'label'} = $label;

            $node->_set_function({'function' => $type, 'function_args' => $function_args});

            # bp options
            for my $key (qw/rankDir state_type/) {
                $bp->{$key} = $c->req->parameters->{'bp_'.$key} || '';
            }

            $bp->save($c);
            $bp->update_status($c, 1);
            my $json = { rc => 0, 'message' => 'OK' };
            return $c->render(json => $json);
        }
    }

    # new business process
    if($action eq 'new') {
        Thruk::BP::Utils::clean_orphaned_edit_files($c, 86400);
        my($file, $newid) = Thruk::BP::Utils::next_free_bp_file($c);
        my $label = Thruk::BP::Utils::clean_nasty($c->req->parameters->{'bp_label'} || 'New Business Process');
        $label = Thruk::BP::Utils::make_uniq_label($c, $label);
        my $bp = Thruk::BP::Components::BP->new($c, $file, {
            'name'  => $label,
            'nodes' => [{
                'id'       => 'node1',
                'label'    => $label,
                'function' => 'Worst()',
                'depends'  => ['node2'],
            }, {
                'id'       => 'node2',
                'label'    => 'Example Node',
                'function' => 'Fixed("OK")',
            }],
        });
        $bp->set_label($c, $label);
        $bp->save();
        die("internal error") unless $bp;
        Thruk::Utils::set_message( $c, { style => 'success_message', msg => 'business process sucessfully created' });
        return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&edit=1&bp=".$newid);
    }

    # readonly actions
    if($id) {
        $c->stash->{editmode} = $c->req->parameters->{'edit'} || 0;
        $c->stash->{editmode} = 0 unless $allowed_for_edit;
        my $bps = Thruk::BP::Utils::load_bp_data($c, { id => $id, edit => $c->stash->{editmode}, backend => $bp_backend_id });
        if(scalar @{$bps} == 0) {
            my $proxyurl = Thruk::Utils::proxifiy_me($c, $bp_backend_id);
            if($proxyurl) {
                $proxyurl =~ s/bp=[^:]*:/bp=/gmx;
                return $c->redirect_to($proxyurl);
            }
            if($c->config->{'Thruk::Plugin::BP'}->{'result_backend'}) {
                $proxyurl = Thruk::Utils::proxifiy_me($c, $c->config->{'Thruk::Plugin::BP'}->{'result_backend'});
                if($proxyurl) {
                    $proxyurl =~ s/bp=[^:]*:/bp=/gmx;
                    return $c->redirect_to($proxyurl);
                }
            }
            Thruk::Utils::set_message( $c, { style => 'fail_message', msg => 'no such business process or no permissions', code => 404 });
            return _bp_start_page($c);
        }
        my $bp = $bps->[0];
        $c->stash->{'bp'} = $bp;

        if($c->req->parameters->{'update'}) {
            if($c->check_cmd_permissions('host', $bp->{'name'})) {
                $bp->update_status($c);
            }
        }
        # try to find this bp on any system
        my $hosts = $c->db->get_hosts( filter => [ { 'name' => $bp->{'name'} } ] );
        $c->stash->{'bp_backend'} = '';
        for my $hst (@{$hosts}) {
            my $vars = Thruk::Utils::get_custom_vars($c, $hst);
            if($vars->{'THRUK_BP_ID'} && $vars->{'THRUK_BP_ID'} == $id) {
                $c->stash->{'bp_backend'} = $hst->{'peer_key'};
                last;
            }
        }

        $c->stash->{'bp_custom_functions'} = Thruk::BP::Utils::get_custom_functions($c);
        $c->stash->{'bp_custom_filter'}    = Thruk::BP::Utils::get_custom_filter($c);

        if($action eq 'details') {
            if($c->req->parameters->{'view_mode'} and $c->req->parameters->{'view_mode'} eq 'json') {
                my $json = { $bp->{'id'} => $bp->TO_JSON() };
                return $c->render(json => $json);
            }
            $c->stash->{'outgoing_refs'}  = $bp->get_outgoing_refs($c);
            $c->stash->{'incoming_refs'}  = $bp->get_incoming_refs($c);

            my($search) = Thruk::Utils::Status::classic_filter($c, { 'host' => 'all' }, 1);
            $c->stash->{'search'}         = $search;
            $c->stash->{'substyle'}       = 'service';
            $c->stash->{'paneprefix'}     = 'dfl_';
            $c->stash->{'prefix'}         = 's0';
            $c->stash->{'title'}          = $bp->{'name'};
            $c->stash->{'subtitle'}       = $bp->{'name'};

            $c->stash->{'auto_reload_fn'} = 'bp_refresh_bg';
            $c->stash->{'template'}       = 'bp_details.tt';
            return 1;
        }
        elsif($action eq 'refresh') {
            # test mode?
            if($c->stash->{testmode}) {
                $bp->{'testmode'} = 1;
                my $testmodes = {};
                for my $n (@{$bp->{'nodes'}}) {
                    my $state = $c->req->parameters->{$n->{'id'}};
                    if(defined $state) {
                        $testmodes->{$n->{'id'}} = $state;
                        $n->set_status($state, 'testmode', $bp, { testmode => 1 });
                    }
                }
                $c->stash->{testmodes} = $testmodes;
                $bp->update_status($c, 1); # only recalculate
            }
            $c->stash->{template} = '_bp_graph.tt';
            return 1;
        }
        if($action eq 'list_objects') {
            # save request parameters
            my $saved_req_params = {};
            for my $key (keys %{$c->req->parameters}) {
                $saved_req_params->{$key} = $c->req->parameters->{$key};
            }
            my $params = {};
            my $hst = 0;
            my $svc = 0;
            my $bp_lookup = {};
            ($params, $hst, $svc) = _bp_list_add_objects($c, $bp, $params, $hst, $svc, $bp_lookup);
            if($hst == 0 && $svc == 0) {
                Thruk::Utils::set_message( $c, { style => 'fail_message', msg => 'this business process has no references' });
                return $c->redirect_to($c->stash->{'url_prefix'}."cgi-bin/bp.cgi?action=details&bp=".$id);
            }
            $params->{'title'} = $bp->{'name'};
            $params->{'style'} = 'combined';
            if($hst == 0) {
                # only service filter -> show service list only
                $params->{'style'} = 'detail';
                for my $key (keys %{$params}) {
                    my $newkey = $key;
                    $newkey =~ s/^svc_/dfl_/gmx;
                    $params->{$newkey} = delete $params->{$key};
                }
            }

            for my $key (keys %{$c->req->parameters}) {
                if($key !~ m/^(hoststatustypes|servicestatustypes|page|previous|next|entries|first|last|total_pages)/mx) {
                    delete $c->req->parameters->{$key};
                }
            }
            for my $key (keys %{$params}) {
                $c->req->parameters->{$key} = $params->{$key};
            }
            local $c->config->{'maximum_search_boxes'} = 9999;
            require Thruk::Controller::status;
            Thruk::Controller::status::index($c);

            # cleanup request parameters again
            for my $key (keys %{$c->req->parameters}) {
                delete $c->req->parameters->{$key};
            }
            for my $key (keys %{$saved_req_params}) {
                $c->req->parameters->{$key} = $saved_req_params->{$key};
            }
            return(1);
        }
    }

    _bp_start_page($c);

    return 1;
}

##########################################################
sub _bp_start_page {
    my($c) = @_;

    Thruk::Utils::Status::set_default_stash($c);
    $c->stash->{template}  = 'bp.tt';
    $c->stash->{editmode}  = 0;

    my $type = $c->req->parameters->{'type'} // $c->config->{'Thruk::Plugin::BP'}->{'default_tab'} // 'local';
    $c->stash->{'type'} = $type;
    my $view_mode = $c->req->parameters->{'view_mode'} || 'html';

    # load business processes
    my $drafts_too = $c->stash->{allowed_for_edit} ? 1 : 0;
    if($c->req->parameters->{'no_drafts'}) {
        $drafts_too = 0;
    }
    my $local_bps = [];
    $local_bps = Thruk::BP::Utils::load_bp_data($c, { drafts => $drafts_too, skip_nodes => 1, skip_runtime => 1 });

    my $bps = [];
    if($type eq 'local' || $type eq 'all' || $type eq 'business process') {
        $bps = $local_bps;
    }

    # add remote business processes
    $c->stash->{'has_remote_bps'} = 0;
    if(scalar @{$c->db->get_http_peers(1)} > 0) {
        $c->stash->{'has_remote_bps'} = 1;
        if($type eq 'remote' || $type eq 'all') {
            $bps = _add_remote_bps($c, $bps, $local_bps);
        }
    }

    # search request from filter input
    if($c->req->parameters->{'format'} && $c->req->parameters->{'format'} eq 'search') {
        if($view_mode eq 'json') {
            my $data = [];
            for my $bp (@{$bps}) {
                push @{$data}, $bp->{'name'};
            }
            my $json = [ { 'name' => "business processs", 'data' => $data } ];
            return $c->render(json => $json);
        }
        my $data = [];
        for my $bp (@{$bps}) {
            push @{$data}, $bp->{'name'};
        }
        return $c->render(json => [{ data =>  $data, name => "bps"}]);
    }

    my $filter = $c->req->parameters->{'filter'} // '';
    if($filter) {
        my $new_bps = [];
        ## no critic
        my $regex = qr/$filter/i;
        ## use critic
        for my $bp (@{$bps}) {
            push @{$new_bps}, $bp if $bp->{'name'} =~ $regex;
        }
        $bps = $new_bps;
    }
    $c->stash->{'filter'} = $filter;

    $c->stash->{'excel_columns'} = ['Name', 'Status', 'Last Check', 'Duration', 'Status Information'];
    if($view_mode eq 'json') {
        my $data = {};
        for my $bp (@{$bps}) {
            if($bp->{'remote'}) {
                $data->{$bp->{'fullid'}} = $bp;
            } else {
                $bp->load_runtime_data();
                $data->{$bp->{'id'}} = $bp->TO_JSON();
            }
        }
        return $c->render(json => $data);
    }
    elsif($view_mode eq 'xls') {
        Thruk::Utils::Status::set_selected_columns($c, [''], 'bp', $c->stash->{'excel_columns'});
        for my $bp (@{$bps}) {
            $bp->load_runtime_data() unless $bp->{'remote'};
        }
        $c->res->headers->header( 'Content-Disposition', 'attachment; filename="bp.xls"' );
        $c->stash->{'data'}     = $bps;
        $c->stash->{'template'} = 'excel/bp.tt';
        return $c->render_excel();
    }

    Thruk::Utils::page_data($c, $bps);
    for my $bp (@{$c->stash->{'data'}}) {
        $bp->load_runtime_data() unless $bp->{'remote'};
    }

    Thruk::Utils::ssi_include($c);

    return 1;
}

##########################################################
sub _add_remote_bps {
    my($c, $bps, $local_bps) = @_;

    my $site_names = {};
    for my $p (@{$c->db->get_peers(1)}) {
        $site_names->{$p->{'key'}} = $p->{'name'};
    }

    my $uniq = {};
    for my $bp (@{$local_bps}) {
        $uniq->{$bp->{'id'}.':'.$bp->{'name'}} = 1;
        $bp->{'site'} = '';
        next unless $bp->{'bp_backend'};
        $bp->{'site'} = $site_names->{$bp->{'bp_backend'}} // '';
    }
    my $services = $c->db->get_services( filter => [ Thruk::Utils::Auth::get_auth_filter( $c, 'services' ), { 'custom_variable_names' => { '>=' => 'THRUK_BP_ID' } } ] );
    for my $svc (@{$services}) {
        my $vars = Thruk::Utils::get_custom_vars($c, $svc);
        next unless($vars->{'THRUK_NODE_ID'} && $vars->{'THRUK_NODE_ID'} eq 'node1');
        my $fullid = $vars->{'THRUK_BP_ID'}.':'.$svc->{'description'};
        # skip the ones we have already
        next if $uniq->{$fullid};
        my $remote_bp = {
            name                => $svc->{'description'},
            bp_backend          => $svc->{'peer_key'},
            status              => $svc->{'state'},
            last_check          => $svc->{'last_check'},
            last_state_change   => $svc->{'last_state_change'},
            status_text         => $svc->{'plugin_output'} // '',
            fullid              => $svc->{'peer_key'}.':'.$vars->{'THRUK_BP_ID'},
            draft               => 0,
            site                => $site_names->{$svc->{'peer_key'}} // '',
            remote              => 1,
        };
        $remote_bp->{'status_text'} =~ s|\\n|\n|gmx;
        $uniq->{$fullid} = 1;
        push @{$bps}, $remote_bp;
    }
    @{$bps} = sort { $a->{'name'} cmp $b->{'name'} } @{$bps};
    return($bps);
}

##########################################################
sub _bp_list_add_objects {
    my($c, $bp, $params, $hst, $svc, $bp_lookup) = @_;
    $bp_lookup->{$bp->{'id'}} = 1;
    for my $n (@{$bp->{'nodes'}}) {
        if(lc $n->{'function'} eq 'status') {
            if($n->{'host'} and $n->{'service'}) {
                my $service = $n->{'service'};
                $service =~ s/^(b|w)://gmx;
                my $svc_op  = $n->{'function_args'}->[2];
                $params->{'svc_s'.$svc.'_type'}   = ['host', 'service'];
                $params->{'svc_s'.$svc.'_op'}     = ['=', $svc_op];
                $params->{'svc_s'.$svc.'_value'}  = [$n->{'host'}, $service];
                $svc++;
            }
            elsif($n->{'host'}) {
                $params->{'hst_s'.$hst.'_type'}   = 'host';
                $params->{'hst_s'.$hst.'_op'}     = '=';
                $params->{'hst_s'.$hst.'_value'}  = $n->{'host'};
                $hst++;
            }
        }
        elsif(lc $n->{'function'} eq 'groupstatus') {
            if($n->{'hostgroup'}) {
                $params->{'hst_s'.$hst.'_type'}   = 'hostgroup';
                $params->{'hst_s'.$hst.'_op'}     = '=';
                $params->{'hst_s'.$hst.'_value'}  = $n->{'hostgroup'};
                $hst++;

                $params->{'svc_s'.$svc.'_type'}   = 'hostgroup';
                $params->{'svc_s'.$svc.'_op'}     = '=';
                $params->{'svc_s'.$svc.'_value'}  = $n->{'hostgroup'};
                $svc++;
            }
            elsif($n->{'servicegroup'}) {
                $params->{'svc_s'.$svc.'_type'}   = 'servicegroup';
                $params->{'svc_s'.$svc.'_op'}     = '=';
                $params->{'svc_s'.$svc.'_value'}  = $n->{'servicegroup'};
                $svc++;
            }
        }
        elsif(lc $n->{'function'} eq 'statusfilter') {
            $c->stash->{'minimal'} = 1; # do not fill totals boxes
            my $type   = $n->{'function_args'}->[1];
            my $filter = $n->{'function_args'}->[2];
            my $p;
            for my $f (@{$filter}) {
                if($type eq 'hosts') {
                    $p = Thruk::Utils::Status::filter_to_param('hst_s'.$hst.'_', $f);
                    $hst++;
                } else {
                    $p = Thruk::Utils::Status::filter_to_param('svc_s'.$svc.'_', $f);
                    $svc++;
                }
            }
            $params = {%{$params}, %{$p}};
        }
    }

    # check recursive for other linked business processes
    my $recursive_bps = {};
    my $livedata = $bp->bulk_fetch_live_data($c, 1);
    if($livedata->{'hosts'}) {
        for my $host (values %{$livedata->{'hosts'}}) {
            my $vars = Thruk::Utils::get_custom_vars($c, $host);
            if($vars->{'THRUK_BP_ID'} && !defined $bp_lookup->{$vars->{'THRUK_BP_ID'}}) {
                $recursive_bps->{$vars->{'THRUK_BP_ID'}} = 1;
            }
        }
    }
    if($livedata->{'services'}) {
        for my $name (keys %{$livedata->{'services'}}) {
            for my $service (values %{$livedata->{'services'}->{$name}}) {
                my $vars = Thruk::Utils::get_custom_vars($c, $service);
                if($vars->{'THRUK_BP_ID'} && !defined $bp_lookup->{$vars->{'THRUK_BP_ID'}}) {
                    $recursive_bps->{$vars->{'THRUK_BP_ID'}} = 1;
                }
            }
        }
    }
    for my $bp_id (sort keys %{$recursive_bps}) {
        my $link_bp = Thruk::BP::Utils::load_bp_data($c, { id => $bp_id });
        $bp_lookup->{$bp_id} = 1;
        if(scalar @{$link_bp} == 1) {
            ($params, $hst, $svc) = _bp_list_add_objects($c, $link_bp->[0], $params, $hst, $svc, $bp_lookup);
        }
    }


    return($params, $hst, $svc);
}

##########################################################

1;
