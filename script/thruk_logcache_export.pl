#!/bin/bash
# vim: expandtab:ts=4:sw=4:syntax=perl

# read rc files if exist
unset PROFILEDOTD
[ -e /etc/thruk/thruk.env  ] && . /etc/thruk/thruk.env
[ -e ~/etc/thruk/thruk.env ] && . ~/etc/thruk/thruk.env
[ -e ~/.thruk              ] && . ~/.thruk
[ -e ~/.profile            ] && . ~/.profile

BASEDIR=$(dirname $0)/..

# git version
if [ -d $BASEDIR/.git -a -e $BASEDIR/lib/Thruk.pm ]; then
  export PERL5LIB="$BASEDIR/lib:$PERL5LIB";
  if [ "$OMD_ROOT" != "" -a "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$OMD_ROOT/etc/thruk"; fi
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$BASEDIR/"; fi

# omd
elif [ "$OMD_ROOT" != "" ]; then
  export PERL5LIB=$OMD_ROOT/share/thruk/lib:$PERL5LIB
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG="$OMD_ROOT/etc/thruk"; fi

# pkg installation
else
  export PERL5LIB=$PERL5LIB:@DATADIR@/lib:@THRUKLIBS@;
  if [ "$THRUK_CONFIG" = "" ]; then export THRUK_CONFIG='@SYSCONFDIR@'; fi
fi

eval 'exec perl -x $0 ${1+"$@"} ;'
    if 0;
# / this slash makes vscode syntax highlighting work
#! -*- perl -*-
#line 35

########################################################################
# thruk_logcache_export.pl - export a Thruk logcache into a re-importable logfile
#
# The logcache stores the original log line in the message column, so this
# export is lossless and engine independent: mysql/mariadb or postgresql in,
# plain logfile out. Import the result into any logcache with:
#
#   thruk logcache import --local -b <peer> -y <file>
#
# Examples:
#
#   # which logcaches are in this database?
#   ./thruk_logcache_export.pl -d 'mysql://thruk:secret@localhost:3306/thruk_logs' --list
#   ./thruk_logcache_export.pl -d 'postgresql://thruk:secret@dbserver:5432/thruk_logs' --list
#
#   # how many entries would be exported?
#   ./thruk_logcache_export.pl -d '...' -p mon --from 2025-10-01 --count
#
#   # everything since 2025-10-01 into a file
#   ./thruk_logcache_export.pl -d '...' -p mon --from 2025-10-01 -o /tmp/mon.log
#
#   # only the last 30 days, written through gzip
#   ./thruk_logcache_export.pl -d '...' -p mon --from 30d --out - | gzip -9 > mon.log.gz
#
# Supported connection strings, the engine is detected from the prefix:
#
#   mysql://user:password@host:port/database
#   mysql://user:password@/path/to/mysqld.sock/database      (mariadb:// works too)
#   postgresql://user:password@host:port/database            (postgres:// works too)
#   postgresql://user:password@/path/to/socketdir/database
#   DBI:mysql:...  /  DBI:Pg:...                             (passed through as is)
#
# Data is copied byte by byte (SET NAMES binary on mysql, client_encoding
# SQL_ASCII on postgresql), the importer detects the encoding on its own.
# Times are unix timestamps inside the database, date arguments are interpreted
# in the local timezone of the machine running this script. The source database
# is only read, never written.
########################################################################

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use POSIX qw(mktime);
use Time::Piece;
use URI::Escape qw(uri_unescape);
use DBI;
use Encode ();

use constant {
    DEFAULT_CHUNK => 86400,     # export day by day
};

my %opt = (
    'out'   => '-',
    'chunk' => DEFAULT_CHUNK,
);

my $exit_code = eval { run() };
if($@) {
    my $error = $@;
    $error =~ s/\s+at\s+\S+\s+line\s+\d+\.?\s*$//mxg;
    print STDERR 'ERROR: '.$error."\n";
    exit(2);
}
exit(defined $exit_code ? $exit_code : 0);

sub run {
    my $ok = GetOptions(\%opt,
        'dsn|d=s',
        'user|u=s',
        'password=s',
        'prefix|p=s',
        'from|start|s=s',
        'to|end|e=s',
        'out|o=s',
        'chunk|C=s',
        'list',
        'count',
        'quiet|q',
        'help|h',
    );
    usage(1) if !$ok;
    usage(0) if $opt{'help'};

    if(!defined $opt{'dsn'} && defined $ENV{'THRUK_LOGCACHE_DSN'}) {
        $opt{'dsn'} = $ENV{'THRUK_LOGCACHE_DSN'};
    }
    usage(1, 'missing --dsn') if !defined $opt{'dsn'} || $opt{'dsn'} eq '';
    usage(1, 'missing --prefix') if !$opt{'list'} && (!defined $opt{'prefix'} || $opt{'prefix'} eq '');

    my $chunk = parse_duration_spec($opt{'chunk'});
    die("--chunk must be greater than 0\n") if !$chunk;

    my($engine, $dbi_dsn, $db_user, $db_pass) = parse_dsn($opt{'dsn'});
    load_driver($engine);
    info('connecting to '.$engine.' ('.redact_password($dbi_dsn).')');

    my $dbh = connect_db($engine, $dbi_dsn, $db_user, $db_pass);

    return list_caches($dbh, $engine) if $opt{'list'};

    my $prefix = $opt{'prefix'};
    my $table  = quote_identifier($engine, $prefix.'_log');
    assert_table_exists($dbh, $engine, $prefix);

    my $from = parse_time($opt{'from'}, '--from');
    my $to   = parse_time($opt{'to'},   '--to');

    my($min, $max) = $dbh->selectrow_array('SELECT MIN(time), MAX(time) FROM '.$table);
    if(!defined $min) {
        die("no log entries found in $table\n");
    }
    $from //= $min;
    $to   //= $max + 1;
    die("--from (".format_time($from).') is after --to ('.format_time($to).")\n") if $from >= $to;

    if($opt{'count'}) {
        my $count = $dbh->selectrow_array('SELECT COUNT(*) FROM '.$table.' WHERE time >= ? AND time < ?', undef, $from, $to);
        printf("range : %s .. %s\n", format_time($from), format_time($to));
        printf("rows  : %d\n", $count);
        return 0;
    }

    my $out_name = $opt{'out'};
    my $out;
    if($out_name eq '-') {
        $out = \*STDOUT;
    } else {
        open($out, '>', $out_name) or die("cannot open '".$out_name."': ".$!."\n");
    }
    binmode($out); # no encoding layer, we copy bytes

    my $rows    = 0;
    my $bytes   = 0;
    my $started = time();
    my $cursor  = $from;
    while($cursor < $to) {
        my $chunk_end = $cursor + $chunk;
        $chunk_end = $to if $chunk_end > $to;

        my $sth = $dbh->prepare('SELECT message FROM '.$table.' WHERE time >= ? AND time < ? ORDER BY time');
        # stream the result instead of buffering a whole chunk in memory
        eval { $sth->{'mysql_use_result'} = 1; } if $engine eq 'mysql';
        $sth->execute($cursor, $chunk_end);

        my $chunk_rows = 0;
        while(my $row = $sth->fetchrow_arrayref()) {
            my $message = $row->[0] // '';
            $message =~ s/[\r\n]+$//mxg;
            # some drivers hand back decoded strings, write bytes in any case
            $message = Encode::encode_utf8($message) if utf8::is_utf8($message);
            print {$out} $message, "\n";
            $bytes += length($message) + 1;
            $rows++;
            $chunk_rows++;
        }
        $sth->finish();

        info(sprintf('%s .. %s : %9d entries (total %d, %.1f MB)',
                     format_time($cursor), format_time($chunk_end), $chunk_rows, $rows, $bytes / 1024 / 1024));
        $cursor = $chunk_end;
    }

    if($out_name ne '-') {
        close($out) or die("closing '".$out_name."' failed: ".$!."\n");
    }

    info(sprintf('exported %d entries (%.1f MB) in %ds to %s',
                 $rows, $bytes / 1024 / 1024, time() - $started, ($out_name eq '-' ? 'stdout' : $out_name)));
    return 0;
}

##########################################################
sub list_caches {
    my($dbh, $engine) = @_;

    my $tables   = logcache_tables($dbh, $engine);
    my @prefixes = sort map { my $p = $_; $p =~ s/_log$//mx; $p } grep { m/_log$/mx } keys %{$tables};
    my $database = database_name($dbh, $engine);
    if(!scalar @prefixes) {
        info('no logcache tables found in '.$engine.' database '.(defined $database ? $database : '?'));
        return 0;
    }

    info('logcaches in '.$engine.' database '.(defined $database ? $database : '?').':');
    printf("%-16s %14s %10s  %-19s .. %-19s\n", 'prefix', 'rows (est.)', 'size', 'first entry', 'last entry');
    for my $prefix (@prefixes) {
        my $table = quote_identifier($engine, $prefix.'_log');
        my($min, $max) = $dbh->selectrow_array('SELECT MIN(time), MAX(time) FROM '.$table);
        my $meta = $tables->{$prefix.'_log'} // {};
        printf("%-16s %14s %7s MB  %-19s .. %-19s\n",
               $prefix,
               defined $meta->{'row_estimate'}  ? $meta->{'row_estimate'} : '?',
               defined $meta->{'bytes'} ? int($meta->{'bytes'} / 1024 / 1024) : '?',
               defined $min ? format_time($min) : '-',
               defined $max ? format_time($max) : '-');
    }
    return 0;
}

##########################################################
# table name => { rows => estimate, bytes => size } for all base tables
sub logcache_tables {
    my($dbh, $engine) = @_;

    if($engine eq 'mysql') {
        return $dbh->selectall_hashref(
            'SELECT table_name,
                    table_rows AS row_estimate,
                    (COALESCE(data_length, 0) + COALESCE(index_length, 0)) AS bytes
             FROM information_schema.tables
             WHERE table_schema = DATABASE() AND table_type = ?',
            'table_name', undef, 'BASE TABLE');
    }

    # postgres: reltuples is -1 for tables which were never analyzed, that is
    # an unknown count, not a negative number of items
    return $dbh->selectall_hashref(
        "SELECT c.relname AS table_name,
                GREATEST(c.reltuples, 0)::bigint AS row_estimate,
                pg_total_relation_size(c.oid) AS bytes
         FROM pg_class c
         JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE n.nspname = current_schema() AND c.relkind = 'r'",
        'table_name');
}

##########################################################
sub known_prefixes {
    my($dbh, $engine) = @_;
    my $tables = logcache_tables($dbh, $engine);
    return sort map { my $p = $_; $p =~ s/_log$//mx; $p } grep { m/_log$/mx } keys %{$tables};
}

##########################################################
sub assert_table_exists {
    my($dbh, $engine, $prefix) = @_;

    my $found = $dbh->selectrow_array(
        'SELECT table_name FROM information_schema.tables WHERE table_schema = '.schema_expression($engine).' AND table_name = ?',
        undef, $prefix.'_log');
    return if defined $found;

    my @prefixes = known_prefixes($dbh, $engine);
    die('table '.$prefix.'_log does not exist, known logcaches: '.(scalar @prefixes ? join(', ', @prefixes) : 'none')."\n");
}

##########################################################
sub database_name {
    my($dbh, $engine) = @_;
    my $sql = $engine eq 'mysql' ? 'SELECT DATABASE()' : 'SELECT current_database()';
    my($database) = $dbh->selectrow_array($sql);
    return $database;
}

sub schema_expression {
    my($engine) = @_;
    return $engine eq 'mysql' ? 'DATABASE()' : 'current_schema()';
}

##########################################################
# accepts mysql://user:pass@host:port/db, mysql://user:pass@/path/mysqld.sock/db,
# postgresql://user:pass@host:port/db, postgresql://user:pass@/socketdir/db
# and plain DBI:mysql:... / DBI:Pg:... connection strings
sub parse_dsn {
    my($dsn) = @_;

    if($dsn =~ m/^DBI:(mysql|Pg)(?::|\z)/mx) {
        my $engine = $1 eq 'Pg' ? 'postgresql' : 'mysql';
        return($engine, $dsn, $opt{'user'}, $opt{'password'});
    }

    my($engine, $rest);
    if($dsn =~ m/^(?:mysql|mariadb):\/\/(.*)$/mxi) {
        ($engine, $rest) = ('mysql', $1);
    } elsif($dsn =~ m/^(?:postgres|postgresql):\/\/(.*)$/mxi) {
        ($engine, $rest) = ('postgresql', $1);
    } else {
        die("unsupported dsn '$dsn', expected mysql://..., postgresql://... or a DBI:mysql:/DBI:Pg: connection string\n");
    }

    my $user = $opt{'user'};
    my $pass = $opt{'password'};
    my($userinfo, $location) = (undef, $rest);
    if($rest =~ m/^(.*)\@([^\@]*)$/mx) {
        ($userinfo, $location) = ($1, $2);
    }
    if(defined $userinfo && $userinfo ne '') {
        if($userinfo =~ m/^([^:]*):(.*)$/mx) {
            $user = uri_unescape($1);
            $pass = uri_unescape($2);
        } else {
            $user = uri_unescape($userinfo);
        }
    }

    my($target, $database) = ($location, undef);
    if($location =~ m|^(.*)/([^/]+)$|mx) {
        ($target, $database) = ($1, $2);
    }
    die("missing database name in dsn '$dsn'\n") if !defined $database || $database eq '';

    my %args;
    if($target =~ m/\//mx || $target =~ m/\.sock$/mx) {
        if($engine eq 'mysql') {
            $args{'mysql_socket'} = $target;
        } else {
            # libpq expects the directory which contains the .s.PGSQL.<port> socket
            $target =~ s|/[^/]*\.s\.PGSQL\.\d+$||mx;
            $args{'host'} = $target;
        }
    } elsif($target =~ m/^\[([0-9a-f:]+)\](?::(\d+))?$/mxi) {
        $args{'host'} = $1;
        $args{'port'} = $2 if defined $2;
    } elsif($target =~ m/^([^:]+):(\d+)$/mx) {
        $args{'host'} = $1;
        $args{'port'} = $2;
    } elsif($target ne '') {
        $args{'host'} = $target;
    }

    if($engine eq 'mysql') {
        $args{'database'} = $database;
        return($engine, 'DBI:mysql:'.join(';', map { $_ .'='. $args{$_} } sort keys %args), $user, $pass);
    }
    $args{'dbname'} = $database;
    return($engine, 'DBI:Pg:'.join(';', map { $_ .'='. $args{$_} } sort keys %args), $user, $pass);
}

##########################################################
sub load_driver {
    my($engine) = @_;
    my $module = $engine eq q(mysql) ? q(DBD::mysql) : q(DBD::Pg);
    my $file   = $module;
    $file =~ s{::}{/}mxg;
    $file .= q(.pm);
    # require with a variable does not translate :: into a path
    my $loaded = eval { require $file; 1; };
    if(!$loaded) {
        my $error = $@ || '';
        die('driver '.$module.' required for '.$engine.' logcaches: '.$error);
    }
    return;
}

##########################################################
sub connect_db {
    my($engine, $dbi_dsn, $user, $pass) = @_;

    my $dbh = DBI->connect($dbi_dsn, $user, $pass, {
        'RaiseError' => 1,
        'PrintError' => 0,
        'AutoCommit' => 1,
        'ChopBlanks' => 0,
        'pg_enable_utf8' => 0,
    });
    die('connect failed: '.$DBI::errstr."\n") if !$dbh;

    # byte preserving copy, the importer detects the encoding itself
    if($engine eq 'mysql') {
        $dbh->do('SET NAMES binary');
    } else {
        $dbh->do("SET client_encoding TO 'SQL_ASCII'");
    }
    return $dbh;
}

##########################################################
# accepts epoch seconds, YYYY-MM-DD, YYYY-MM-DD HH:MM[:SS], YYYY-MM-DDTHH:MM:SS
# and relative values in the past like 30d, 12h, 90m
sub parse_time {
    my($spec, $option) = @_;
    return undef if !defined $spec || $spec eq '';

    return int($spec) if $spec =~ m/^\d{9,}$/mx;
    if($spec =~ m/^(\d+)([smhdwMy])$/mx) {
        return time() - ($1 * duration_seconds($2));
    }
    for my $format ('%Y-%m-%d %H:%M:%S', '%Y-%m-%dT%H:%M:%S', '%Y-%m-%d %H:%M', '%Y-%m-%d') {
        my $parsed = eval { Time::Piece->strptime($spec, $format) };
        next if !$parsed || $@;
        # strptime interprets the string as UTC, mktime reinterprets the broken
        # down time in the local timezone of the machine running the export
        my $epoch = mktime($parsed->sec, $parsed->min, $parsed->hour, $parsed->mday, $parsed->mon - 1, $parsed->year - 1900);
        return $epoch if defined $epoch && $epoch != -1;
    }
    die("cannot parse ".$option." '".$spec."', expected 'YYYY-MM-DD[ HH:MM[:SS]]', an epoch or a relative value like '30d'\n");
}

##########################################################
# accepts seconds or duration specifications like 1d, 12h
sub parse_duration_spec {
    my($spec) = @_;
    return DEFAULT_CHUNK if !defined $spec;
    if($spec =~ m/^(\d+)([smhdwMy])$/mx) {
        return $1 * duration_seconds($2);
    }
    die("cannot parse duration '$spec', expected seconds or e.g. '1d'\n") if $spec !~ m/^\d+$/mx;
    return int($spec);
}

sub duration_seconds {
    my($unit) = @_;
    my %seconds = (
        's' => 1,
        'm' => 60,
        'h' => 3600,
        'd' => 86400,
        'w' => 604800,
        'M' => 2592000,     # 30 days
        'y' => 31536000,    # 365 days
    );
    die("unknown duration unit '".$unit."'\n") if !defined $seconds{$unit};
    return $seconds{$unit};
}

##########################################################
sub quote_identifier {
    my($engine, $name) = @_;
    if($engine eq 'mysql') {
        $name =~ s/`/``/mxg;
        return '`'.$name.'`';
    }
    $name =~ s/"/""/mxg;
    return '"'.$name.'"';
}

sub redact_password {
    my($dsn) = @_;
    $dsn =~ s/;?\bpassword=[^;]*/;password=***/mxg;
    return $dsn;
}

sub format_time {
    my($epoch) = @_;
    return '-' if !defined $epoch;
    return scalar localtime($epoch);
}

sub info {
    my($message) = @_;
    print STDERR '[logcache-export] '.$message."\n" if !$opt{'quiet'};
    return;
}

##########################################################
sub usage {
    my($code, $error) = @_;
    print STDERR "ERROR: ".$error."\n\n" if defined $error;
    print STDERR <<'END_USAGE';
export a Thruk logcache (mysql/mariadb or postgresql) into a logfile which can
be imported again with: thruk logcache import --local -b <peer> -y <file>

usage: thruk_logcache_export.pl --dsn <dsn> --prefix <peer> [options]

  -d, --dsn <dsn>       mysql://user:password@host:port/database
                        mysql://user:password@/path/to/mysqld.sock/database
                        postgresql://user:password@host:port/database
                        postgresql://user:password@/path/to/socketdir/database
                        or a DBI:mysql:/DBI:Pg: connection string
                        the engine is detected from the dsn
                        can also be set with THRUK_LOGCACHE_DSN
                        url-encode special characters in user/password
  -u, --user <user>     database user (alternative to user:password in the dsn)
      --password <pw>   database password (alternative to user:password in the dsn)
  -p, --prefix <peer>   logcache peer key, that is the prefix of the tables
      --list            list all logcaches in that database and exit
      --count           only count the entries in the selected range and exit
  -s, --from <time>     export entries at or after this time (default: first entry)
  -e, --to <time>       export entries before this time (default: after last entry)
                        time formats: 2025-10-01, '2025-10-01 12:30', epoch seconds
                        or relative values in the past: 30d, 12h, 90m
  -o, --out <file>      write to this file, '-' for stdout (default: -)
  -C, --chunk <dur>     export in chunks of this size (default: 1d) to keep
                        memory usage low on large logcaches
  -q, --quiet           no progress messages on stderr
  -h, --help            this help

examples:

  # what is in the database?
  ./thruk_logcache_export.pl -d 'mysql://thruk:secret@localhost:3306/thruk_logs' --list
  ./thruk_logcache_export.pl -d 'postgresql://thruk:secret@localhost:5432/thruk_logs' --list

  # how much would that be?
  ./thruk_logcache_export.pl -d '...' -p mon --from 30d --count

  # export and pack for transfer
  ./thruk_logcache_export.pl -d '...' -p mon --from 2025-10-01 -o /tmp/mon.log
  tar -czf /tmp/mon.log.tar.gz -C /tmp mon.log

  # export directly through gzip
  ./thruk_logcache_export.pl -d '...' -p mon --from 30d -o - | gzip -9 > mon.log.gz

END_USAGE
    exit($code);
}
