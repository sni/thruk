package Thruk::Backend::Provider::Mysql;

use warnings;
use strict;
use Carp qw/confess/;
use Data::Dumper qw/Dumper/;
use Module::Load qw/load/;
use Time::HiRes qw/gettimeofday tv_interval/;

use Thruk::Timer qw/timing_breakpoint/;
use Thruk::Utils ();
use Thruk::Utils::Log qw/:all/;

use parent 'Thruk::Backend::Provider::DBcommon';

=head1 NAME

Thruk::Backend::Provider::Mysql - connection provider for Mysql connections

=head1 DESCRIPTION

connection provider for Mysql connections

=head1 METHODS

=cut

## no lint
# backward-compat aliases so callers using the package-variable form still work
{ no warnings 'once'; ## no critic (ProhibitNoWarnings)
*Thruk::Backend::Provider::Mysql::cache_version = \$Thruk::Backend::Provider::DBcommon::cache_version;
*Thruk::Backend::Provider::Mysql::db_types      = \$Thruk::Backend::Provider::DBcommon::db_types;
*Thruk::Backend::Provider::Mysql::db_classes     = \$Thruk::Backend::Provider::DBcommon::db_classes;
*Thruk::Backend::Provider::Mysql::tables         = \@Thruk::Backend::Provider::DBcommon::tables;
}
## use lint

##########################################################

=head2 new

create new manager

=cut
sub new {
    my($class, $peer_config) = @_;

    my $options = $peer_config->{'options'};
    confess('need at least one peer. Minimal options are <options>peer = mysql://user:password@host:port/dbname</options>'."\ngot: ".Dumper($peer_config)) unless defined $options->{'peer'};

    $options->{'name'} = 'mysql' unless defined $options->{'name'};
    if(!defined $options->{'peer_key'}) {
        confess('please provide peer_key');
    }
    my($dbhost, $dbport, $dbuser, $dbpass, $dbname, $dbsock);
    if($options->{'peer'} =~ m/^mysql:\/\/(.*?)(|:.*?)@([^:]+)(|:.*?)\/([^\/]*?)$/mx) {
        $dbuser = $1;
        $dbpass = $2;
        $dbhost = $3;
        $dbport = $4;
        $dbname = $5;
        $dbpass =~ s/^://gmx;
        $dbport =~ s/^://gmx;
        if($dbhost =~ m|/|mx) {
            $dbsock = $dbhost;
            $dbhost = 'localhost';
        }
    } else {
        die('Mysql connection must match this form: mysql://user:password@host:port/dbname');
    }

    my $self = {
        'dbhost'      => $dbhost,
        'dbport'      => $dbport,
        'dbname'      => $dbname,
        'dbuser'      => $dbuser,
        'dbpass'      => $dbpass,
        'dbsock'      => $dbsock,
        'peer_config' => $options,
        'verbose'     => 0,
    };
    bless $self, $class;

    return $self;
}

##########################################################
# DB-specific driver identification

sub _driver_name { return 'Mysql' }
sub _db_handle_name { return 'mysql' }
sub _quote_char { return '`' }

##########################################################
# DB-specific quoting

sub _quote {
    my($self, $val) = @_;
    return 'NULL' unless defined $val;
    if(ref $val eq 'ARRAY') {
        return [ map { $self->_quote($_) } @{$val} ];
    }
    if($val =~ m/^\-?(\d+|\d+\.\d+)$/mx) {
        return $val;
    }
    $val =~ s/'/\\'/gmx;
    return "'".$val."'";
}

##########################################################
# MySQL backslash quoting (used in LIKE patterns)
sub _quote_backslash {
    my($self, $val) = @_;
    $val =~ s/\\/\\\\/gmx;
    return $val;
}

##########################################################

=head2 _dbh

try to connect to database and return database handle

=cut
sub _dbh {
    my($self) = @_;
    if(!defined $self->{'mysql'} || $self->{'mysql'}->ping()) {
        &timing_breakpoint('connecting '.$self->{'dbname'}.' '.($self->{'dbsock'} || $self->{'dbhost'}).($self->{'dbport'} ? ':'.$self->{'dbport'} : ''));
        if(!$self->{'modules_loaded'}) {
            load DBI;
            load File::Temp, qw/tempfile/;
            load Encode, qw/encode_utf8/;
            $self->{'modules_loaded'} = 1;
        }
        my $dsn = "DBI:mysql:database=".$self->{'dbname'}.";host=".$self->{'dbhost'};
        $dsn .= ";port=".$self->{'dbport'} if $self->{'dbport'};
        $dsn .= ";mysql_socket=".$self->{'dbsock'} if $self->{'dbsock'};
        $dsn .= ";mysql_ssl=0";
        $self->{'mysql'} = DBI->connect_cached($dsn, $self->{'dbuser'}, $self->{'dbpass'}, {RaiseError => 1, AutoCommit => 0, mysql_enable_utf8 => 1, mysql_local_infile => 1});
        $self->{'mysql'}->do("SET NAMES utf8 COLLATE utf8_bin");
        $self->{'mysql'}->do("SET myisam_stats_method=nulls_ignored");
        &timing_breakpoint('connected');
    }
    return $self->{'mysql'};
}

##########################################################
# MySQL-specific auto-increments

sub _get_autoincrements {
    my($self, $dbh, $prefix) = @_;
    my $auto_increments = $dbh->selectall_hashref(
        'SELECT
            TABLE_NAME,
            AUTO_INCREMENT
         FROM
            INFORMATION_SCHEMA.TABLES
         WHERE
            TABLE_SCHEMA = Database()
            AND TABLE_NAME LIKE "%'.$prefix.'_%"
        ', 'TABLE_NAME');
    return($auto_increments);
}

##########################################################

sub _check_index {
    my($self, $c, $dbh, $prefix) = @_;
    $c->stats->profile(begin => "update index statistics");
    _debugs("running check/analyse...");

    my $data = $dbh->selectall_hashref("SHOW INDEXES FROM `".$prefix."_log`", "Key_name");
    if($data && $data->{'host_id'}) {
        if(exists $data->{'host_id'}->{'Cardinality'} && !defined $data->{'host_id'}->{'Cardinality'}) {
            _warn("table index was disabled, enabling...");
            $self->_enable_index($dbh, $prefix);
            _warn("done.");
        }
        my($hostcount) = @{$dbh->selectcol_arrayref("SELECT COUNT(*) as total FROM `".$prefix."_host`")};
        if(!$hostcount || !$data->{'host_id'}->{'Cardinality'} || $data->{'host_id'}->{'Cardinality'} < $hostcount * 5) {
            $c->stats->profile(end => "update index statistics");
            _debug("not required");
            return;
        }
    }

    for my $table (@{$self->tables()}) {
        $dbh->do("ANALYZE TABLE `".$prefix."_".$table.'`');
        $dbh->do("CHECK TABLE `".$prefix."_".$table.'`');
    }
    _debug("done");
    $c->stats->profile(end => "update index statistics");
    return;
}

##########################################################

sub _check_db_fs {
    my($self, $c, $peer, $prefix) =  @_;

    _debug2("[%s] checking required disk space", $prefix);

    # fetch mysql datadir
    my $dbh = $self->_dbh();
    my $res  = $dbh->selectall_arrayref("SHOW VARIABLES LIKE 'datadir'", { Slice => {} });
    if(scalar @{$res} != 1) {
        _debug2("[%s] cannot fetch datadir variable.", $prefix);
        return 1;
    }
    my $datadir = $res->[0]->{'Value'};

    # fetch mysql hostname
    $res  = $dbh->selectall_arrayref('SELECT @@hostname', { Slice => {} });
    if(scalar @{$res} != 1) {
        _debug2("[%s] cannot fetch hostname variable.", $prefix);
        return 1;
    }
    my $dbhost = $res->[0]->{'@@hostname'};

    _debug("[%s] db runs on %s with datadir %s", $prefix, $dbhost, $datadir);

    chomp(my $hostname = Thruk::Utils::IO::cmd("hostname"));
    chomp(my $fqdn     = Thruk::Utils::IO::cmd("hostname --fqdn"));

    # not on the same host, no chance to access the filesystem
    if($dbhost ne $hostname && $dbhost ne $fqdn) {
        _debug2("[%s] database is not on the same host, cannot check filesystem. (%s != %s)", $prefix, $dbhost, $fqdn);
        return 1;
    }

    # try to get free disk space
    my($rc, $diskspace) = Thruk::Utils::IO::cmd("df -k $datadir 2>&1"); # use -k to force 1k blocks
    if($rc != 0) {
        _debug2("[%s] cannot check filesystem available space: %s", $prefix, $diskspace);
        return 1;
    }
    chomp($diskspace);

    my @lines = split(/\n/mx, $diskspace);
    my(undef, undef, undef, $disk_available) = split(/\s+/mx, $lines[scalar @lines -1]);
    if(!$disk_available || $disk_available !~ m/^\d+$/mx) {
        _debug2("[%s] cannot check filesystem available space.", $prefix);
        return 1;
    }
    $disk_available = $disk_available * 1024;

    my @stats = $self->_log_stats($c, $prefix);
    if(scalar @stats != 1) {
        _debug2("[%s] cannot fetch log stats", $prefix);
        return 1;
    }

    # add 10% safety
    my $required = 1.1 * ($stats[0]->{'data_size'} + $stats[0]->{'index_size'});
    if($required > $disk_available) {
        _warn("[%s] not enough disk space for table optimization: required: %5.1f %2s, available: %5.1f %2s", $prefix, Thruk::Utils::reduce_number($required, "B"), Thruk::Utils::reduce_number($disk_available, "B"));
        return;
    }

    _info("[%s] disk space sufficient for table optimization: required: %5.1f %2s, available: %5.1f %2s", $prefix, Thruk::Utils::reduce_number($required, "B"), Thruk::Utils::reduce_number($disk_available, "B"));
    return 1;
}

##########################################################

sub _get_create_schema {
    my($self, $prefix) = @_;
    my @statements = (
    # contact
        "DROP TABLE IF EXISTS `".$prefix."_contact`",
        "CREATE TABLE `".$prefix."_contact` (
          contact_id mediumint(9) unsigned NOT NULL AUTO_INCREMENT,
          name varchar(150) NOT NULL,
          PRIMARY KEY (contact_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

    # contact_host_rel
        "DROP TABLE IF EXISTS `".$prefix."_contact_host_rel`",
        "CREATE TABLE `".$prefix."_contact_host_rel` (
          contact_id mediumint(9) unsigned NOT NULL,
          host_id mediumint(9) unsigned NOT NULL,
          PRIMARY KEY (contact_id,host_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

    # contact_service_rel
        "DROP TABLE IF EXISTS `".$prefix."_contact_service_rel`",
        "CREATE TABLE `".$prefix."_contact_service_rel` (
          contact_id mediumint(9) unsigned NOT NULL,
          service_id mediumint(9) unsigned NOT NULL,
          PRIMARY KEY (contact_id,service_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

    # host
        "DROP TABLE IF EXISTS `".$prefix."_host`",
        "CREATE TABLE `".$prefix."_host` (
          host_id mediumint(9) unsigned NOT NULL AUTO_INCREMENT,
          host_name varchar(150) NOT NULL,
          PRIMARY KEY (host_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

    # log
        "DROP TABLE IF EXISTS `".$prefix."_log`",
        "CREATE TABLE IF NOT EXISTS `".$prefix."_log` (
          log_id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
          time int(11) unsigned NOT NULL,
          class tinyint(4) unsigned NOT NULL,
          type enum('CURRENT SERVICE STATE','CURRENT HOST STATE','SERVICE NOTIFICATION','HOST NOTIFICATION','SERVICE ALERT','HOST ALERT','SERVICE EVENT HANDLER','HOST EVENT HANDLER','EXTERNAL COMMAND','PASSIVE SERVICE CHECK','PASSIVE HOST CHECK','SERVICE FLAPPING ALERT','HOST FLAPPING ALERT','SERVICE DOWNTIME ALERT','HOST DOWNTIME ALERT','LOG ROTATION','INITIAL HOST STATE','INITIAL SERVICE STATE','TIMEPERIOD TRANSITION') DEFAULT NULL,
          state tinyint(4) unsigned DEFAULT NULL,
          state_type enum('HARD','SOFT') DEFAULT NULL,
          contact_id mediumint(9) unsigned DEFAULT NULL,
          host_id mediumint(9) unsigned DEFAULT NULL,
          service_id mediumint(9) unsigned DEFAULT NULL,
          message mediumtext NOT NULL,
          PRIMARY KEY (log_id),
          KEY time (time),
          KEY host_id (host_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci PACK_KEYS=1",    # using utf8_bin here would break case-insensitive rlike queries

    # service
        "DROP TABLE IF EXISTS `".$prefix."_service`",
        "CREATE TABLE `".$prefix."_service` (
          service_id mediumint(9) unsigned NOT NULL AUTO_INCREMENT,
          host_id mediumint(9) unsigned NOT NULL,
          service_description varchar(150) NOT NULL,
          PRIMARY KEY (service_id),
          KEY host_id (host_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

    # status
        "DROP TABLE IF EXISTS `".$prefix."_status`",
        "CREATE TABLE `".$prefix."_status` (
          status_id smallint(6) unsigned NOT NULL AUTO_INCREMENT,
          name varchar(150) NOT NULL,
          value varchar(150) DEFAULT NULL,
          PRIMARY KEY (status_id)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",

        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(1, 'last_update', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(2, 'update_pid', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(3, 'last_reorder', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(4, 'cache_version', '".$Thruk::Backend::Provider::DBcommon::cache_version."')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(5, 'reorder_duration', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(6, 'update_duration', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(7, 'last_compact', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(8, 'compact_duration', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(9, 'compact_till', '')",
        "INSERT INTO `".$prefix."_status` (status_id, name, value) VALUES(10,'lock_mode', '')",
    );
    return \@statements;
}

##########################################################

sub _lock_table_share {
    my($self, $dbh, $prefix) = @_;
    $dbh->do('LOCK TABLES `'.$prefix.'_status` READ');
    return;
}

sub _lock_table_exclusive {
    my($self, $dbh, $prefix) = @_;
    $dbh->do('LOCK TABLES `'.$prefix.'_status` WRITE');
    return;
}

sub _release_write_locks {
    my($self, $dbh) = @_;
    $dbh->do('UNLOCK TABLES');
    return;
}

##########################################################

sub _update_status {
    my($self, $dbh, $prefix, $status_id, $name, $val, $val2) = @_;
    $val2 //= $val;
    if(defined $val && $val =~ m/^\d+$/mx) {
        $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES($status_id,'$name','$val') ON DUPLICATE KEY UPDATE value='$val2'");
    }
    elsif(defined $val) {
        $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES($status_id,'$name',".$dbh->quote($val).") ON DUPLICATE KEY UPDATE value=".$dbh->quote($val2));
    }
    else {
        $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES($status_id,'$name',NULL) ON DUPLICATE KEY UPDATE value=NULL");
    }
    return;
}

##########################################################

sub _finish_update {
    my($self, $c, $dbh, $prefix, $duration) = @_;
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(1,'last_update',UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE value=UNIX_TIMESTAMP()");
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(2,'update_pid',NULL) ON DUPLICATE KEY UPDATE value=NULL");
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(6,'update_duration','".$duration."') ON DUPLICATE KEY UPDATE value='".$duration."'");
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(10,'lock_mode','') ON DUPLICATE KEY UPDATE value=''");
    $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};
    $dbh->commit || return;
    return 1;
}

##########################################################

sub _db_optimize_tables {
    my($self, $c, $peer, $prefix, $disk_space_ok) = @_;
    my $dbh = $peer->logcache->_dbh;

    if($disk_space_ok) {
        my $t1 = [gettimeofday];
        _infos("update %s logs table order...", $prefix);
        $dbh = $peer->logcache->_dbh; # reconnect
        $dbh->do("ALTER TABLE `".$prefix."_log` ORDER BY time");
        $dbh->commit || confess $dbh->errstr;
        _info("done. (duration: %s)", Thruk::Utils::Filter::duration(tv_interval($t1), 6));
    }

    unless($c->config->{'logcache_pxc_strict_mode'}) {
        # repair / optimize tables
        $dbh = $peer->logcache->_dbh; # reconnect

        _debug("optimizing / repairing tables");
        for my $table (@{$self->tables()}) {
            my $t1 = [gettimeofday];
            _infos('maintain table %20s...', $table);
            _infos(', check...');
            my $res = $dbh->selectall_arrayref("CHECK TABLE `".$prefix."_".$table.'`', { Slice => {} });
            if(!$res || !$res->[0] || $res->[0]->{"Msg_text"} ne 'OK') {
                _infos('running repair, check returned: %s', $res->[0]->{"Msg_text"});
                $dbh->do("REPAIR TABLE `".$prefix."_".$table.'`');
            }
            if($disk_space_ok && $table ne 'log') { # log table is optimized by the alter table order by... already
                _infos(', optimize...');
                $dbh->do("OPTIMIZE TABLE `".$prefix."_".$table.'`');
            }
            _infos(', analyze...');
            $dbh->do("ANALYZE TABLE `".$prefix."_".$table.'`');
            _info("OK. (duration: %s)", Thruk::Utils::Filter::duration(tv_interval($t1), 6));
        }
    }
    return;
}

##########################################################

sub _disable_index {
    my($self, $dbh, $prefix) = @_;
    &timing_breakpoint('_import_peer_logfiles disable index');
    $dbh->do('SET foreign_key_checks = 0');
    $dbh->do('SET unique_checks = 0');
    $dbh->do('ALTER TABLE `'.$prefix.'_log` DISABLE KEYS');
    return;
}

sub _enable_index {
    my($self, $dbh, $prefix) = @_;
    &timing_breakpoint('_import_peer_logfiles enable index');
    $dbh->do('SET foreign_key_checks = 1');
    $dbh->do('SET unique_checks = 1');
    $dbh->do('ALTER TABLE `'.$prefix.'_log` ENABLE KEYS');
    for my $table (@{$self->tables()}) {
        $dbh->do("ANALYZE TABLE `".$prefix."_".$table.'`');
        $dbh->do("CHECK TABLE `".$prefix."_".$table.'`');
    }
    return;
}

##########################################################

sub _sql_extra_columns { return ', SUBSTRING_INDEX(l.message, \': \', 1) as plugin_output' }

sub _sql_coalesce {
    my($self, $col, $default) = @_;
    return "IFNULL($col, $default)";
}

sub _sql_show_indexes {
    my($self, $prefix) = @_;
    return "SHOW INDEXES FROM `".$prefix."_log`";
}

sub _sql_show_tables {
    my($self) = @_;
    return 'SHOW TABLES';
}

sub _sql_tables_exist {
    my($self, $prefix) = @_;
    return ('SHOW TABLES LIKE "'.$prefix.'\_%"', []);
}

sub _sql_insert_on_conflict {
    my($self) = @_;
    return '';
}

sub _sql_drop_table_cascade {
    my($self) = @_;
    return '';
}

sub _sql_regex_operator {
    my($self, $op, $val) = @_;
    if($op eq '~' || $op eq '~~') {
        return 'RLIKE '.$self->_quote($val);
    }
    if($op eq '!~~') {
        return 'NOT RLIKE '.$self->_quote($val);
    }
    return '= '.$self->_quote($val);
}

##########################################################

sub _db_table_stats {
    my($self, $dbh, $prefix) = @_;
    my($index_size, $data_size, $items, $status, $msg);
    eval {
        my $res = $dbh->selectall_arrayref("SELECT SUM(index_length) as index_size, SUM(data_length) as data_size, SUM(table_rows) as items FROM information_schema.TABLES WHERE table_schema=Database() AND table_name LIKE '".$prefix."_%'", { Slice => {} });
        if($res && $res->[0]) {
            $index_size = $res->[0]->{'index_size'};
            $data_size  = $res->[0]->{'data_size'};
            $items      = $res->[0]->{'items'};
        }
        $status = $dbh->selectall_hashref("SELECT name, value FROM `".$prefix."_status`", 'name');
        $status->{'cache_version'}->{'value'} //= '';
    };
    if($@) {
        chomp(my $err = $@);
        $msg = $err;
    }
    return($index_size, $data_size, $items, $status, $msg);
}

##########################################################

sub _has_log_table {
    my($self, $dbh, $prefix) = @_;
    my @tables = @{$dbh->selectcol_arrayref('SHOW TABLES LIKE "'.$prefix.'_log"')};
    return scalar @tables >= 1 ? 1 : 0;
}

sub _get_all_table_names {
    my($self, $dbh) = @_;
    return $dbh->selectcol_arrayref('SHOW TABLES');
}

sub _use_load_data_infile {
    my($self, $mode) = @_;
    return $mode == Thruk::Backend::Provider::DBcommon::MODE_IMPORT() ? 1 : 0;
}

##########################################################
sub _get_log_host_auth {
    my($self,$dbh, $prefix, $contact) = @_;
    my @hosts = @{$dbh->selectall_arrayref("SELECT h.host_name FROM `".$prefix."_host` h, `".$prefix."_contact_host_rel` chr, `".$prefix."_contact` c WHERE h.host_id = chr.host_id AND c.contact_id = chr.contact_id AND c.name = ".$dbh->quote($contact))};
    my $hosts_lookup = {};
    for my $h (@hosts) { $hosts_lookup->{$h->[0]} = 1; }
    return $hosts_lookup;
}

##########################################################
sub _get_log_service_auth {
    my($self,$dbh, $prefix, $contact) = @_;

    # Select all Services where the host is allowed by contact
    my $sql1 = "SELECT h.host_name, s.service_description
               FROM
                 `".$prefix."_service` s,
                 `".$prefix."_host` h,
                 `".$prefix."_contact_host_rel` chr,
                 `".$prefix."_contact` c1,
                 `".$prefix."_contact_service_rel` csr
               WHERE
                 s.host_id = h.host_id
                 AND h.host_id = chr.host_id
                 AND c1.contact_id = chr.contact_id
                 AND s.service_id = csr.service_id
                 AND c1.name = ".$dbh->quote($contact)
               ;
    # Select all Services which are directly allowed by contact
    my $sql2 = "SELECT h.host_name, s.service_description
               FROM
                 `".$prefix."_service` s,
                 `".$prefix."_host` h,
                 `".$prefix."_contact_host_rel` chr,
                 `".$prefix."_contact` c1,
                 `".$prefix."_contact_service_rel` csr
               WHERE
                 s.host_id = h.host_id
                 AND h.host_id = chr.host_id
                 AND c1.contact_id = csr.contact_id
                 AND s.service_id = csr.service_id
                 AND c1.name = ".$dbh->quote($contact)
                ;
    my $services1        = $dbh->selectall_arrayref($sql1);
    my $services2        = $dbh->selectall_arrayref($sql2);
    # Make them unique
    my $services_lookup = {};
    for my $s (@{$services1}) { $services_lookup->{$s->[0]}->{$s->[1]} = 1; }
    for my $s (@{$services2}) { $services_lookup->{$s->[0]}->{$s->[1]} = 1; }
    return $services_lookup;
}

##########################################################

=head2 set_verbose

  set_verbose($val)

sets verbose mode

=cut
sub set_verbose {
    my($self, $val) = @_;
    my $old = $self->{'verbose'};
    $self->{'verbose'} = $val;
    return($old);
}

##########################################################

=head2 renew_logcache

=cut
sub renew_logcache {
    return;
}

##########################################################

=head2 get_logs

  get_logs

returns logfile entries

=cut

=head2 get_logs_start_end

  get_logs_start_end

returns first and last logfile timestamp

=cut

##########################################################

=head2 get_timeperiods

=cut
sub get_timeperiods {
    confess("not implemented");
}

##########################################################

=head2 get_timeperiod_names

=cut
sub get_timeperiod_names {
    confess("not implemented");
}

##########################################################

=head2 get_commands

=cut
sub get_commands {
    confess("not implemented");
}

##########################################################

=head2 get_contacts

=cut
sub get_contacts {
    confess("not implemented");
}

##########################################################

=head2 get_contact_names

=cut
sub get_contact_names {
    confess("not implemented");
}

##########################################################

=head2 get_host_stats

=cut
sub get_host_stats {
    confess("not implemented");
}

##########################################################

=head2 get_host_totals_stats

=cut
sub get_host_totals_stats {
    confess("not implemented");
}

##########################################################

=head2 get_host_less_stats

=cut
sub get_host_less_stats {
    confess("not implemented");
}

##########################################################

=head2 get_service_stats

=cut
sub get_service_stats {
    confess("not implemented");
}

##########################################################

=head2 get_service_totals_stats

=cut
sub get_service_totals_stats {
    confess("not implemented");
}

##########################################################

=head2 get_service_less_stats

=cut
sub get_service_less_stats {
    confess("not implemented");
}

##########################################################

=head2 get_performance_stats

=cut
sub get_performance_stats {
    confess("not implemented");
}

##########################################################

=head2 get_extra_perf_stats

=cut
sub get_extra_perf_stats {
    confess("not implemented");
}

##########################################################

=head2 get_contact_totals_stats

=cut
sub get_contact_totals_stats {
    confess("not implemented");
}

##########################################################
sub _import_logs {
    my($self, $c, $mode, $backends, $blocksize, $options) = @_;
    my $files = $options->{'files'} || [];
    $c->stats->profile(begin => "Mysql::_import_logs($mode)");

    my $forcestart;
    if($options->{'start'}) {
        require Thruk::Utils::DateTime;
        $forcestart = Thruk::Utils::DateTime::parse_date($c, $options->{'start'});
    }

    my $backend_count = 0;
    my $log_count     = 0;
    my $errors        = [];
    ($backends)       = $c->db->select_backends('get_logs') unless defined $backends;
    $backends         = Thruk::Base::list($backends);
    my $total         = scalar @{$backends};
    my $num           = 0;
    my $sp            = length("$total");

    for my $prefix (@{$backends}) {
        $num++;
        my $peer = $c->db->get_peer_by_key($prefix);
        if(!$peer) {
            _error("error: no such backend: %s", $prefix);
            push @{$errors}, "no such backend: ".$prefix;
            next;
        }
        if(!$peer->{'logcache'}) {
            _debug("skipping backend: ".$prefix." (logcache is disabled)");
            next;
        }
        $peer->logcache->reconnect();
        my $dbh = $peer->logcache->_dbh;
        $backend_count++;

        _infos("[%0".$sp."d/%0".$sp."d] %sing %s logcache... ", $num, $total, $mode, $prefix);

        my $count = 0;
        eval {
            if($mode eq 'update' || $mode eq 'import') {
                $count = $peer->logcache->_update_logcache($c, $mode, $peer, $dbh, $prefix, $blocksize, $files, $forcestart);
            }
            elsif($mode eq 'clean') {
                my $tmp = $peer->logcache->_update_logcache($c, $mode, $peer, $dbh, $prefix, $blocksize, $files, $forcestart);
                $log_count = [0,0] unless ref $log_count eq 'ARRAY';
                if(ref $tmp eq 'ARRAY') {
                    $log_count->[0] += $tmp->[0];
                    $log_count->[1] += $tmp->[1];
                }
            }
            elsif($mode eq 'compact') {
                my $tmp = $peer->logcache->_update_logcache($c, $mode, $peer, $dbh, $prefix, $blocksize, $files, $forcestart, $options->{'force'});
                $log_count = [0,0] unless ref $log_count eq 'ARRAY';
                if(ref $tmp eq 'ARRAY') {
                    $log_count->[0] += $tmp->[0];
                    $log_count->[1] += $tmp->[1];
                }
            }
            elsif($mode eq 'drop') {
                $peer->logcache->_update_logcache($c, $mode, $peer, $dbh, $prefix, $blocksize, $files, $forcestart);
            }
            elsif($mode eq 'authupdate') {
                $count = $peer->logcache->_update_logcache_auth($c, $peer, $dbh, $prefix);
            }
            elsif($mode eq 'optimize') {
                $count = $peer->logcache->_update_logcache_optimize($c, $peer, $prefix, $options);
            } else {
                die("unknown mode: ".$mode."\n");
            }
            $log_count += $count if($count && $count > 0);
        };
        my $err = $@;
        if($err) {
            _debug($err);
            if($err =~ m/(.*\Qplease come back later\E)/mx) {
                _warn(sprintf("skipping %s, remote site is currently running an cache import, please try again later.", $peer->{'name'}));
                push @{$errors}, ""; # count it as failed
            } else {
                push @{$errors}, $err;
            }
        }

        # cleanup connection
        eval {
            $peer->logcache->_disconnect();
        };
    }

    our $global_lock_created;
    if($global_lock_created) {
        unlink($c->config->{'tmp_path'}."/logcache_import.lock");
    }

    $c->stats->profile(end => "Mysql::_import_logs($mode)");
    return($backend_count, $log_count, $errors);
}

##########################################################
sub _update_logcache {
    my($self, $c, $mode, $peer, $dbh, $prefix, $blocksize, $files, $forcestart,$force) = @_;

    &timing_breakpoint('_update_logcache');
    unless(defined $blocksize) {
        $blocksize = 86400;
        if($mode eq 'clean') {
            $blocksize = Thruk::Utils::expand_duration($c->config->{'logcache_clean_duration'}) / 86400;
        }
        if($mode eq 'compact') {
            $blocksize = Thruk::Utils::expand_duration($c->config->{'logcache_compact_duration'}) / 86400;
        }
    }

    if($mode eq 'drop') {
        $self->_drop_tables($dbh, $prefix);
        return;
    }

    # check tables
    $self->_drop_tables($dbh, $prefix) if $mode eq 'import';
    my $fresh_created = 0;
    if($self->_create_tables_if_not_exist($dbh, $prefix)) {
        $fresh_created = 1;
    }

    return(-1) unless $self->_check_lock($dbh, $prefix, $c, $mode);
    my $start = time();

    if($mode eq 'clean') {
        my $res = $self->_update_logcache_clean($c, $dbh, $prefix, $blocksize);
        $self->_finish_update($c, $dbh, $prefix, time() - $start);
        return($res);
    }
    if($mode eq 'compact') {
        my $res = $self->_update_logcache_compact($c, $dbh, $prefix, $blocksize, $force);
        $self->_finish_update($c, $dbh, $prefix, time() - $start);
        return($res);
    }

    $mode = 'import' if $fresh_created;

    my $log_count = 0;
    eval {
        my $host_lookup    = $self->_get_host_lookup(   $dbh,$peer,$prefix,               $mode eq 'import' ? 0 : 1);
        my $service_lookup = $self->_get_service_lookup($dbh,$peer,$prefix, $host_lookup, $mode eq 'import' ? 0 : 1);
        my $contact_lookup = $self->_get_contact_lookup($dbh,$peer,$prefix,               $mode eq 'import' ? 0 : 1);

        if(defined $files && scalar @{$files} > 0) {
            $log_count += $self->_import_logcache_from_file($mode,$dbh,$files,$host_lookup,$service_lookup,$prefix,$contact_lookup,$c);
        } else {
            $log_count += $self->_import_peer_logfiles($c,$mode,$peer,$blocksize,$dbh,$host_lookup,$service_lookup,$prefix,$contact_lookup,$forcestart);
        }

        if($mode eq 'import') {
            _debug2("updateing auth cache");
            $self->_update_logcache_auth($c, $peer, $dbh, $prefix);
        }
    };
    my $error = $@ || '';

    $self->_finish_update($c, $dbh, $prefix, time() - $start) or $error .= $dbh->errstr;

    if($error) {
        my($short_err, undef) = Thruk::Utils::extract_connection_error($error);
        if(defined $short_err) {
            _debug($error);
            $error = $short_err;
        }
        _cronerror('logcache '.$mode.' failed: '._strip_line($error)); # don't fill the log with errors from cronjobs
        die($error);
    }

    return $log_count;
}

##########################################################

sub _create_tables_if_not_exist {
    my($self, $dbh, $prefix) = @_;

    return if $self->_tables_exist($dbh, $prefix);

    _debug2("creating logcache tables");
    $self->_create_tables($dbh, $prefix);
    return 1;
}

sub _create_tables {
    my($self, $dbh, $prefix) = @_;
    for my $stm (@{$self->_get_create_schema($prefix)}) {
        $dbh->do($stm);
    }
    $dbh->commit || confess $dbh->errstr;
    return;
}

##########################################################
sub _check_lock {
    my($self, $dbh, $prefix, $c, $mode) = @_;

    # import locks all other operations
    return unless check_global_lock($c);

    # check if there is already a update / import running
    my $skip          = 0;
    eval {
        $self->_lock_table_share($dbh, $prefix) unless $c->config->{'logcache_pxc_strict_mode'};
        my @pids = @{$dbh->selectcol_arrayref('SELECT value FROM `'.$prefix.'_status` WHERE status_id = 2 LIMIT 1')};
        if(scalar @pids > 0 and $pids[0]) {
            if(kill(0, $pids[0])) {
                _info("WARNING: logcache update already running with pid ".$pids[0]);
                $skip = 1;
            }
        }
    };
    $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};
    if($@) {
        _debug($@);
        return;
    }
    if($skip) {
        return;
    }

    $self->_lock_table_exclusive($dbh, $prefix) unless $c->config->{'logcache_pxc_strict_mode'};
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(1,'last_update',UNIX_TIMESTAMP()) ON DUPLICATE KEY UPDATE value=UNIX_TIMESTAMP()");
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(2,'update_pid',".$$."  ) ON DUPLICATE KEY UPDATE value=".$$);
    $dbh->do("INSERT INTO `".$prefix."_status` (status_id,name,value) VALUES(10,'lock_mode','".$mode."') ON DUPLICATE KEY UPDATE value='".$mode."'");
    $dbh->commit || confess $dbh->errstr;
    $self->_release_write_locks($dbh) unless $c->config->{'logcache_pxc_strict_mode'};

    if(($mode eq 'import' || $ENV{'THRUK_CRON'}) && !-f $c->config->{'tmp_path'}."/logcache_import.lock") {
        our $global_lock_created = 1;
        Thruk::Utils::IO::write($c->config->{'tmp_path'}."/logcache_import.lock", $$);
    }

    return(1);
}

##########################################################

=head2 check_global_lock

  check_global_lock($c)

returns true if no global lock exists

=cut

sub check_global_lock {
    my($c) = @_;
    # import locks all other operations
    my $pid = Thruk::Utils::IO::saferead($c->config->{'tmp_path'}."/logcache_import.lock");
    if($pid && $pid != $$) {
        if($pid && kill(0, $pid)) {
            _info(sprintf("WARNING: logcache import currently running with pid %d", $pid));
            return;
        }
        _warn("WARNING: removing stale lock file: ".$c->config->{'tmp_path'}."/logcache_import.lock");
        unlink($c->config->{'tmp_path'}."/logcache_import.lock");
    }
    return(1);
}

##########################################################
sub _update_logcache_auth {
    my($self, undef, $peer, $dbh, $prefix) = @_;

    my $contact_lookup = $self->_get_contact_lookup($dbh,$peer,$prefix);
    my $host_lookup    = $self->_get_host_lookup($dbh,$peer,$prefix);
    my $service_lookup = $self->_get_service_lookup($dbh,$peer,$prefix,$host_lookup);

    # update hosts
    my($hosts) = $peer->{'class'}->get_hosts(columns => [qw/name contacts/]);
    _debugs("hosts: ");
    my $stm = "INSERT INTO `".$prefix."_contact_host_rel` (contact_id, host_id) VALUES";
    $dbh->do("TRUNCATE TABLE `".$prefix."_contact_host_rel`");
    my $count = 0;
    for my $host (@{$hosts}) {
        my $host_id = $self->_host_lookup($host_lookup, $host->{'name'}, $dbh, $prefix);
        my @values;
        for my $contact (@{Thruk::Base::array_uniq($host->{'contacts'})}) {
            my $contact_id = $self->_contact_lookup($contact_lookup, $contact, $dbh, $prefix);
            push @values, '('.$contact_id.','.$host_id.')';
        }
        $dbh->do($stm.join(',', @values)) if scalar @values > 0;
        $count++;
        _debugc(".") if $count%100 == 0;
    }
    _debug("done");

    # update services
    _debugs("services: ");
    $dbh->do("TRUNCATE TABLE `".$prefix."_contact_service_rel`");
    $stm = "INSERT INTO `".$prefix."_contact_service_rel` (contact_id, service_id) VALUES";
    my($services) = $peer->{'class'}->get_services(columns => [qw/host_name description contacts/]);
    $count = 0;
    for my $service (@{$services}) {
        my $service_id = $self->_service_lookup($service_lookup, $host_lookup, $service->{'host_name'}, $service->{'description'}, $dbh, $prefix);
        next unless $service_id;
        my @values;
        for my $contact (@{Thruk::Base::array_uniq($service->{'contacts'})}) {
            my $contact_id = $self->_contact_lookup($contact_lookup, $contact, $dbh, $prefix);
            push @values, '('.$contact_id.','.$service_id.')';
        }
        $dbh->do($stm.join(',', @values)) if scalar @values > 0;
        $count++;
        _debugc(".") if $count%1000 == 0;
    }

    _debug("done");

    $dbh->commit || confess $dbh->errstr;

    return(scalar @{$hosts} + scalar @{$services});
}

##########################################################
sub _get_host_lookup {
    my($self, $dbh, $peer, $prefix, $noupdate) = @_;

    my $sth = $dbh->prepare("SELECT host_id, host_name FROM `".$prefix."_host`");
    $sth->execute;
    my $hosts_lookup = {};
    for my $r (@{$sth->fetchall_arrayref()}) { $hosts_lookup->{$r->[1]} = $r->[0]; }
    return $hosts_lookup if $noupdate;

    my($hosts) = $peer->{'class'}->get_hosts(columns => [qw/name/]);
    my $stm = "INSERT INTO `".$prefix."_host` (host_name) VALUES";
    my @values;
    for my $h (@{$hosts}) {
        next if defined $hosts_lookup->{$h->{'name'}};
        push @values, '('.$dbh->quote($h->{'name'}).')';
    }
    if(scalar @values > 0) {
        for my $chunk (@{Thruk::Utils::array_chunk_fixed_size(\@values, 50)}) {
            $dbh->do($stm.join(',', @{$chunk}));
            $sth->execute;
        }
        for my $r (@{$sth->fetchall_arrayref()}) { $hosts_lookup->{$r->[1]} = $r->[0]; }
    }
    return $hosts_lookup;
}

##########################################################
sub _get_service_lookup {
    my($self, $dbh, $peer, $prefix, $hosts_lookup, $noupdate, $auto_increments, $foreign_key_stash) = @_;

    my $sth = $dbh->prepare("SELECT s.service_id, h.host_name, s.service_description FROM `".$prefix."_service` s, `".$prefix."_host` h WHERE s.host_id = h.host_id");
    $sth->execute;
    my $services_lookup = {};
    for my $r (@{$sth->fetchall_arrayref()}) { $services_lookup->{$r->[1]}->{$r->[2]} = $r->[0]; }
    return $services_lookup if $noupdate;

    my($services) = $peer->{'class'}->get_services(columns => [qw/host_name description/]);
    my $stm = "INSERT INTO `".$prefix."_service` (host_id, service_description) VALUES";
    my @values;
    for my $s (@{$services}) {
        next if defined $services_lookup->{$s->{'host_name'}}->{$s->{'description'}};
        my $host_id = $self->_host_lookup($hosts_lookup, $s->{'host_name'}, $dbh, $prefix, $auto_increments, $foreign_key_stash);
        push @values, '('.$host_id.','.$dbh->quote($s->{'description'}).')';
    }
    if(scalar @values > 0) {
        for my $chunk (@{Thruk::Utils::array_chunk_fixed_size(\@values, 50)}) {
            $dbh->do($stm.join(',', @{$chunk}));
            $sth->execute;
        }
        for my $r (@{$sth->fetchall_arrayref()}) { $services_lookup->{$r->[1]}->{$r->[2]} = $r->[0]; }
    }
    return $services_lookup;
}

##########################################################
sub _get_contact_lookup {
    my($self, $dbh, $peer, $prefix, $noupdate) = @_;

    my $sth = $dbh->prepare("SELECT contact_id, name FROM `".$prefix."_contact`");
    $sth->execute;
    my $contact_lookup = {};
    for my $r (@{$sth->fetchall_arrayref()}) { $contact_lookup->{$r->[1]} = $r->[0]; }
    return $contact_lookup if $noupdate;

    my($contacts) = $peer->{'class'}->get_contacts(columns => [qw/name/]);
    my $stm = "INSERT INTO `".$prefix."_contact` (name) VALUES";
    my @values;
    for my $c (@{$contacts}) {
        next if defined $contact_lookup->{$c->{'name'}};
        push @values, '('.$dbh->quote($c->{'name'}).')';
    }
    if(scalar @values > 0) {
        for my $chunk (@{Thruk::Utils::array_chunk_fixed_size(\@values, 50)}) {
            $dbh->do($stm.join(',', @{$chunk}));
            $sth->execute;
        }
        for my $r (@{$sth->fetchall_arrayref()}) { $contact_lookup->{$r->[1]} = $r->[0]; }
    }
    return $contact_lookup;
}

##########################################################
sub _host_lookup {
    my($self, $host_lookup, $host_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) = @_;
    return unless $host_name;

    my $id = $host_lookup->{$host_name};
    return $id if $id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_host'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'host'}}, '('.$id.', '.$dbh->quote($host_name).')';
        $host_lookup->{$host_name} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO `".$prefix."_host` (host_name) VALUES(".$dbh->quote($host_name).")");
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $host_lookup->{$host_name} = $id;

    return $id;
}

##########################################################
sub _service_lookup {
    my($self, $service_lookup, $host_lookup, $host_name, $service_description, $dbh, $prefix, $host_id, $auto_increments, $foreign_key_stash) = @_;
    return unless $service_description;
    return unless $host_name;

    my $id = $service_lookup->{$host_name}->{$service_description};
    return $id if $id;

    $host_id = $self->_host_lookup($host_lookup, $host_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) unless $host_id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_service'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'service'}}, '('.$id.', '.$host_id.','.$dbh->quote($service_description).')';
        $service_lookup->{$host_name}->{$service_description} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO `".$prefix."_service` (host_id, service_description) VALUES(".$host_id.", ".$dbh->quote($service_description).")");
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $service_lookup->{$host_name}->{$service_description} = $id;

    return $id;
}

##########################################################
sub _contact_lookup {
    my($self, $contact_lookup, $contact_name, $dbh, $prefix, $auto_increments, $foreign_key_stash) = @_;
    return unless $contact_name;

    my $id = $contact_lookup->{$contact_name};
    return $id if $id;

    if($auto_increments) {
        $id = $auto_increments->{$prefix.'_contact'}->{'AUTO_INCREMENT'}++;
        push @{$foreign_key_stash->{'contact'}}, '('.$id.', '.$dbh->quote($contact_name).')';
        $contact_lookup->{$contact_name} = $id;
        return $id;
    }

    $dbh->do("INSERT INTO `".$prefix."_contact` (name) VALUES(".$dbh->quote($contact_name).")");
    $id = $dbh->last_insert_id(undef, undef, undef, undef);
    $contact_lookup->{$contact_name} = $id;

    return $id;
}


##########################################################

1;
