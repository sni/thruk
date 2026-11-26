#!/usr/bin/perl
#
# test http server for the renderer tests (t/105-render-url.t). Core perl modules only.
#
# usage: TestRenderServer.pl <port> <logfile>
#
# writes one line per request to <logfile>: "<host header>\t<path>\t<cookie header>"
#
use warnings;
use strict;
use IO::Socket::IP;
use MIME::Base64 qw(decode_base64);

my($port, $logfile) = @ARGV;
die("usage: $0 <port> <logfile>\n") unless $logfile;

my $png = decode_base64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

$SIG{'CHLD'} = 'IGNORE';
my $server = IO::Socket::IP->new(LocalHost => '::', LocalPort => $port, Listen => 50, ReuseAddr => 1, V6Only => 0)
          || IO::Socket::IP->new(LocalHost => '0.0.0.0', LocalPort => $port, Listen => 50, ReuseAddr => 1)
          || die("cannot listen on port $port: $!\n");
open(my $log, '>>', $logfile) or die("cannot write $logfile: $!\n");
$log->autoflush(1);
print "listening on port $port\n";
$| = 1;

while(1) {
    my $client = $server->accept() or next;
    my $pid = fork();
    if($pid) { close($client); next; }
    close($server);
    handle($client);
    exit 0;
}

sub reply {
    my($client, $status, $type, $body, @header) = @_;
    print $client "HTTP/1.1 $status X\r\nContent-Type: $type\r\nContent-Length: ".length($body)."\r\nConnection: close\r\nCache-Control: no-store\r\n".join("", map { "$_\r\n" } @header)."\r\n".$body;
    close($client);
    return;
}

sub page { my($body) = @_; return "<html><head><title>test</title></head><body>$body</body></html>"; }

sub handle {
    my($client) = @_;
    my $request = <$client> // return;
    my %h;
    while(my $line = <$client>) {
        $line =~ s/\r?\n$//;
        last if $line eq '';
        $h{lc $1} = $2 if $line =~ m/^([^:]+):\s*(.*)$/;
    }
    my($path) = $request =~ m/^\S+\s+(\S+)/;
    $path //= '/';
    syswrite($log, join("\t", $h{'host'} // '', $path, $h{'cookie'} // '')."\n");

    my($self) = ($h{'host'} // '') =~ m/:(\d+)$/;
    $self //= $port;
    my $foreign = "http://127.0.0.2:$self";

    if($path =~ m|^/status/(\d+)|)      { return reply($client, $1, 'text/html', page("status $1")); }
    if($path =~ m|^/slow/(\d+)|)        { sleep($1); return reply($client, 200, 'image/png', $png); }
    if($path =~ m|^/redirect\?to=(.*)$|) { return reply($client, 302, 'text/html', '', "Location: $1"); }
    if($path =~ m|^/bounce\?to=(.*)$|)   { return reply($client, 200, 'text/html', page('<h1>bounce</h1><script>window.location = "'.$1.'";</script>')); }
    if($path =~ m|^/sub5xx|)            { return reply($client, 200, 'text/html', page('<h1>sub5xx</h1><img src="/slow/20"><img src="/status/503">')); }
    if($path =~ m|^/hangpage|)          { return reply($client, 200, 'text/html', page('<h1>hangpage</h1><img src="/slow/120">')); }
    if($path =~ m|^/embed\?f=(.*)$|)    { return reply($client, 200, 'text/html', page('<h1>embed</h1><iframe src="'.$1.'"></iframe><img src="/late.png?afterframe">')); }
    if($path =~ m|^/framepage\?t=(.*)$|) { return reply($client, 200, 'text/html', page('<h1>frame</h1><img src="'.$1.'/x.png?fromframe_img"><script>fetch("'.$1.'/plain?fromframe_fetch",{credentials:"include",mode:"no-cors"});</script><iframe src="'.$1.'/plain?fromframe_nested"></iframe>')); }
    if($path =~ m|^/popup\?t=(.*)$|)    { return reply($client, 200, 'text/html', page('<h1>popup</h1><script>window.open("'.$1.'");</script><img src="/slow/2">')); }
    if($path =~ m|^/popped\?t=(.*)$|)   { return reply($client, 200, 'text/html', page('<h1>popped</h1><script>window.location="'.$1.'/plain?frompopup_nav";</script>')); }
    if($path =~ m|^/nest\?f=(.*)$|)     { return reply($client, 200, 'text/html', page('<h1>nest</h1><iframe src="'.$1.'"></iframe><img src="/slow/3">')); }
    # a canvas with random pixels does not compress, so the pdf gets large
    if($path =~ m|^/big|)               { return reply($client, 200, 'text/html', page('<h1>big</h1><canvas id="c" width="1200" height="1200"></canvas><script>var x = document.getElementById("c").getContext("2d"); var d = x.createImageData(1200, 1200); for(var i = 0; i < d.data.length; i++) { d.data[i] = (i % 4 == 3) ? 255 : Math.floor(Math.random() * 256); } x.putImageData(d, 0, 0);</script>')); }
    if($path =~ m|^/c/page|) {
        return reply($client, 200, 'text/html', page('<h1>cookie page</h1><script src="/c/sub.js"></script><img src="/other/deep/img.png">'
            .'<script src="'.$foreign.'/foreign_sub.js"></script><img src="/redirect?to='.$foreign.'/after_sub_redirect.png">'));
    }
    if($path =~ m|^/grafana/chart|)     { return reply($client, 200, 'text/html', page('<h1>chart</h1><script>setTimeout(function() { var d = document.createElement("div"); d.className = "flot-text"; d.textContent = "the chart"; document.body.appendChild(d); }, 500);</script>')); }
    if($path =~ m|^/grafana/nochart|)   { return reply($client, 200, 'text/html', page('<h1>no chart here</h1>')); }
    if($path =~ m|^/grafana/busy|)     { return reply($client, 200, 'text/html', page('<h1>busy</h1><script>setTimeout(function() { for(;;) {} }, 200);</script>')); }
    if($path =~ m|^/grafana/login|)     { return reply($client, 200, 'text/html', page('<form><input id="loginuser" name="login"></form>')); }
    if($path =~ m|^/grafana/alert|)     { return reply($client, 200, 'text/html', page('<div class="alert-error">datasource exploded</div>')); }
    if($path =~ m|\.js(\?.*)?$|)         { return reply($client, 200, 'application/javascript', 'var loaded = 1;'); }
    if($path =~ m|\.png(\?.*)?$|)        { return reply($client, 200, 'image/png', $png); }
    return reply($client, 200, 'text/html', page('<h1>plain page</h1><p>host: '.($h{'host'} // '').'</p>'));
}
