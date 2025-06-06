package Thruk::Controller::proxy;

use warnings;
use strict;
use Carp qw/confess/;
use Cpanel::JSON::XS ();
use HTTP::Request 6.12 ();

use Thruk::Action::AddDefaults ();
use Thruk::UserAgent ();
use Thruk::Utils::Log qw/:all/;
use Thruk::Views::ToolkitRenderer ();

=head1 NAME

Thruk::Controller::proxy - Proxy interface

=head1 DESCRIPTION

Thruk Controller

=head1 METHODS

=head2 index

=cut


##########################################################
sub index {
    my($c, $path_info) = @_;

    # workaround for centos7 apache segfaulting on too long requests urls
    if($c->req->header('X-Thruk-Passthrough')) {
        $path_info = $c->req->header('X-Thruk-Passthrough');
    }

    my($site, $url);
    if($path_info =~ m%^.*/thruk/cgi-bin/proxy.cgi/([^/]+)(/.*)$%mx) {
        $site = $1;
        $url  = $2;
    }
    if(!$url || !$site) {
        return $c->detach('/error/index/25');
    }
    if(!$c->config->{'http_backend_reverse_proxy'}) {
        return $c->redirect_to($url);
    }

    $c->authenticate() unless $c->user_exists();
    return $c->detach('/error/index/100') unless $c->user_exists();

    my $res = proxy_request($c, $site, $url, $c->req);

    $c->res->status($res->code);
    $c->res->headers($res->headers);
    $c->res->body($res->content);
    $c->{'rendered'} = 1;
    $c->stash->{'inject_stats'} = 0;
    $c->stash->{'no_change_res_header'} = 1;
    return;

}

##########################################################

=head2 proxy_request

=cut

sub proxy_request {
    my($c, $site, $url, $base_req) = @_;

    my $peer = $c->db->get_peer_by_key($site);
    if(!$peer) {
        # might be a not yet be populated federated backend
        Thruk::Action::AddDefaults::add_defaults($c);
        $peer = $c->db->get_peer_by_key($site);
        die("no such peer: ".$site) unless $peer;
    }
    if($peer->{'type'} ne 'http') {
        if(my $http_peer = $peer->get_http_fallback_peer()) {
            $peer = $http_peer;
        } else {
            confess("peer has type: ".$peer->{'type'});
        }
    }

    my $session_id  = $c->cookies('thruk_auth') || $peer->{'class'}->propagate_session_file($c);
    my $request_url = Thruk::Utils::absolute_url($peer->{'addr'}, $url, 1);

    # federated peers forward to the next hop
    my($passthrough, $add_key);
    if($peer->{'federation'} && scalar @{$peer->{'fed_info'}->{'type'}} >= 2 && $peer->{'fed_info'}->{'type'}->[1] eq 'http') {
        $request_url = $peer->{'addr'};
        $request_url =~ s|/cgi\-bin/remote\.cgi$||gmx;
        $request_url =~ s|/thruk/?$||gmx;
        $request_url = $request_url.'/thruk/cgi-bin/proxy.cgi/'.$peer->{'key'};
        $passthrough = '/thruk/cgi-bin/proxy.cgi/'.$peer->{'key'}.$url;
    } else {
        ## only if normal http request fails or so...
        #$request_url = $peer->{'addr'};
        #$request_url =~ s|/cgi\-bin/remote\.cgi$||gmx;
        #$request_url =~ s|/thruk/?$||gmx;
        #$request_url = $request_url.'/thruk/cgi-bin/remote.cgi';
        #$passthrough = $url;
        #$add_key = 1;
    }

    if($base_req->{'env'}->{'QUERY_STRING'}) {
        $request_url = $request_url.'?'.$base_req->{'env'}->{'QUERY_STRING'};
    }
    my $req = HTTP::Request->new($base_req->method, $request_url, $base_req->headers->clone);
    my $content = $base_req->content();
    if($c->check_user_roles('admin')) {
        my $update = _update_federate_remote_req($c, $peer, $request_url, $content);
        if(defined $update) {
            $content = $update;
            $req->header('Content-Length', length($content));
        }
    }
    $req->content($content);
    # cleanup a few headers
    for my $h (qw/host via x-forwarded-for referer/) {
        $req->header($h, undef);
    }

    $req->header('X-Thruk-Passthrough', undef);
    if($passthrough) {
        $req->header('X-Thruk-Passthrough', $passthrough);
    }
    if($add_key) {
        $req->header('X-Thruk-Auth-Key', $peer->{'class'}->{'auth'});
        $req->header('X-Thruk-Auth-User', $c->user->{'username'}) if $c->user_exists;
    }
    my $ua = Thruk::UserAgent->new({}, $c->config);
    $ua->max_redirect(0);
    Thruk::UserAgent::disable_verify_hostname_by_url($ua, $request_url);

    $req->header('X-Thruk-Proxy', 1);
    _add_cookie($req, 'thruk_auth', $session_id);
    $c->stats->profile(begin => "req: ".$request_url);

    my $res = $ua->request($req);
    $c->stats->profile(end => "req: ".$request_url);
    $c->stats->profile(comment => sprintf('code: %s%s', $res->code, $res->header('location') ? "redirect: ".$res->header('location') : ''));

    # check if we need to login
    if($res->header('location') && $res->header('location') =~ m%\Q/cgi-bin/login.cgi?\E%mx) {
        # propagate session and try again
        $session_id = $peer->{'class'}->propagate_session_file($c);
        _add_cookie($req, 'thruk_auth', $session_id);
        $res = $ua->request($req);
    }

    # in case we don't have a cookie yet, set the last session_id, so it can be reused
    if(!$c->cookies('thruk_auth')) {
        $c->cookie('thruk_auth', $session_id, { 'httponly' => 1 });
    }

    _cleanup_response($c, $peer, $url, $res);
    return($res);
}

##########################################################
sub _cleanup_response {
    my($c, $peer, $url, $res) = @_;

    if($c->req->header('X-Thruk-Passthrough')) {
        return;
    }

    my $replace_prefix;
    if($url =~ m%^(.*/(pnp|pnp4nagios|grafana|thruk))/%mx) { # must be without trailing slash. Breaks grafanas root_url otherwise
        $replace_prefix = $1;
    }
    my $site         = $peer->{'key'};
    my $url_prefix   = $c->stash->{'url_prefix'};
    my $proxy_prefix = $url_prefix.'cgi-bin/proxy.cgi/'.$site;

    # replace url in redirects
    if($res->header('location')) {
        my $loc = $res->header('location');
        $loc =~ s%^https?://[^/]+/%/%mx;
        if($loc !~ m/^\//mx) {
            my $newloc = $url;
            $newloc =~ s/[^\/]+$//gmx;
            $newloc = $newloc.$loc;
            $loc = $newloc;
        }
        $res->header('location', $proxy_prefix.$loc);
    }

    # leads to endless redirect loop in grafana
    $res->header('Link', '') if $res->header('Link');

    # replace path in cookies
    if($res->header("set-cookie")) {
        my $newcookie = $res->header("set-cookie");
        $newcookie =~ s%path=(.*?)(\s|$|;)%path=$proxy_prefix$1;%gmx;
        $res->header("set-cookie", $newcookie);
    }

    if($replace_prefix && $res->header('content-type') && $res->header('content-type') =~ m/^(text\/html|application\/json)/mxi) {
        my $body = $res->decoded_content || $res->content;
        # make thruk links work, but only if we are not proxying thruk itself
        if($url !~ m|/thruk/|mx) {
            $body =~ s%("|')/[^/]+/thruk/cgi-bin/%$1${url_prefix}cgi-bin/%gmx;
        } else {
            # if its thruk itself, insert a message at the top
            if(!$c->req->parameters->{'minimal'} && $body =~ m/(site_panel_container|id="mainframe")/mx) {
                my $header = "";
                # we actually connect to the last http peer in chain, so show that name
                my $proxy_peer = $peer->{'name'};
                if($peer->{'federation'} && $peer->{'fed_info'}->{'type'}) {
                    for(my $x = 0; $x < scalar @{$peer->{'fed_info'}->{'type'}}; $x++) {
                        if($peer->{'fed_info'}->{'type'}->[$x] eq 'http') {
                            $proxy_peer = $peer->{'fed_info'}->{'name'}->[$x];
                        }
                    }
                }
                $c->stash->{'proxy_peer'}   = $proxy_peer;
                $c->stash->{'local_prefix'} = "###local_prefix###";
                Thruk::Views::ToolkitRenderer::render($c, "_proxy_header.tt", $c->stash, \$header);
                $body =~ s/<\/body>/$header<\/body>/gmx;
            }
            # fix cookie path
            $body =~ s%^\s*var\s+cookie_path\s*=\s+'([^']+)';%var cookie_path = '$proxy_prefix$1';%gmx;
        }

        # send other links to our proxy
        $body =~ s%("|')$replace_prefix%$1$proxy_prefix$replace_prefix%gmx;
        $body =~ s%\#\#\#local_prefix\#\#\#%$url_prefix%gmx;

        # length has changed
        $res->headers()->remove_header('content-length');

        # unset content encoding header, because its no longer gziped content but plain text
        $res->headers()->remove_header('content-encoding');

        # replace content
        $res->content(undef);
        $res->add_content_utf8($body);
    }

    return;
}

##########################################################
sub _add_cookie {
    my($req, $name, $val) = @_;
    my $cookies = $req->header('cookie');
    if(!$cookies) {
        $req->header('cookie', $name.'='.$val.'; HttpOnly');
        return;
    }
    $cookies =~ s%$name=.*?(;\s*|$)%%gmx;
    $cookies = $cookies.'; '.$name.'='.$val.';';
    $req->header('cookie', $cookies);
    return;
}
##########################################################
sub _update_federate_remote_req {
    my($c, $peer, $request_url, $content) = @_;

    return unless $request_url =~ m|/thruk/cgi-bin/remote.cgi$|gmx;
    return unless $content =~ m|^\{|gmx;

    my $data;
    my $json = Cpanel::JSON::XS->new->utf8;
    $json->relaxed();
    eval {
        $data = $json->decode($content);
    };
    my $err = $@;
    if($err) {
        _debug("failed to decode json: ".$err);
        return;
    }

    return unless $data->{'data'};

    eval {
        $data = $json->decode($data->{'data'});
    };
    if($err) {
        _debug("failed to decode json: ".$err);
        return;
    }

    $data->{'credential'} = $peer->{'class'}->{'auth'} if $data->{'credential'};
    if($data->{'options'} && $data->{'options'}->{'remote_name'}) {
        if($peer->{'class'}->{'remote_name'}) {
            $data->{'options'}->{'remote_name'} = $peer->{'class'}->{'remote_name'};
        } else {
            delete $data->{'options'}->{'remote_name'};
        }
    }

    return($json->encode({ data => $json->encode($data) }));
}

##########################################################


1;
