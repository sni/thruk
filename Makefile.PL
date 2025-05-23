use strict;
use warnings;
use inc::Module::Install;

name 'thruk';
license 'perl';
all_from 'lib/Thruk/Config.pm';

resources(
    'homepage',   => 'http://www.thruk.org',
    'bugtracker'  => 'http://github.com/sni/thruk/issues',
    'repository', => 'http://github.com/sni/thruk',
    'license'     => 'http://dev.perl.org/licenses/',
    'IRC'         => 'irc://irc.freenode.org/#thruk',
    'MailingList' => 'https://groups.google.com/d/forum/thruk',
);

requires 'parent'                                 => 0;     # required by Thruk
requires 'Module::Load'                           => 0;     # required by Thruk
requires 'Plack'                                  => 1.0046;# required by Thruk
requires 'Plack::Util'                            => 0;     # required by Thruk
requires 'FCGI'                                   => 0;     # required by Thruk
requires 'Cpanel::JSON::XS'                       => 0;     # required by Thruk::View::JSON
requires 'HTTP::Response'                         => 0;     # required by Thruk::UserAgent
requires 'HTTP::Request'                          => 6.12;  # required by Thruk::Utils::CLI, versions before cannot handle delete or patch requests
requires 'HTTP::Request::Common'                  => 0;     # required by Thruk::UserAgent
requires 'Pod::Usage'                             => 0;     # required by Thruk::Utils::CL
requires 'LWP::UserAgent'                         => 0;     # required by Thruk::UserAgent
requires 'Net::HTTP'                              => 6.02;  # required for HTTP connections. Version required due to timeout bug
requires 'URI::Escape'                            => 0;     # required by Thruk::Controller::Root
requires 'HTML::Entities'                         => 0;     # required by Thruk::Utils::Filter
requires 'Socket'                                 => 0;     # required by Monitoring::Livestatus
requires 'IO::Socket::IP'                         => 0;     # required by Monitoring::Livestatus
requires 'GD'                                     => 2.44;  # required by Thruk::Utils::Trends
requires 'Template'                               => 0;     # required by Thruk
requires 'Date::Calc'                             => 6.3;   # required by Thruk::Utils
requires 'Date::Manip'                            => 0;     # required by Thruk::Utils
requires 'Excel::Template'                        => 0;     # required by Thruk::Views::ExcelRenderer
requires 'IO::String'                             => 0;     # required by Thruk::Views::ExcelRenderer
requires 'Log::Log4perl'                          => 1.34;  # required by Thruk
requires 'Storable'                               => 0;     # required by Thruk::Utils::External
requires 'threads'                                => 0;     # required by Thruk::Pool::Simple
requires 'Thread::Queue'                          => 0;     # required by Thruk::Pool::Simple
requires 'Time::HiRes'                            => 0;     # required by Thruk::Backend::Manager
requires 'Crypt::Rijndael'                        => 0;     # required by Thruk::Utils::CookieAuth
requires 'Digest::SHA'                            => 0;     # required by Thruk::Utils::Crypt

# reporting2 plugin
feature     ('plugin_reports2',
  -default                                        => 0,
  'MIME::Lite'                                    => 0,
  'Tie::IxHash'                                   => 0,
);

# https backends support
feature     ('https_backends_support',
  -default                                        => 0,
  'Net::SSLeay'                                   => 0,     # required by Thruk::Backend::Pool
  'IO::Socket::SSL'                               => 0,     # required by Thruk::Backend::Pool
  'LWP::Protocol::https'                          => 0,     # required by Thruk::Backend::Provider::HTTP
  'LWP::Protocol::connect'                        => 0,     # required by Thruk::Backend::Provider::HTTP
  'Mozilla::CA'                                   => 0,     # required by Thruk::UserAgent
);

# mysql logcache support
feature     ('mysql_support',
  -default                                        => 0,
  'DBI'                                           => 0,     # required by Thruk::Backend::Provider::Mysql
  'DBD::mysql'                                    => 0,     # required by Thruk::Backend::Provider::Mysql
);

# performance tweaking modules
feature     ('performance_tweaking',
  -default                                        => 0,
  'HTML::Escape'                                  => 0,     # required by Thruk::Utils::Filter
#  'Thruk::Utils::XS'                              => 0,     # required by Thruk::Backend::Manager
);

# requirements test requirements
if(scalar @ARGV != 1 || $ARGV[0] ne '--checkdeps') {
  test_requires 'Test::Simple'                                                            => 0;
  test_requires 'HTML::Lint'                                                              => 0;
  test_requires 'File::BOM'                                                               => 0;
  test_requires 'Test::Cmd'                                                               => 0;
  test_requires 'Test::Pod'                                                               => 1.40;
  test_requires 'Test::Perl::Critic'                                                      => 0;
  test_requires 'Test::Pod::Coverage'                                                     => 0;
  test_requires 'Perl::Critic::Policy::Dynamic::NoIndirect'                               => 0;
  test_requires 'Perl::Critic::Policy::NamingConventions::ProhibitMixedCaseSubs'          => 0;
  test_requires 'Perl::Critic::Policy::ValuesAndExpressions::ProhibitAccessOfPrivateData' => 0;
  test_requires 'Perl::Critic::Policy::Modules::ProhibitPOSIXimport'                      => 0;
  test_requires 'Perl::Critic::Policy::TooMuchCode::ProhibitUnusedImport'                 => 0;
  test_requires 'WWW::Mechanize::Chrome'                                                  => 0;
  test_requires 'Test::Vars'                                                              => 0;
  test_requires 'Devel::Cycle'                                                            => 0;
  test_requires 'Devel::Gladiator'                                                        => 0;
};

##################################
# check plugin test symlinks
my $testlinks = {};
mkdir("t/xt") unless -d "t/xt";
for my $testdir (glob('plugins/plugins-enabled/*/t')) {
    $testdir =~ m|/plugins-enabled/(.*)/t|gmx or die("test directory $testdir does not have valid format!");
    my $plugin = $1;

    if(!-e 't/xt/'.$plugin and !-l 't/xt/'.$plugin) {
        symlink('../../plugins/plugins-enabled/'.$plugin.'/t', 't/xt/'.$plugin) or die("cannot create symlink ('../../plugins/plugins-enabled/$plugin/t', 't/xt/$plugin'): $!");
        $testlinks->{$plugin} = '../../plugins/plugins-enabled/'.$plugin.'/t';
        next;
    }
    my $target = readlink('t/xt/'.$plugin);
    if($target ne '../../plugins/plugins-enabled/'.$plugin.'/t') {
        die('t/xt/'.$plugin.' has wrong target: '.$target.' vs. ../../plugins/plugins-enabled/'.$plugin.'/t');
    }
    $testlinks->{$plugin} = $target;
}

# check if there are some links too much
my @cur_t_links = glob('t/xt/*');
for my $link (@cur_t_links) {
    my $target = readlink($link);
    my $linkbasename = $link;
    $linkbasename =~ s/\/\.$//gmx;
    $linkbasename =~ s/^.*\///gmx;
    $link         =~ s/\/\.$//gmx;
    if(!defined $testlinks->{$linkbasename}) {
        unlink($link) or die($link.' should be deleted: '.$!);
    }
    elsif($testlinks->{$linkbasename} ne $target) {
        die($link.' has wrong target: '.$target.' vs. '.$testlinks->{$linkbasename});
    }
}

# cleanup old links
for my $rootlink (glob("./root/thruk/plugins/*")) {
    unlink($rootlink) unless -e $rootlink;
}

# touch the Makefile, so Extutils skips its broken 'check_manifest()'
`touch Makefile`;

tests_recursive;
eval {
    require CPAN;
    installdeps_target();
};
WriteAll;

##################################
# patch our makefile
print `./script/thruk_patch_makefile.pl`;
if($? != 0) {
  die("failed to patch makefile");
}

# create combined javascript/css files
print `./script/thruk_create_combined_static_content.pl`;
if($? != 0) {
  die("failed to create cached js/css files");
}
print "created cached js/css files\n";

print `test -f themes/themes-available/Light/stylesheets/Light.css || make themes`;
if($? != 0) {
  die("failed to build themes");
}

##################################
my $uname = `uname -s`; chomp($uname);
if($uname eq 'Linux') {
  print `./script/thruk_set_standard_header`;
  if($? != 0) {
    die("failed to update standard headers");
  }
}

print "finished\n";
exit 0
