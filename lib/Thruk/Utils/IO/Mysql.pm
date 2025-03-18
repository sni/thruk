package Thruk::Utils::IO::Mysql;

=head1 NAME

Thruk::Utils::IO::Mysql - Store files in a mysql database

=head1 DESCRIPTION

Store files in a mysql database

=cut

use warnings;
use strict;
use Carp qw/confess/;
use Cpanel::JSON::XS ();
use Errno ();
use Time::HiRes qw/gettimeofday tv_interval/;

use Thruk::Backend::Provider::Mysql ();
use Thruk::Config 'noautoload';
use Thruk::Utils::IO ();
use Thruk::Utils::Log qw/:all/;

##############################################

my $table_name = 'thruk_var_files';

##############################################
# TODO:
#    - check stdout/stderr of jobs
#    - check reports log files
#    - check cron.log
#    - check why mtime has no milliseconds
##############################################
=head1 METHODS

=head2 new

    new($connection)

=cut
sub new {
    my($class, $connection) = @_;
    my $hdl = Thruk::Backend::Provider::Mysql->new({
        options => {
            peer_key => 'db_storage_driver',
            peer     => $connection,
        },
    });

    my $config = Thruk::Config::get_config();
    my $self = {
        'class'     => $hdl,
        'use_locks' => $config->{'logcache_pxc_strict_mode'},
    };
    bless $self, $class;
    $self->_create_tables_if_not_exist();
    return $self;
}

##############################################

=head2 reconnect

recreate database connection

=cut
sub reconnect {
    my($self) = @_;
    return($self->_disconnect());
}

##############################################

=head2 _disconnect

close database connection

=cut
sub _disconnect {
    my($self) = @_;
    return($self->{'class'}->_disconnect());
}

##############################################

=head2 _dbh

try to connect to database and return database handle

=cut
sub _dbh {
    my($self) = @_;
    return($self->{'class'}->_dbh);
}

##############################################
# returns 1 if tables have been newly created or undef if already exist
sub _create_tables_if_not_exist {
    my($self) = @_;

    return if $self->_tables_exist();

    _debug2("creating tables");
    $self->_create_tables();

    my $c = $Thruk::Globals::c;
    Thruk::Utils::IO::sync_db_fs($c, 'fs', 'db') if $c;
    return 1;
}

##############################################
# returns 1 if tables exist, undef if not
sub _tables_exist {
    my($self) = @_;

    # check if our tables exist
    my $dbh = $self->_dbh;
    my @tables = @{$dbh->selectcol_arrayref('SHOW TABLES LIKE "'.$table_name.'"')};
    if(scalar @tables >= 1) {
        return 1;
    }

    return;
}

##############################################
# returns 1 if tables exist, undef if not
sub _drop_tables {
    my($self) = @_;
    my $dbh = $self->_dbh;
    $dbh->do("DROP TABLE IF EXISTS `".$table_name."`") || confess $dbh->errstr;
    return;
}

##############################################
sub _create_tables {
    my($self) = @_;
    my $dbh = $self->_dbh;
    my @statements = (
        "DROP TABLE IF EXISTS `".$table_name."`",
        "CREATE TABLE `".$table_name."` (
          path varchar(255) NOT NULL,
          mtime decimal(14,3) DEFAULT NULL,
          permission varchar(5),
          content LONGTEXT,
          PRIMARY KEY (path)
        ) DEFAULT CHARSET=utf8 COLLATE=utf8_bin",
    );
    for my $stm (@statements) {
        $dbh->do($stm) || confess $dbh->errstr;
    }
    $dbh->commit || confess $dbh->errstr;
    return;
}

##############################################

=head2 close

not implemented

=cut
sub close {
    return 0;
}

##############################################

=head2 mkdir

not implemented

=cut
sub mkdir {
    return 1;
}

##############################################

=head2 mkdir_r

not implemented

=cut
sub mkdir_r {
    return 1;
}

##############################################

=head2 read

  read($path)

read file and return content

=cut
sub read {
    my($self, $path) = @_;
    my $data = $self->saferead($path);
    return($data) if defined $data;
    die("no such file: ".$path);
}

##############################################

=head2 read_decoded

  read_decoded($path)

read file and return decoded content

=cut
sub read_decoded {
    require Thruk::Utils::Encode;
    return Thruk::Utils::Encode::decode_any(&read(@_));
}

##############################################

=head2 saferead

  saferead($path)

read file and return content or undef in case it cannot be read

=cut
sub saferead {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    my $dbh  = $self->_dbh;
    my $data = $dbh->selectcol_arrayref("SELECT content FROM ".$table_name." WHERE path = ".$dbh->quote($path)." LIMIT 1");

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;
    return($data->[0]) if scalar @{$data} > 0;
    return;
}

##############################################

=head2 saferead_decoded

  saferead_decoded($path)

safe read file and return decoded content

=cut
sub saferead_decoded {
    require Thruk::Utils::Encode;
    return Thruk::Utils::Encode::decode_any(&saferead(@_));
}

##############################################

=head2 read_as_list

  read_as_list($path)

read file and return content as array

=cut
sub read_as_list {
    my($self, $path) = @_;

    my $data = $self->read($path);
    return(split/\n/mx, $data);
}

##############################################

=head2 saferead_as_list

  saferead_as_list($path)

read file and return content as array, return empty list if open fails

=cut
sub saferead_as_list {
    my($self, $path) = @_;
    my $data = $self->saferead($path);
    return(split/\n/mx, $data);
}

##############################################

=head2 write

  write($path, $content, [ $mtime ], [ $append ])

creates file and ensure permissions

=cut
sub write {
    my($self,$path,$content,$mtime,$append) = @_;
    my $t1 = [gettimeofday];

    my $dbh = $self->_dbh;

    if($mtime) {
        $mtime = 0 + $mtime;
    } else {
        $mtime = Time::HiRes::time();
    }

    $content = $dbh->quote($content);
    if($append) {
        $dbh->do("INSERT INTO ".$table_name." (path,content,mtime)"
                ." VALUES(".$dbh->quote($path).", ".$content.", ".$mtime.")"
                ." ON DUPLICATE KEY UPDATE mtime=".$mtime.",content=CONCAT(content, ".$content.")");
    } else {
        $dbh->do("INSERT INTO ".$table_name." (path,content,mtime)"
                ." VALUES(".$dbh->quote($path).", ".$content.", ".$mtime.")"
                ." ON DUPLICATE KEY UPDATE mtime=".$mtime.",content=".$content);
    }

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return 1;
}

##############################################

=head2 unlink

  unlink($path)

remove file

=cut
sub unlink {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    my $dbh = $self->_dbh;
    $dbh->do("DELETE FROM ".$table_name." WHERE path = ".$dbh->quote($path));

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return 1;
}


##############################################

=head2 move

  move($from, $to)

move file to new location

=cut

sub move {
    my($self, $from, $to) = @_;

    my $t1 = [gettimeofday];

    my $dbh = $self->_dbh;
    $dbh->do("UPDATE ".$table_name." SET path = ".$dbh->quote($to)." WHERE path = ".$dbh->quote($from));

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return 1;
}

##############################################

=head2 copy

  copy($from, $to)

copy file to new location

=cut

sub copy {
    my($self, $from, $to) = @_;

    my $t1 = [gettimeofday];

    my $data = &read($from);
    my $rc   = &write($to, $data);

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return($rc);
}

##############################################

=head2 file_exists

  file_exists($path)

returns true if the file exists

=cut

sub file_exists {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    my $dbh  = $self->_dbh;
    my $data = $dbh->selectcol_arrayref("SELECT path FROM ".$table_name." WHERE path = ".$dbh->quote($path)." LIMIT 1");

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;
    return(1) if scalar @{$data} > 0;
    ## no critic
    $! = &Errno::ENODATA;
    ## use critic
    return(0);
}

##############################################

=head2 folder_exists

  folder_exists($path)

returns true if the folder exists

=cut

sub folder_exists {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    $path =~ s/\/$//gmxo;

    my $dbh  = $self->_dbh;
    my $data = $dbh->selectcol_arrayref("SELECT path FROM ".$table_name." WHERE path LIKE '".$path."/%' LIMIT 1");

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;
    return(1) if scalar @{$data} > 0;
    ## no critic
    $! = &Errno::ENODATA;
    ## use critic
    return(0);
}

##############################################

=head2 file_not_empty

  file_not_empty($path)

returns true if the file exists and is not empty

=cut

sub file_not_empty {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    my $dbh  = $self->_dbh;
    my $data = $dbh->selectcol_arrayref("SELECT length(content) FROM ".$table_name." WHERE path = ".$dbh->quote($path)." AND content != '' LIMIT 1");

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;
    return($data->[0]) if scalar @{$data} > 0;
    ## no critic
    $! = &Errno::ENODATA;
    ## use critic
    return(0);
}

##############################################

=head2 stat

  stat($path)

returns (incomolete) stat of file. Basically only the mtime is returned

=cut

sub stat {
    my($self, $path) = @_;
    my $t1 = [gettimeofday];

    my $dbh  = $self->_dbh;
    my $data = $dbh->selectcol_arrayref("SELECT mtime FROM ".$table_name." WHERE path = ".$dbh->quote($path)." LIMIT 1");

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$ctime,$blksize,$blocks);

    my $mtime = 0;
    $mtime = ($data->[0]) if scalar @{$data} > 0;
    return((
        $dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,0+$mtime,$ctime,$blksize,$blocks,
    ));
}

##############################################

=head2 rmdir

  rmdir($path)

remove empty folder

=cut

sub rmdir {
    return;
}

##############################################

=head2 ensure_permissions

  ensure_permissions($mode, $path)

ensure permissions and ownership

=cut
sub ensure_permissions {
    my($self, $mode, $path) = @_;
    return if defined $ENV{'THRUK_NO_TOUCH_PERM'};

    if($mode eq 'file') {
        my $config = Thruk::Config::get_config();
        $mode = $config->{'mode_file'};
    }
    elsif($mode eq 'dir') {
        my $config = Thruk::Config::get_config();
        $mode = $config->{'mode_dir'};
    }

    my $dbh = $self->_dbh;
    $dbh->do("UPDATE ".$table_name." SET permission = ".$dbh->quote($mode)." WHERE path = ".$dbh->quote($path));

    return;
}

##############################################

=head2 file_rlock

  file_rlock($file)

locks files table in shared / readonly mode. Returns nothing

=cut
sub file_rlock {
    my($self, $file) = @_;

    return unless $self->{'use_locks'};

    my $t1 = [gettimeofday];

    alarm(10);
    local $SIG{'ALRM'} = sub { confess("timeout while trying to shared flock: ".$file."\n"); };

    my $retrys = 0;
    my $err;
    while($retrys < 3) {
        eval {
            alarm(10);
            $self->_dbh->do('LOCK TABLES '.$table_name.' READ') || confess('Cannot lock_sh file: '.$file.': '.$!);
        };
        $err = $@;
        alarm(0);
        if(!$err) {
            last;
        }
        $retrys++;
        Time::HiRes::sleep(0.5);
    }
    alarm(0);

    if($err) {
        die("failed to shared flock $file: $err");
    }

    if($retrys > 0) {
        _warn("got lock for ".$file." after ".$retrys." retries") unless $ENV{'TEST_IO_NOWARNINGS'};
    }

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_lock'} += $elapsed if $c;

    return;
}

##############################################

=head2 file_lock

  file_lock($file)

locks files table in read/write mode. Returns nothing

=cut
sub file_lock {
    my($self, $file, $mode) = @_;

    return unless $self->{'use_locks'};

    if($mode && $mode eq 'sh') { return $self->file_rlock($file); }

    my $t1 = [gettimeofday];
    alarm(20);
    local $SIG{'ALRM'} = sub { confess("timeout while trying to excl. flock: ".$file."\n"); };

    my $retrys    = 0;
    my $err;
    while($retrys < 3) {
        alarm(10);
        eval {
            $self->_dbh->do('LOCK TABLES '.$table_name.' WRITE') || confess('Cannot lock_ex file: '.$file.': '.$!);
        };
        $err = $@;
        alarm(0);
        if(!$err) {
            last;
        }
        $retrys++;
        Time::HiRes::sleep(0.5);
    }
    alarm(0);

    if($err) {
        die("failed to lock $file: $err");
    }

    if($retrys > 0) {
        _warn("got lock for ".$file." after ".$retrys." retries") unless $ENV{'TEST_IO_NOWARNINGS'};
    }

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_lock'} += $elapsed if $c;

    return;
}

##############################################

=head2 file_unlock

  file_unlock($file)

unlocks tables previously locked with file_lock exclusivly. Returns nothing.

=cut
sub file_unlock {
    my($self) = @_;

    return unless $self->{'use_locks'};

	eval {
        $self->_dbh->do('UNLOCK TABLES') unless $self->{'use_locks'};
    };
    my $err = $@;
    if($err) {
        _debug($err);
        return;
    }

    return;
}

##############################################

=head2 storable_store

  storable_store($data, $filename)

Uses Storable to store data to disk.

=cut

sub storable_store {
    my($self, $data, $file) = @_;
    my $serialized = Storable::freeze($data);
    return($self->write($file, $serialized));
}

##############################################

=head2 storable_retrieve

  storable_retrieve($file)

Uses Storable to retrieve data from disk.

=cut

sub storable_retrieve {
    my($self, $file) = @_;
    my $serialized = $self->read($file);
    if(!defined $serialized) {
        return;
    }
    return(Storable::thaw($serialized));
}

##############################################

=head2 json_store

  json_store($file, $data, $options)

stores data json encoded

$options can be {
    pretty                  => 0/1,         # don't write json into a single line and use human readable intendation
    tmpfile                 => <filename>   # use this tmpfile while writing new contents
    changed_only            => 0/1,         # only write the file if it has changed
    compare_data            => "...",       # use this string to compare for changed content
    skip_ensure_permissions => 0/1          # skip running ensure_permissions after write
    skip_validate           => 0/1          # skip file validation (author only)
    skip_config             => 0/1          # skip all steps which reqire thruk config
}

=cut
sub json_store {
    my($self, $file, $data, $options) = @_;

    if(defined $options && ref $options ne 'HASH') {
        confess("json_store options have been changed to hash.");
    }

    if($options->{'skip_config'}) {
        $options->{'skip_ensure_permissions'} = 1;
        $options->{'skip_validate'}           = 1;
    }

    my $json = Cpanel::JSON::XS->new->utf8;
    $json = $json->pretty if $options->{'pretty'};
    $json = $json->canonical; # keys will be randomly ordered otherwise
    $json = $json->convert_blessed;

    my $write_out;
    if($options->{'changed_only'}) {
        $write_out = $json->encode($data);
        if(defined $options->{'compare_data'}) {
            return 1 if $options->{'compare_data'} eq $write_out;
        }
        else {
            my $old = $self->read($file) // '';
            return 1 if $old eq $write_out;
        }
    }

    my $t1 = [gettimeofday];
    my $mtime = Time::HiRes::time();

    my $dbh = $self->_dbh;
    my $content = $dbh->quote($write_out || $json->encode($data));
    $dbh->do("INSERT INTO ".$table_name." (path,content,mtime) VALUES(".$dbh->quote($file).", ".$content.", ".$mtime.") ON DUPLICATE KEY UPDATE mtime=".$mtime.",content=".$content);

    if(!$options->{'skip_validate'}) {
        my $config = Thruk::Config::get_config();
        if($config->{'thruk_author'}) {
            eval {
                my $test = $json->decode($self->read($file));
            };
            my $err = $@;
            confess("json_store failed to write a valid file $file: ".$err) if $err;
        }
    }

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return 1;
}

##############################################

=head2 json_lock_store

  json_lock_store($file, $data, [$options])

stores data json encoded. options are passed to json_store.

=cut
sub json_lock_store {
    my($self, $file, $data, $options) = @_;
    eval {
        $self->file_lock($file);
        $self->json_store($file, $data, $options);
    };
    my $err = $@;
    $self->file_unlock();
    confess($err) if $err;
    return 1;
}

##############################################

=head2 json_retrieve

  json_retrieve($file)

retrieve json data

=cut
sub json_retrieve {
    my($self, $file) = @_;

    our $jsonreader;
    if(!$jsonreader) {
        $jsonreader = Cpanel::JSON::XS->new->utf8;
        $jsonreader->relaxed();
    }

    my $t1 = [gettimeofday];

    my($data, $content);
    $content = $self->saferead($file);
    $data    = $jsonreader->decode($content) if $content;

    my $elapsed = tv_interval($t1);
    my $c = $Thruk::Globals::c || undef;
    $c->stash->{'total_io_time'} += $elapsed if $c;

    return($data, $content) if wantarray;
    return $data;
}

##############################################

=head2 json_lock_retrieve

  json_lock_retrieve($file)

retrieve json data

=cut
sub json_lock_retrieve {
    my($self, $file) = @_;
    my($data);
    eval {
        $self->file_rlock($file);
        $data = $self->json_retrieve($file);
    };
    my $err = $@;
    $self->file_unlock();
    confess($err) if $err;
    return $data;
}

##############################################

=head2 json_lock_patch

  json_lock_patch($file, $patch_data, [$options])

update json data with locking. options are passed to json_store.

=cut
sub json_lock_patch {
    my($self, $file, $patch_data, $options) = @_;
    my($data);
    eval {
        $self->file_lock($file);
        $data = $self->json_patch($file, undef, $patch_data, $options);
    };
    my $err = $@;
    $self->file_unlock();
    confess($err) if $err;
    return $data;
}

##############################################

=head2 json_patch

  json_patch($file, unused, $patch_data, [$options])

update json data. options are passed to json_store.

=cut
sub json_patch {
    my($self, $file, undef, $patch_data, $options) = @_;
    if(defined $options && ref $options ne 'HASH') {
        confess("json_store options have been changed to hash.");
    }

    my($data, $content) = $self->json_retrieve($file);
    if(!defined $data) {
        if(!$options->{'allow_empty'}) {
            confess("attempt to patch empty file without allow_empty option: $file");
        }
        ($data, $content) = ({}, "");
    }
    $data = Thruk::Utils::IO::merge_deep($data, $patch_data);
    $options->{'changed_only'} = 1;
    $options->{'compare_data'} = $content;
    $self->json_store($file, $data, $options);
    return $data;
}

########################################

=head2 touch

  touch($file)

create file if not exists and update timestamp

=cut
sub touch {
    my($self, $file, $mtime) = @_;
    $mtime = Time::HiRes::time() unless $mtime;
    $self->write($file, "", $mtime, 1);
    return;
}

###################################################

=head2 find_files

  find_files($folder, $pattern)

return list of files for folder and pattern

=cut
sub find_files {
    #my($self, $dir, $match, $skip_symlinks) = @_;
    my($self, $dir, $match, undef) = @_;

    my @files;
    $dir =~ s/\/$//gmxo;
    $dir =~ s/'//gmxo;

# TODO: should not list sub folders...
    my $dbh = $self->_dbh;
    my @res = @{$dbh->selectall_arrayref("SELECT path FROM ".$table_name." WHERE path LIKE '".$dir."/%'", { Slice => {} })};
    for my $r (@res) {
        my $file = $r->{'path'};
        # if its a file, make sure it matches our pattern
        if(defined $match) {
            next unless $file =~ m/$match/mx;
        }

        push @files, $file;
    }

    return \@files;
}


###################################################

=head2 remove_folder

  remove_folder($folder)

recursively remove folder and all files

=cut
sub remove_folder {
    my($self, $dir) = @_;

    $dir =~ s/\/$//gmxo;
    $dir =~ s/'//gmxo;

    my $dbh = $self->_dbh;
    $dbh->do("DELETE FROM ".$table_name." WHERE path LIKE '".$dir."/%'");

    return;
}

##############################################

1;
