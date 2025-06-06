package TestUtils;

use warnings;
use strict;
use utf8;

#########################
# Test Utils
#########################
BEGIN {
  $ENV{'THRUK_MODE'} = 'TEST';
  $ENV{'THRUK_TEST_NO_AUDIT_LOG'} = 1;
  $ENV{'PLACK_TEST_EXTERNALSERVER_URI'} =~ s#/$##gmx if $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
  binmode(STDOUT, ":encoding(UTF-8)");
  binmode(STDERR, ":encoding(UTF-8)");
}

###################################################
use lib 'lib';
use Carp qw/confess/;
use Cpanel::JSON::XS qw/encode_json decode_json/;
use Data::Dumper;
use File::Temp qw/tempfile/;
use HTTP::Cookies::Netscape;
use HTTP::Request ();
use HTTP::Request::Common 6.12 qw/GET POST/;
use Plack::Test;
use Test::More;
use Time::HiRes qw/sleep gettimeofday tv_interval/;
use URI::Escape qw/uri_unescape/;

use Thruk ();
use Thruk::UserAgent ();
use Thruk::Utils::Crypt ();
use Thruk::Utils::Encode ();

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT    = qw(request ctx_request);
our @EXPORT_OK = qw(request ctx_request);
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

my @js_functions = qw/js_init js_ok js_eval_ok js_eval_extracted js_is js_deinit/;
push @EXPORT_OK, @js_functions;
$EXPORT_TAGS{js} = \@js_functions;

my $use_html_lint;
my $lint;
my $test_token = "";

my $has_curl = 0; # does require newer curl, disabling for now (2020-06-09) # has_util("curl");

our $placktest;

#########################
sub has_util {
    my($util) = @_;
    for my $path (split/:/mx, $ENV{'PATH'}) {
        return(1) if -x $path.'/'.$util;
    }
    return(0);
}

#########################
sub request {
    my($url) = @_;
    my($req, $res);
    if(!$placktest) {
        $placktest = Plack::Test->create(Thruk->startup);
    }
    if(ref $url eq "") {
        $res = $placktest->request(GET $url);
    } else {
        $res = $placktest->request($url);
    }
    return($res);
}

#########################
sub clear {
    undef $placktest;
    undef $Thruk::thruk;
}

#########################
sub ctx_request {
    my($url) = @_;
    local $ENV{'THRUK_KEEP_CONTEXT'} = 1;
    $Thruk::Globals::c = undef;
    my $res = request($url);
    my $c = $Thruk::Globals::c;
    return($res, $c);
}

#########################
sub get_test_servicegroup {
    my $request = _request('/thruk/r/servicegroups?columns=name&limit=1');
    ok( $request->is_success, 'get_test_servicegroup() request succeeded' ) || bail_out_req('got no test object, cannot test.', $request);
    my $data       = decode_json($request->decoded_content || $request->content);
    my $name       = $data->[0]->{'name'};
    isnt($name, undef, "got a servicegroup from the rest api") || bail_out_req('got no test object, cannot test.', $request);
    return($name);
}

#########################
sub get_test_hostgroup {
    my $request = _request('/thruk/r/hostgroups?columns=name&limit=1');
    ok( $request->is_success, 'get_test_hostgroup() request succeeded' ) || bail_out_req('got no test object, cannot test.', $request);
    my $data       = decode_json($request->decoded_content || $request->content);
    my $name       = $data->[0]->{'name'};
    isnt($name, undef, "got a hostgroup from the rest api") || bail_out_req('got no test object, cannot test.', $request);
    return($name);
}

#########################
sub get_test_user {
    our $remote_user_cache;
    return $remote_user_cache if $remote_user_cache;
    my $request = _request('/thruk/r/thruk/whoami?columns=id');
    ok( $request->is_success, 'get_test_user() request succeeded' ) || bail_out_req('got no test object, cannot test.', $request);
    my $data       = decode_json($request->decoded_content || $request->content);
    my $name       = $data->{'id'};
    isnt($name, undef, "got a user from the rest api") || bail_out_req('got no test object, cannot test.', $request);
    $remote_user_cache = $name;
    return($name);
}

#########################
sub get_current_user_token {
    our $remote_user_token;
    return $remote_user_token if $remote_user_token;
    my $request = _request('/thruk/cgi-bin/user.cgi');
    ok( $request->is_success, 'get_current_user_token() request succeeded' ) || bail_out_req('got no token, cannot test.', $request);
    my $page = $request->content;
    my $token;
    if($page =~ m/name="CSRFtoken"\s+value="([^"]+)"/mxo) {
        $token = $1;
    }
    isnt($token, undef, "got a token from user.cgi") || bail_out_req('got no token, cannot test.', $request);
    $remote_user_token = $token;
    return($token);
}

#########################
sub get_test_service {
    my $backend = shift;
    my $request = _request('/thruk/r/services?columns=host_name,description&description[nregex]=Business&limit=1'.(defined $backend ? '&backend='.$backend : ''));
    ok( $request->is_success, 'get_test_service() request succeeded' ) || bail_out_req('got no test host, cannot test.', $request);
    my $data    = decode_json($request->decoded_content || $request->content);
    my $host    = $data->[0]->{'host_name'};
    my $service = $data->[0]->{'description'};
    isnt($host, undef, "got a host from the rest api") || bail_out_req('got no test host, cannot test.', $request);
    isnt($service, undef, "got a service from the rest api") || bail_out_req('got no test service, cannot test.', $request);
    return($host, $service);
}

#########################
sub get_test_timeperiod {
    my $request = _request('/thruk/r/timeperiods?columns=name&limit=1');
    ok( $request->is_success, 'get_test_timeperiod() request succeeded' ) || bail_out_req('got no test object, cannot test.', $request);
    my $data       = decode_json($request->decoded_content || $request->content);
    my $name       = $data->[0]->{'name'};
    isnt($name, undef, "got a timeperiod from the rest api") || bail_out_req('got no test object, cannot test.', $request);
    return($name);
}

#########################
sub get_test_host_cli {
    my($binary) = @_;
    my $auth = '';
    if(!$ENV{'PLACK_TEST_EXTERNALSERVER_URI'}) {
        my $user = Thruk->config->{'default_user_name'};
        $auth = ' -A "'.$user.'"' if($user and $user ne 'thrukadmin');
    }
    my $test = { cmd  => $binary.' -a listhosts'.$auth };
    test_command($test);
    my $host = (split(/\n/mx, $test->{'stdout'}))[0];
    isnt($host, undef, 'got test hosts') or BAIL_OUT($0.": need test host:\n".Dumper($test));
    return $host;
}

#########################
sub get_test_hostgroup_cli {
    my($binary) = @_;
    my $auth = '';
    if(!$ENV{'PLACK_TEST_EXTERNALSERVER_URI'}) {
        my $user = Thruk->config->{'default_user_name'};
        $auth = ' -A "'.$user.'"' if($user and $user ne 'thrukadmin');
    }
    my $test = { cmd  => $binary.' -a listhostgroups'.$auth };
    test_command($test);
    my @groups = split(/\n/mx, $test->{'stdout'});
    my $hostgroup;
    for my $group (@groups) {
        my($name, $members) = split/\s+/, $group, 2;
        next unless $members;
        $hostgroup = $name;
    }
    isnt($hostgroup, undef, 'got test hostgroup') or BAIL_OUT($0.": need test hostgroup");
    return $hostgroup;
}

#########################

=head2 test_page

  check a page

  needs test hash
  {
    url             => url to test
    post            => do post request with this data
    post_file       => file upload, must be list of form: [{ 'name' => 'upload name', 'filename' => 'filename', 'data' => '...', 'content_type' => 'image/png' } ]
    method          => http method, default is GET
    follow          => follow redirects
    fail            => request should fail
    code            => expect this response code
    redirect        => request should redirect
    location        => redirect location
    fail_message_ok => page can contain error message without failing
    like            => (list of) regular expressions which have to match page content
    unlike          => (list of) regular expressions which must not match page content
    content_type    => match this content type
    skip_html_lint  => skip html lint check
    skip_doctype    => skip doctype check, even if its an html page
    skip_js_check   => skip js comma check
    sleep           => sleep this amount of seconds after the request
    waitfor         => wait till regex occurs (max 300sec or waitmax)
    waitmax         => wait this amount of seconds
    agent           => user agent for requests
    callback        => content callback
  }

=cut
sub test_page {
    my(%opts) = @_;
    my $return  = {};
    my $waitmax = $opts{'waitmax'} // 300;

    my $start = time();
    my $opts = _set_test_page_defaults(\%opts);

    if($opts->{'post'}) {
        if(ref $opts->{'post'} eq 'REF') {
            $opts->{'post'} = ${$opts->{'post'}};
        }
        $opts->{'method'} = 'POST' unless $opts->{'method'};
        $opts->{'method'} = uc($opts->{'method'});
        local $Data::Dumper::Indent = 0;
        local $Data::Dumper::Varname = $opts->{'method'};
        ok($opts->{'url'}, $opts->{'method'}.' '.Thruk::Utils::Encode::encode_utf8($opts->{'url'}).' '.Dumper($opts->{'post'}));
    } else {
        $opts->{'method'} = 'GET' unless $opts->{'method'};
        $opts->{'method'} = uc($opts->{'method'});
        ok($opts->{'url'}, $opts->{'method'}.' '.Thruk::Utils::Encode::encode_utf8($opts->{'url'}));
    }

    my $request = _request($opts->{'url'}, $opts->{'startup_to_url'}, $opts->{'post'}, $opts->{'agent'}, $opts->{'method'}, $opts->{'post_file'});

    if(defined $opts->{'follow'}) {
        my $redirects = 0;
        while(my $location = $request->{'_headers'}->{'location'}) {
            if($location !~ m/^(http|\/)/gmxo) { $location = _relative_url($location, $request->base()->as_string()); }
            $request = _request($location, undef, undef, $opts->{'agent'});
            $redirects++;
            last if $redirects > 10;
        }
        ok( $redirects < 10, 'Redirect succeed after '.$redirects.' hops' ) || bail_out_req('too many redirects', $request, 1);
    }

    my $cleaned_content = $request->content;
    $cleaned_content =~ s/<script.*?<\/script>//sgmx;
    if($cleaned_content =~ m/<span\ class="fail_message">(.*?)<\/span>/msxo) {
        my $msg = $1;
        fail('Request '.$opts->{'url'}.' had error message: '.$msg) unless $opts->{'fail_message_ok'};
        fail('Request '.$opts->{'url'}.' error message contains escaped html: '.$msg) if $msg =~ m/&lt;.*&gt;/mx;
    }

    # wait for something?
    $return->{'content'} = $request->decoded_content || $request->content;
    if(defined $opts->{'waitfor'}) {
        my $now = time();
        my $waitfor = $opts->{'waitfor'};
        my $found   = 0;
        my $end     = $start + $waitmax;
        ok(1, "waiting for $waitfor to appear till ".(scalar localtime $end));
        while($now < $end) {
            # text that shouldn't appear
            if(defined $opts->{'unlike'}) {
                for my $unlike (@{_list($opts->{'unlike'})}) {
                    if($return->{'content'} =~ m/$unlike/mx) {
                        fail("Content should not contain: ".(defined $1 ? $1 : $unlike)) or diag($opts->{'url'});
                        return $return;
                    }
                }
            }

            if($return->{'content'} =~ $waitfor) {
                ok(1, "content ".$waitfor." found after ".($now - $start)."seconds");
                $found = 1;
                last;
            }

            if($request->is_redirect && $request->{'_headers'}->{'location'} =~ m/cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
                # is it a background job page?
                my $location = $request->{'_headers'}->{'location'};
                wait_for_job($location);
                $request = _request($location, undef, undef, $opts->{'agent'});
                $return->{'content'} = $request->content;
                if($request->is_error) {
                    fail('Request '.$location.' should succeed. Original url: '.$opts->{'url'});
                    bail_out_req('request failed', $request, 1);
                }
                if($request->is_redirect && $request->{'_headers'}->{'location'} =~ m/cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
                    fail(sprintf('Request %s should not redirect to job page again. (start: %s, now: %s, original url: %s', $location, (scalar localtime $start), (scalar localtime $now), $opts->{'url'}));
                    bail_out_req('request failed', $request, 1);
                }
            } else {
                sleep(0.3);
                $now = time();
                $request = _request($opts->{'url'}, $opts->{'startup_to_url'}, $opts->{'post'}, $opts->{'agent'}, $opts->{'method'});
                $return->{'content'} = $request->content;
            }
        }

        if(!$found) {
            fail("content did not match $waitfor within $waitmax seconds") or diag($opts->{'url'});
            bail_out_req("waitfor failed, bailing out", $request, 1);
        } else {
            # text that should appear
            if(defined $opts->{'like'}) {
                for my $like (@{_list($opts->{'like'})}) {
                    my $regex = ref $like ? $like : qr/$like/;
                    like($return->{'content'}, $regex, "Content should contain: ".Thruk::Utils::Encode::encode_utf8($like)) or diag($opts->{'url'});
                }
            }
        }

        return $return;
    }

    my($job_location, $job_id);
    # job redirect
    if($request->is_redirect && $request->{'_headers'}->{'location'} =~ m/cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
        $job_id = $1;
        $job_location = $request->{'_headers'}->{'location'};
    }
    # job page?
    elsif(defined $return->{'content'} && $return->{'content'} =~ m/cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
        $job_id = $1;
        $job_location = "/thruk/cgi-bin/job.cgi?job=".$job_id;
    }
    # follow job
    if($job_id) {
        wait_for_job($job_location);
        $request = _request($job_location, undef, undef, $opts->{'agent'});
        $return->{'content'} = $request->content;
        if($request->is_error) {
            fail('Request '.$job_location.' should succeed. Original url: '.$opts->{'url'});
            bail_out_req('request failed', $request, 1);
        }
    }

    if(defined $opts->{'code'}) {
        is($request->code, $opts->{'code'}, 'Request '.$opts->{'url'}.' returns code: '.$opts->{'code'} );
    }
    elsif(defined $opts->{'fail'}) {
        ok( $request->is_error, 'Request '.$opts->{'url'}.' should fail' );
    }
    elsif(defined $opts->{'redirect'}) {
        ok( $request->is_redirect, 'Request '.$opts->{'url'}.' should redirect' ) or diag(Dumper($opts, $request));
        if(defined $opts->{'location'}) {
            if(defined $request->{'_headers'}->{'location'}) {
                like($request->{'_headers'}->{'location'}, qr/$opts->{'location'}/, "Content should redirect: ".$opts->{'location'});
            } else {
                fail('no redirect header found');
            }
        }
    }
    else {
        ok( $request->is_success, 'Request '.Thruk::Utils::Encode::encode_utf8($opts->{'url'}).' should succeed' ) || bail_out_req('request failed', $request, 1);
    }

    # text that should appear
    if(defined $opts->{'like'}) {
        for my $like (@{_list($opts->{'like'})}) {
            use Carp;
            my $regex = ref $like ? $like : qr/$like/;
            like($return->{'content'}, $regex, "Content should contain: ".Thruk::Utils::Encode::encode_utf8($regex)) || bail_out_req("failed content like match", $request, 1);
        }
    }

    # text that shouldn't appear
    if(defined $opts->{'unlike'}) {
        for my $unlike (@{_list($opts->{'unlike'})}) {
            my $content = $return->{'content'};
            if($unlike eq 'HASH' || $unlike eq 'ARRAY') {
                # remove stacktrace parts from content
                $content =~ s%\Q<!--BEGIN STACKTRACE-->\E.*?\Q<!--END STACKTRACE-->\E%%sgmx;
            }
            unlike($content, qr/$unlike/, "Content should not contain: ".$unlike) || bail_out_req("failed content unlike match", $request, 1);
        }
    }

    # test the content type
    $return->{'content_type'} = $request->header('content-type');
    my $content_type = $request->header('content-type') || '';
    if(defined $opts->{'content_type'}) {
        is($return->{'content_type'}, $opts->{'content_type'}, 'Content-Type should be: '.$opts->{'content_type'}) || bail_out_req("failed content-type match", $request, 1);
    }


    # memory usage
    SKIP: {
        skip "skipped memory check", 1 if $ENV{'TEST_SKIP_MEMORY'};
        require Thruk::Backend::Pool;
        my $rsize = Thruk::Utils::IO::get_memory_usage($$);
        ok($rsize < 1024, 'resident size ('.$rsize.'MB) higher than 1024MB on '.Thruk::Utils::Encode::encode_utf8($opts->{'url'}));
    }

    # html valitidy
    if(!defined $opts->{'skip_doctype'} or $opts->{'skip_doctype'} == 0) {
        if($content_type =~ 'text\/html' and !$request->is_redirect) {
            like($return->{'content'}, '/<html[^>]*>/i', 'html page has html section');
            like($return->{'content'}, '/<!doctype/i',   'html page has doctype');
        }
    }
    if($content_type =~ m|text/html| && !defined $return->{'content_type'}) {
        # test without having to change the test number in all tests
        fail("Content-Type should contain charset=utf-8") unless $content_type =~ m/\;\s*charset=utf\-8/mx;
    }
    if($content_type =~ m|application/json|) {
        # test without having to change the test number in all tests
        fail("Content-Type should contain charset=utf-8") unless $content_type =~ m/\;\s*charset=utf\-8/mx;
    }
    my $is_length  = length($request->content);
    my $got_length = $request->header('content-length');
    if($got_length && $is_length != $got_length) {
        fail("Content-Length did not match, $is_length != $got_length");
    }
    my $got_chunked = $request->header('client-transfer-encoding') // $request->header('transfer-encoding');
    if(!$got_length && ($content_type =~ m|text/html| || $content_type =~ m|application/json|)) {
        # traefik alters the response and remove the content-length in favor of chunked encoding
        if(!$got_chunked || $got_chunked ne 'chunked') {
            fail("no Content-Length set");
        }
    }

    SKIP: {
        if($content_type =~ m|text/html| and (!defined $opts->{'skip_html_lint'} or $opts->{'skip_html_lint'} == 0)) {
            if(!defined $use_html_lint) {
                # load lint on first use
                $use_html_lint = 0;
                eval {
                    require HTML::Lint;
                    $use_html_lint = 1;
                    $lint          = HTML::Lint->new();
                };
            }
            if($use_html_lint == 0) {
                skip "no HTML::Lint installed", 1;
            }
            $lint->newfile($opts->{'url'});
            # will result in "Parsing of undecoded UTF-8 will give garbage when decoding entities..." otherwise
            my $content = $return->{'content'};
            utf8::decode($content);
            $lint->parse($content);
            $lint->eof();
            my @errors = $lint->errors;
            @errors = diag_lint_errors_and_remove_some_exceptions($lint, $content);
            is(scalar @errors, 0, "No errors found in HTML");
            $lint->clear_errors();
            my $html_only_content = $return->{'content'};
            $html_only_content =~ s/<script[^>]*>.+?<\/script>//gsmxio;
            my $matches = get_matches_with_meta($html_only_content, qr/^(.*\&amp;amp.*)$/mx);
            for my $m (@{$matches}) {
                next if $m->{'match'} =~ m/abbr=/mx;
                fail(sprintf("page contains double html escaped amps in line %d: %s", $m->{'line'}, $m->{'match'}));
            }
        }
    }

    # check for missing images / css or js
    if($content_type =~ 'text\/html') {
        my $content = $return->{'content'};
        # check for failed javascript lists
        verify_html_js($content) unless $opts->{'skip_js_check'};
        # remove script tags without a src
        $content =~ s/<script(?!([^>]*src=[^>]*))[^>]*>.+?<\/script>//gsmxio;
        my @matches1 = $content =~ m/<(?:[^>]+)\s+(src|href)='(.+?)'/gio;
        my @matches2 = $content =~ m/<(?:[^>]+)\s+(src|href)="(.+?)"/gio;
        my $links_to_check;
        my $x=0;
        for my $match (@matches1, @matches2) {
            $x++;
            next if $x%2==1;
            next if $match =~ m/^https?:/mxo;
            next if $match =~ m/^\/\//mxo;
            next if $match =~ m/^ssh/mxo;
            next if $match =~ m/^mailto:/mxo;
            next if $match =~ m/^(\#|'|")/mxo;
            next if $match =~ m/\/thruk\/cgi\-bin/mxo;
            next if $match =~ m/^\w+\.cgi/mxo;
            next if $match =~ m/^javascript:/mxo;
            next if $match =~ m/^'\+\w+\+'$/mxo         and defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
            next if $match =~ m|^/thruk/frame\.html|mxo and defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'};
            next if $match =~ m/"\s*\+\s*icon\s*\+\s*"/mxo;
            next if $match =~ m/\/"\+/mxo;
            next if $match =~ m/data:image\/png;base64/mxo;
            $match =~ s/"\s*\+\s*url_prefix\s*\+\s*"/\//gmxo;
            $match =~ s/"\s*\+\s*theme\s*\+\s*"/Thruk/gmxo;
            $links_to_check->{$match} = 1;
        }
        my $errors = 0;
        for my $test_url (sort keys %{$links_to_check}) {
            if($test_url !~ m/^(http|\/)/gmxo) { $test_url = _relative_url($test_url, $request->base()->as_string()); }
            next if $test_url =~ m/\/pnp4nagios\//mxo;
            next if $test_url =~ m/\/pnp\//mxo;
            next if $test_url =~ m/\/grafana\//mxo;
            next if $test_url =~ m|/thruk/themes/.*?/images/logos/|mxo;
            my $request = _request($test_url, undef, undef, $opts->{'agent'});

            if($request->is_redirect) {
                my $redirects = 0;
                while(my $location = $request->{'_headers'}->{'location'}) {
                    if($location !~ m/^(http|\/)/gmxo) { $location = _relative_url($location, $request->base()->as_string()); }
                    $request = _request($location, undef, undef, $opts->{'agent'});
                    $redirects++;
                    last if $redirects > 10;
                }
            }
            unless($request->is_success) {
                $errors++;
                diag("'$test_url' is missing, status: ".$request->code);
            }
        }
        is( $errors, 0, 'All stylesheets, images and javascript exist' );
    }

    # sleep after the request?
    if(defined $opts->{'sleep'}) {
        ok(sleep($opts->{'sleep'}), "slept $opts->{'sleep'} seconds");
    }

    if($opts->{'callback'}) {
        $opts->{'callback'}($return->{'content'});
    }

    $return->{'response'} = $request;
    $return->{'code'}     = $request->code();
    return $return;
}

#########################

=head2 set_cookie

    set_cookie($name, $value, $expire)

  Sets cookie. Expire date is in seconds. A value <= 0 will remove the cookie.

=cut
sub set_cookie {
    my($var, $val, $expire) = @_;
    our($cookie_jar, $cookie_file);
    if(!defined $cookie_jar) {
        my $fh;
        ($fh, $cookie_file) = tempfile(TEMPLATE => 'tempXXXXX', UNLINK => 1);
        unlink ($cookie_file);
        $cookie_jar = HTTP::Cookies::Netscape->new(file => $cookie_file);
    }
    my $config      = Thruk::Config::get_config();
    my $cookie_path = $config->{'cookie_path'};
    $cookie_jar->set_cookie( 0, $var, $val, $cookie_path, 'localhost.local', undef, 1, 0, $expire, 1, {});
    $cookie_jar->save();
    return;
}

#########################
sub diag_lint_errors_and_remove_some_exceptions {
    my($lint, $content) = @_;
    my @return;
    for my $error ( $lint->errors ) {
        my $err_str = $error->as_string;
        next if $err_str =~ m/<IMG\ SRC="[^"]+">\ tag\ has\ no\ HEIGHT\ and\ WIDTH\ attributes/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "data\-[\w\-]+"\ for\ tag/imxo;
        next if $err_str =~ m/Invalid\ character.*should\ be\ written\ as/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "placeholder"\ for\ tag\ <input>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "placeholder"\ for\ tag\ <textarea>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "class"\ for\ tag\ <html>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "autocomplete"\ for\ tag\ <form>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "autocomplete"\ for\ tag\ <input>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "hidden"\ for\ tag\ <option>/imxo;
        next if $err_str =~ m/Character\ ".*?"\ should\ be\ written\ as/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "manifest"\ for\ tag\ <html>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "sizes"\ for\ tag\ <link>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "charset"\ for\ tag\ <meta>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "required"\ for\ tag\ <(input|select|textarea)>/imxo;
        next if $err_str =~ m/Unknown\ attribute\ "oncontextmenu"\ for\ tag/imxo;
        next if $err_str =~ m/<html>\ tag\ is\ required/imxo;
        next if $err_str =~ m/<head>\ tag\ is\ required/imxo;
        next if $err_str =~ m/<title>\ tag\ is\ required/imxo;
        next if $err_str =~ m/<body>\ tag\ is\ required/imxo;
        next if $err_str =~ m/Entity\ .*\ is\ unknown/imxo;
        next if $err_str =~ m/Unknown\ element\ <(main|header|footer|nav)>/imxo;
        diag($error->as_string."\n");
        my @lines = $error->as_string() =~ m/\((\d+):\d+\)/gmx;
        for my $line (sort @lines) {
            _diag_context($content, $line);
        }
        push @return, $error;
    }
    return @return;
}

#########################
sub _diag_context {
    my($content, $nr) = @_;
    my $linenr = 0;
    for my $line (split(/\n/, $content)) {
        $linenr++;
        if($linenr >= $nr-2 && $linenr <= $nr+2) {
            diag($linenr.": ".substr($line, 0, 250));
        }
    }
    return;
}

#########################
sub get_themes {
    my @themes = @{Thruk->config->{'themes'}};
    return @themes;
}

#########################
sub get_c {
    our($c);
    return $c if defined $c;
    my $res;
    ($res, $c) = ctx_request('/thruk/changes.html');
    return $c;
}

#########################
sub get_user {
    my $c = get_c();
    require Thruk::Utils;
    my ($uid, $groups) = Thruk::Utils::get_user($c);
    my $user           = getpwuid($uid);
    return $user;
}

#########################
sub wait_for_job {
    my($url) = @_;
    my($job, $joburl);
    my $maxwait = 300;
    my $maxend  = time() + $maxwait;
    if($url =~ m/^\w+$/mx) {
        $job = $url;
    }
    elsif($url =~ m/proxy\.cgi\/([^\/]+)\/.*cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
        $job = $1;
        $joburl = $url.'&json=1';
    }
    elsif($url =~ m/cgi\-bin\/job\.cgi\?job=(\w+)/mxo) {
        $job = $1;
    }
    my $start = [gettimeofday];
    my $config = Thruk::Config::get_config();

    if($ENV{'PLACK_TEST_EXTERNALSERVER_URI'} || $joburl) {
        $joburl = '/thruk/r/thruk/jobs/'.$job unless $joburl;
        local $SIG{ALRM} = sub { die("timeout while waiting for external job: ".$job) };
        alarm($maxwait);
        my $data;
        eval {
            while(time() < $maxend) {
                my $r = _request($joburl);
                eval {
                    $data = decode_json($r->decoded_content);
                };
                last if($data && defined $data->{'is_running'} && $data->{'is_running'} == 0 && $data->{'end'} && $data->{'end'} > 0);
                sleep(0.1);
            }
        };
        my $end = [gettimeofday];
        is($data->{'is_running'}, 0, 'job '.$job.' is finished in '.(sprintf("%.3f", tv_interval($start, $end))).' seconds');
        alarm(0);
        return;
    }

    my $jobdir = $config->{'var_path'} ? $config->{'var_path'}.'/jobs/'.$job : './var/jobs/'.$job;
    if(!-e $jobdir) {
        fail("job folder ".$jobdir.": ".$!);
        return;
    }
    local $SIG{ALRM} = sub { die("timeout while waiting for job: ".$jobdir) };
    require Thruk::Utils::External;

    alarm($maxwait);
    eval {
        while(Thruk::Utils::External::_is_running(undef, $jobdir) && time() < $maxend) {
            sleep(0.1);
        }
    };
    alarm(0);
    my $end = [gettimeofday];
    is(Thruk::Utils::External::_is_running(undef, $jobdir), 0, 'job '.$job.' is finished in '.(sprintf("%.3f", tv_interval($start, $end))).' seconds')
        or diag(sprintf("uptime: %s\n\nps:\n%s\n\njobs:\n%s\n",
                            scalar `uptime`,
                            scalar `ps -efl`,
                            scalar `find $jobdir/ -ls -exec cat {} \\;`,
               ));
    return;
}

#########################

=head2 test_command

  execute a test command

  needs test hash
  {
    cmd     => command line to execute
    exit    => expected exit code (set to undef to ignore exit code verification)
    like    => (list of) regular expressions which have to match stdout
    errlike => (list of) regular expressions which have to match stderr, default: empty
    unlike  => (list of) regular expressions which must not match stdout
    sleep   => time to wait after executing the command
    env     => hash with extra environment variables
    waitfor => wait till regex occurs (max 120sec)
    maxwait => how long should be waited (default 30sec)
  }

=cut
sub test_command {
    my $test = shift;
    my($rc, $stdout, $stderr) = ( -1, '', '') ;
    my $return = 1;

    require Test::Cmd;
    Test::Cmd->import();

    # run the command
    isnt($test->{'cmd'}, undef, "running cmd: ".Thruk::Utils::Encode::encode_utf8($test->{'cmd'})) or $return = 0;

    if($test->{'env'}) {
        for my $key (%{$test->{'env'}}) {
            $ENV{$key} = $test->{'env'}->{$key};
        }
    }

    my($prg,$arg) = split(/\s+/, $test->{'cmd'}, 2);

    # wait for something?
    if(defined $test->{'waitfor'}) {
        my $duration = $test->{'maxwait'} // 30;
        my $start    = time();
        my $now      = time();
        my $waitfor  = $test->{'waitfor'};
        my $found    = 0;
        local $test->{'exit'}    = undef;
        local $test->{'like'}    = '/.*/';
        local $test->{'errlike'} = '/.*/';
        my $expr = '';
        my $end  = $start + $duration;
        ok(1, "waiting for $waitfor to appear till ".(scalar localtime $end));
        while($now <= $end) {
            alarm(15);
            $expr = $waitfor;
            my $t = Test::Cmd->new(prog => $prg, workdir => '') || bail_out_cmd($test, -1, $!);
            $test->{'test_cmd'} = $t;
            eval {
                local $SIG{ALRM} = sub { die "timeout on cmd: ".$test->{'cmd'}."\n" };
                $t->run(args => $arg, stdin => $test->{'stdin'});
            };
            alarm(0);
            $stdout = Thruk::Utils::Encode::decode_any(scalar $t->stdout);

            if($waitfor =~ m/^\!/) {
                $expr =~ s/^\!//mx;
                if($stdout !~ m/$expr/mx) {
                    ok(1, "content ".$expr." disappeared after ".($now - $start)."seconds");
                    $found = 1;
                    last;
                }
            }
            elsif($stdout =~ m/$waitfor/mx) {
                ok(1, "content ".$expr." found after ".($now - $start)."seconds");
                $found = 1;
                last;
            }
            sleep(1);
            $now = time();
        }
        if(!$found) {
            fail("content ".$expr." did not occur within ".$duration." seconds");
            bail_out_cmd($test, -1, "waitfor failed");
        }
    }

    my $t = Test::Cmd->new(prog => $prg, workdir => '') || bail_out_cmd($test, -1, $!);
    $test->{'test_cmd'} = $t;

    alarm(300);
    eval {
        local $SIG{ALRM} = sub { die "timeout on cmd: ".$test->{'cmd'}."\n" };
        $t->run(args => $arg, stdin => $test->{'stdin'});
        $rc = $?>>8;
    };
    if($@) {
        $stderr = $@;
    } else {
        $stderr = Thruk::Utils::Encode::decode_any(scalar $t->stderr);
    }
    $stdout = Thruk::Utils::Encode::decode_any(scalar $t->stdout);
    alarm(0);

    # exit code?
    $test->{'exit'} = 0 unless exists $test->{'exit'};
    if(defined $test->{'exit'} and $test->{'exit'} != -1) {
        ok($rc == $test->{'exit'}, "exit code: ".$rc." == ".$test->{'exit'}) || do { bail_out_cmd($test, $rc, "command failed with rc: ".$rc, 2); $return = 0 };
    }

    # matches on stdout?
    if(defined $test->{'like'}) {
        for my $expr (ref $test->{'like'} eq 'ARRAY' ? @{$test->{'like'}} : $test->{'like'} ) {
            like($stdout, $expr, "stdout like ".Thruk::Utils::Encode::encode_utf8($expr)) || do { bail_out_cmd($test, $rc, "content like failed", 2); $return = 0 };
        }
    }

    # unlike matches on stdout?
    if(defined $test->{'unlike'}) {
        for my $expr (ref $test->{'unlike'} eq 'ARRAY' ? @{$test->{'unlike'}} : $test->{'unlike'} ) {
            unlike($stdout, $expr, "stdout unlike ".$expr) || do { bail_out_cmd($test, $rc, "content unlike failed", 2); $return = 0 };
        }
    }

    # matches on stderr?
    $test->{'errlike'} = '/^\s*$/' unless exists $test->{'errlike'};
    if(defined $test->{'errlike'}) {
        for my $expr (@{_list($test->{'errlike'})}) {
            like($stderr, $expr, "stderr like ".$expr) || do { bail_out_cmd($test, $rc, "content errlike failed", 2); $return = 0 };
        }
    }

    # sleep after the command?
    if(defined $test->{'sleep'}) {
        ok(sleep($test->{'sleep'}), "slept $test->{'sleep'} seconds");
    }

    # set some values
    $test->{'stdout'} = $stdout;
    $test->{'stderr'} = $stderr;
    $test->{'exit'}   = $rc;

    return $return;
}

#########################

=head2 override_config

    override_config('key', 'value')

  override config setting

=cut
sub override_config {
    my($key, $value) = @_;
    my $c = get_c();
    $c->config->{$key} = $value;
    ok(1, "config: set '$key' to '$value'");
    return;
}

#########################
sub make_test_hash {
    my $data = shift;
    my $test = shift || {};
    if(ref $data eq '') {
        $test->{'url'} = $data;
    } else {
        for my $key (%{$data}) {
            $test->{$key} = $data->{$key};
        }
    }
    return $test;
}
#########################
sub _relative_url {
    my($location, $url) = @_;
    my $newloc = $url;
    $newloc    =~ s/^(.*\/).*$/$1/gmxo;
    $newloc    .= $location;
    while($newloc =~ s|/[^\/]+/\.\./|/|gmxo) {}
    return $newloc;
}

#########################
sub _request {
    my($url, $start_to, $post, $agent, $method, $file_upload) = @_;

    our($cookie_jar, $cookie_file);
    if(!defined $cookie_jar) {
        my $fh;
        ($fh, $cookie_file) = tempfile(TEMPLATE => 'tempXXXXX', UNLINK => 1);
        unlink ($cookie_file);
        $cookie_jar = HTTP::Cookies::Netscape->new(file => $cookie_file);
    }

    $url =~ s|^\Qhttp://localhost.local/\E|/|gmx;
    if(defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'} || $url =~ m/^https?:\/\//mx) {
        return(_external_request(@_));
    }
    # add pseudo domain, otherwise cookies from set_cookie() won't work
    $url = 'http://localhost.local'.$url unless $url =~ m|^https?:|mx;

    my $request;
    if($post) {
        $method = 'POST' unless $method;
        $method = uc($method);
        $post->{'CSRFtoken'} = $test_token if $test_token;
        $request = POST($url, {});
        $request->method(uc($method));
        $request = _build_post_request($request, $post, $file_upload);
    } else {
        $method = 'GET' unless $method;
        $method = uc($method);
        $request = HTTP::Request->new($method => $url);
    }
    $request->header("User-Agent" => $agent) if $agent;
    $request->header('X-Thruk-Auth-Key'  => $ENV{'THRUK_TEST_AUTH_KEY'})  if $ENV{'THRUK_TEST_AUTH_KEY'};
    $request->header('X-Thruk-Auth-User' => $ENV{'THRUK_TEST_AUTH_USER'}) if $ENV{'THRUK_TEST_AUTH_USER'};
    $cookie_jar->add_cookie_header($request);
    my $response = request($request);
    $cookie_jar->extract_cookies($response);

    return $response;
}

#########################
sub _external_request {
    my($url, $start_to, $post, $agent, $method, $file_upload, $retry) = @_;
    confess("no url") unless $url;
    $retry = 1 unless defined $retry;

    if($url !~ m/^http/) {
        $url =~ s#//#/#gmx;
        $url =~ s#^/demo##gmx;
        if($ENV{'PLACK_TEST_EXTERNALSERVER_URI'}) {
            $url = $ENV{'PLACK_TEST_EXTERNALSERVER_URI'}.$url;
        }
    }

    our($cookie_jar, $cookie_file);
    our $ua;
    $ua = Thruk::UserAgent->new({
        keep_alive   => 1,
        max_redirect => 0,
        timeout      => 60,
        requests_redirectable => [],
    }, {
        use_curl     => $has_curl,
    }) unless $ua;
    $ua->env_proxy;
    $ua->cookie_jar($cookie_jar);
    $ua->agent( $agent ) if $agent;

    if($post && ref $post ne 'HASH') {
        confess("unknown post data: ".Dumper($post));
    }
    my $req;
    if($post || ($method && $method ne 'GET')) {
        $post = {} unless defined $post;
        $post->{'CSRFtoken'} = $test_token if $test_token;
        $method = 'POST' unless $method;
        my $request = POST($url, {});
        $request->method(uc($method));
        $request = _build_post_request($request, $post, $file_upload);
        $request->header('X-Thruk-Auth-Key'  => $ENV{'THRUK_TEST_AUTH_KEY'})  if $ENV{'THRUK_TEST_AUTH_KEY'};
        $request->header('X-Thruk-Auth-User' => $ENV{'THRUK_TEST_AUTH_USER'}) if $ENV{'THRUK_TEST_AUTH_USER'};
        $cookie_jar->add_cookie_header($request) if $cookie_jar;
        $req = $ua->request($request);
    } else {
        my $request = GET($url);
        $cookie_jar->add_cookie_header($request) if $cookie_jar;
        $request->header('X-Thruk-Auth-Key'  => $ENV{'THRUK_TEST_AUTH_KEY'})  if $ENV{'THRUK_TEST_AUTH_KEY'};
        $request->header('X-Thruk-Auth-User' => $ENV{'THRUK_TEST_AUTH_USER'}) if $ENV{'THRUK_TEST_AUTH_USER'};
        $req = $ua->request($request);
    }

    if($req->is_redirect and $req->{'_headers'}->{'location'} =~ m/\/thruk\/cgi\-bin\/login\.cgi\?(.*)$/mxo and defined $ENV{'THRUK_TEST_AUTH'}) {
        die("login failed: ".Dumper($req)) unless $retry;
        my $referer = uri_unescape($1);
        $referer =~ s/^nocookie&//gmx;
        $referer = '/'.$referer;
        my($user, $pass) = split(/:/mx, $ENV{'THRUK_TEST_AUTH'}, 2);
        my $login_page = $req->{'_headers'}->{'location'};
        my $r = _external_request($login_page, undef, undef, $agent);
        $login_page =~ s/nocookie&//gmx;
           $r = _external_request($login_page, undef, { password => $pass, login => $user, submit => 'login', referer => $referer }, $agent, undef, undef, 0);
        $req  = _external_request($r->{'_headers'}->{'location'} // $url, $start_to, $post, $agent, undef, undef, 0);

    }
    return $req;
}

#########################
sub _build_post_request {
    my($request, $post, $file_upload) = @_;
    if($file_upload) {
        # construct a multipart/form-data request
        my $boundary = "--".Thruk::Utils::Crypt::random_uuid([time()]);
        $request->content_type('multipart/form-data; boundary='.$boundary);
        my $content = "";
        for my $key (sort keys %{$post}) {
            $content .= sprintf("--%s\nContent-Disposition: form-data; name=\"%s\"\n\n%s\n", $boundary, $key, $post->{$key});
        }
        for my $file (@{$file_upload}) {
            $content .= sprintf("--%s\nContent-Disposition: form-data; name=\"%s\"; filename=\"%s\"\nContent-Type: %s\n\n%s\n",
                $boundary,
                $file->{'name'},
                $file->{'filename'},
                $file->{'content_type'},
                $file->{'data'},
            );
        }
        $content .= sprintf("--%s--\n", $boundary);
        # HTML/4.01 says that line breaks are represented as "CR LF" pairs (i.e., `%0D%0A')
        $content =~ s/\n/\x0D\x0A/g;
        $request->content($content);
    } else {
        $request->content_type('application/json; charset=utf-8');
        $request->content(Cpanel::JSON::XS->new->encode($post)); # using ->utf8 here would end in double encoding
    }
    $request->header('Content-Length' => undef);

    return($request);
}

#########################
sub _set_test_page_defaults {
    my($opts) = @_;
    if(!exists $opts->{'unlike'}) {
        $opts->{'unlike'} = [ 'internal server error', 'HASH', 'ARRAY' ];
    }
    return $opts;
}

#########################
sub bail_out_req {
    my($msg, $res, $die) = @_;
    $die = 0 if $ENV{'THRUK_TEST_BAIL_OUT'};

    my $page    = $res->content;
    my $error   = "";
    if($page =~ m/<!--error:(.*?):error-->/smx) {
        $error = $1;
        $error =~ s/\A\s*//gmsx;
        $error =~ s/\s*\Z//gmsx;
        eval {
            require HTML::Entities;
            HTML::Entities::decode_entities($error);
        };
        die($0.': '.$res->code.' '.$msg."\n".$error) if $die;
        BAIL_OUT($0.': '.$res->code.' '.$msg."\n".$error);
    }
    if($page =~ m/<pre\s+id="error">(.*)$/mx) {
        $error = $1;
        $error =~ s|</pre>$||gmx;
        die($0.': '.$res->code.' '.$msg.' - '.$error) if $die;
        BAIL_OUT($0.': '.$res->code.' '.$msg.' - '.$error);
    }
    if($page =~ m/\Qsubject=Thruk%20Error%20Report&amp;body=\E(.*?)">/smx) {
        $error = URI::Escape::uri_unescape($1);
        diag($error);
        die($0.': '.$res->code.' '.$msg.' - '.$error) if $die;
        BAIL_OUT($0.': '.$res->code.' '.$msg.' - '.$error);
    }
    diag("\n######################################################\n");
    diag("request diagnostics:");
    diag("error: '".(ref $msg ? Dumper($msg) : $msg)."'\n");
    my $time = Thruk::Utils::Log::time_prefix(); chop($time);
    diag("date:  '".$time."'\n");
    diag("request:\n");
    diag($res->request->as_string());
    diag("\n\nresponse:\n");
    diag($res->as_string());
    diag("\n\norigin:\n");
    diag(Carp::longmess("started here:"));
    diag("\n######################################################\n");
    die($0.': '.$msg) if $die;
    BAIL_OUT($0.': '.$msg);
    return;
}

#########################

=head2 bail_out_cmd

  print diagnostic output for failed commands

=cut
sub bail_out_cmd {
    my($test, $rc, $msg, $die) = @_;
    $die = 0 if $ENV{'THRUK_TEST_BAIL_OUT'};

    # command provides diag callback
    &{$test->{'diag'}}($test) if $test->{'diag'};

    diag("\n######################################################\n");
    diag("cmd diagnostics:");
    diag("error:  '".(ref $msg ? Dumper($msg) : $msg)."'\n");
    my $cmd = $test->{'test_cmd'};
    diag("cmd:    '".$test->{'cmd'}."' failed\n");
    diag("stdout: '".($cmd->stdout // '')."'\n") if $cmd;
    diag("stderr: '".($cmd->stderr // '')."'\n") if $cmd;
    diag("exit:   '".($rc // '(none)')."'\n");

    diag(Carp::longmess("started here:"));
    diag("\n######################################################\n");
    BAIL_OUT($msg) unless $die;
    die($msg) if $die == 1;
    return;
}

#########################

=head2 bail_out_diag

  print diagnostic output and bail out

=cut
sub bail_out_diag {
    my($msg, @details) = @_;

    diag("\n######################################################\n");
    chomp($msg);
    diag($msg."\n");
    for my $d (@details) {
        my $m = (ref $d ? Dumper($d) : $d);
        chomp($m);
        diag($m."\n");
    }

    diag(Carp::longmess("started here:"));
    diag("\n######################################################\n");
    BAIL_OUT($msg);
    return;
}

#########################
sub set_test_user_token {
    return if $test_token;
    $test_token = get_current_user_token();
    return;
}

#########################
sub _list {
    my($data) = @_;
    return $data if ref $data eq 'ARRAY';
    return([$data]);
}

#################################################
# verify js syntax
my $errors_js = 0;
sub verify_js {
    my($file) = @_;
    my $content = Thruk::Utils::IO::read($file);
    my $matches = _replace_with_marker($content);
    return unless $matches;
    _check_marker($file, $content) if $errors_js;
    return;
}

#################################################
# verify js syntax in html
sub verify_html_js {
    my($content) = @_;
    $content =~ s/(<script.*?<\/script>)/&_extract_js($1)/misge;
    _check_marker(undef, $content) if $errors_js;
    return;
}

#################################################
# verify js syntax in templates
sub verify_tt {
    my($file) = @_;
    my $content = Thruk::Utils::IO::read($file);
    confess("file could not be read: $file") unless $content;
    $content =~ s/(<script.*?<\/script>)/&_extract_js($1)/misge;
    _check_marker($file, $content) if $errors_js;
    return;
}

#################################################
# verify js syntax in templates
sub _extract_js {
    my($text) = @_;
    _replace_with_marker($text);
    return $text;
}

#################################################
# verify js syntax in templates
sub _replace_with_marker {
    my $errors  = 0;

    # trailing commas
    my @matches = $_[0]  =~ s/(\,\s*[\)|\}|\]])/JS_ERROR_MARKER1:$1/sgmxi;
    @matches = grep {!/^\s*$/} @matches;
    $errors    += scalar @matches;

    # insecure for loops which do not work in IE8
    @matches = $_[0]  =~ s/(for\s*\(.*\s+in\s+.*\))/JS_ERROR_MARKER2:$1/gmxi;
    @matches = grep {!/^\s*$/} @matches;
    $errors    += scalar @matches;

    # jQuery().attr('checked', true) must be .prop now
    @matches = $_[0]  =~ s/(\.attr\s*\(.*checked)/JS_ERROR_MARKER3:$1/gmxi;
    @matches = grep {!/^\s*$/} @matches;
    $errors    += scalar @matches;

    # jQuery().attr('selected', true) must be .prop now
    @matches = $_[0]  =~ s/(\.attr\s*\(.*selected)/JS_ERROR_MARKER4:$1/gmxi;
    @matches = grep {!/^\s*$/} @matches;
    $errors    += scalar @matches;

    $errors_js += $errors;
    return $errors;
}

#################################################
sub _check_marker {
    my($file, $content) = @_;
    my @lines = split/\n/mx, $content;
    my $x = 0;
    for my $line (@lines) {
        $x++;
        next unless $line =~ m/JS_ERROR_MARKER/mx;
        if($line =~ m/JS_ERROR_MARKER1:/mx) {
            my $orig = $line;
            $orig   .= "\n".$lines[$x+1] if defined $lines[$x+1];
            $orig =~ s/JS_ERROR_MARKER1://gmx;
            fail('found trailing comma in '.($file || 'content').' line: '.$x);
            diag($orig);
        }
        if($line =~ m/JS_ERROR_MARKER2:/mx and $line !~ m/var\s+(peer_key|key|section|id)/) {
            my $orig = $line;
            $orig =~ s/JS_ERROR_MARKER2://gmx;
            fail('found insecure for loop in '.($file || 'content').' line: '.$x);
            diag($orig);
        }
        if($line =~ m/JS_ERROR_MARKER3:/mx) {
            my $orig = $line;
            $orig   .= "\n".$lines[$x+1] if defined $lines[$x+1];
            $orig =~ s/JS_ERROR_MARKER3://gmx;
            fail('found jQuery.attr(checked) instead of .prop() in '.($file || 'content').' line: '.$x);
            diag($orig);
        }
        if($line =~ m/JS_ERROR_MARKER4:/mx) {
            my $orig = $line;
            $orig   .= "\n".$lines[$x+1] if defined $lines[$x+1];
            $orig =~ s/JS_ERROR_MARKER4://gmx;
            fail('found jQuery.attr(selected) instead of .prop() in '.($file || 'content').' line: '.$x);
            diag($orig);
        }
    }
    $errors_js = 0;
}

#################################################
sub get_matches_with_meta {
    my($string, $regex) = @_;
    my @matches;
    while($string =~ /$regex/g) {
        my $match = substr($string, $-[0], $+[0]-$-[0]);
        my $linenr = 1 + substr($string,0,$-[0]) =~ y/\n//;
        push @matches, {
            match => $match,
            line  => $linenr,
        };
    }
    return(\@matches);
}

#################################################
sub js_init {
    eval "use WWW::Mechanize::Chrome";
    plan skip_all => 'WWW::Mechanize::Chrome required' if $@;

    # cannot eval larger files otherwise
    eval "use Protocol::WebSocket::Frame";
    plan skip_all => 'Protocol::WebSocket::Frame required' if $@;
    $Protocol::WebSocket::Frame::MAX_PAYLOAD_SIZE = 0;
    ok($Protocol::WebSocket::Frame::MAX_PAYLOAD_SIZE == 0, "reduced websocket payload size");

    my($chrome, $diagnosis) = WWW::Mechanize::Chrome->find_executable();
    plan skip_all => 'WWW::Mechanize::Chrome requires chrome: '.$diagnosis if !$chrome;

    my $chrome_folder = "/tmp/.thruk_chromium_test.".$>;
    $ENV{'XDG_CONFIG_HOME'} = $chrome_folder;
    $ENV{'XDG_CACHE_HOME'}  = $chrome_folder;
    Thruk::Utils::IO::cmd("rm -rf $chrome_folder");

    use Log::Log4perl qw(:easy);
    Log::Log4perl->easy_init($ERROR);
    our $mech = WWW::Mechanize::Chrome->new(
        headless         => 1,
        separate_session => 1,
        incognito        => 1,
        tab              => 'current',
        launch_arg       => ["--password-store=basic", "--remote-allow-origins=*"],
    );
    $mech->get_local(-f "./data/blank.html" ? "./data/blank.html" : "../../data/blank.html");
    $mech->clear_js_errors();

    my $console = $mech->add_listener('Runtime.consoleAPICalled', sub {
        return if(scalar @_ == 0);
        diag(join ", ",
            map { $_->{value} // $_->{description} }
            @{ $_[0]->{params}->{args} }
        );
    });

    js_ok("function diag(txt) { console.log(txt); }", 'added diag function');
    return($mech);
}

#################################################
sub js_deinit {
    our $mech;
    $mech->close();
}

#################################################
sub js_ok {
    my($src, $msg, $diag) = @_;

    # replace template toolkit comments
    $src =~ s/\[%\#.*?\#%\]//gmx;

    our $mech;
    ok(1, sprintf("js_ok(%s)", $msg));
    local $SIG{ALRM} = sub { die("timeout while waiting for js eval") };
    alarm(120);
    $mech->clear_js_errors();
    eval {
        $mech->eval_in_page($src, returnByValue => Cpanel::JSON::XS::false);
    };
    my $err = $@;
    if($err) {
        fail(sprintf("js ok failed for %s: %s%s", $msg, ($diag ? ' (from '.$diag.') ' : ''), $err));
    }
    my @err = $mech->js_errors();
    for my $e (@err) {
      _js_diag_error($e, sprintf("console messages for %s: %s", $msg, ($diag ? ' (from '.$diag.') ' : '')));
    }
    $mech->clear_js_errors();
    alarm(0);
}

#################################################
sub js_eval_ok {
  my($file, $msg) = @_;
  my $src = Thruk::Utils::IO::read($file);
  js_ok($src, $file, $msg);
}

#################################################
sub js_is {
    my($src, $expect, $msg) = @_;
    our $mech;
    local $SIG{ALRM} = sub { die("timeout while waiting for js eval") };
    alarm(120);
    $mech->clear_js_errors();
    my($val, $type) = $mech->eval_in_page($src);
    my @err = $mech->js_errors();
    for my $e (@err) {
      _js_diag_error($e, "console messages for: ".($msg//'unknown'));
    }
    $mech->clear_js_errors();
    is($val, $expect, $msg);
    alarm(0);
}

#################################################
sub _js_diag_error {
    my($e, $diag) = @_;
    diag($diag) if $diag;
    my $known = 0;
    if($e->{'message'}) {
        diag($e->{'message'});
        $known = 1;
    }
    if($e->{'exceptionDetails'}) {
        diag(sprintf("[%s:%d:%d] %s: %s",
            $e->{'exceptionDetails'}->{url}//'<anonymous>',
            $e->{'exceptionDetails'}->{lineNumber},
            $e->{'exceptionDetails'}->{columnNumber},
            $e->{'exceptionDetails'}->{text},
            $e->{'exceptionDetails'}->{exception}->{description},
        ));
        $known = 1;
    }
    if($e->{'args'}) {
        diag(join ", ",
            map { $_->{value} // $_->{description} }
            @{$e->{args}}
        );
        $known = 1;
    }
    if($e->{'type'} && $e->{'type'} eq 'debug') {
        diag("not failing on debug lvl console message");
        return;
    } else {
        fail("got js error");
    }
    if($e->{'stackTrace'} && ref $e->{'stackTrace'} eq 'HASH' && $e->{'stackTrace'}->{'callFrames'}) {
        diag("Stack Trace:");
        for my $frame (@{$e->{'stackTrace'}->{'callFrames'}}) {
            diag(sprintf("  at %s (%s:%s:%s)",
                $frame->{functionName} // 'anonymous',
                $frame->{url} // '[unknown]',
                $frame->{lineNumber} // '?',
                $frame->{columnNumber} // '?',
            ));
        }
    }

    diag("unknown error: ".Dumper($e)) unless $known;
}

#################################################
sub js_eval_extracted {
    my($file, $msg) = @_;
    ok(1, "extracting from ".$file);
    my $cont = Thruk::Utils::IO::read($file);
    my @codes = $cont =~ m/<script[^>]*?>(.*?)<\/script>/gsmxi;
    my $jscode = join("\n", @codes);
    $jscode =~ s/\[\%\s*product_prefix\s*\%\]/thruk/gmx;
    $jscode =~ s/\[\%\#.*?\#\%\]//gmx;
    my($fh, $filename) = tempfile();
    print $fh $jscode;
    close($fh);
    js_eval_ok($filename, $msg);
    unlink($filename);
    return;
}

#################################################
END {
    our $cookie_file;
    unlink($cookie_file) if defined $cookie_file;
}

#################################################

1;

__END__
