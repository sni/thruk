use warnings;
use strict;
use POSIX ();
use Test::More;

BEGIN {
    plan skip_all => 'backends required' if(!-s 'thruk_local.conf' and !defined $ENV{'PLACK_TEST_EXTERNALSERVER_URI'});
    plan tests => 2123;
}

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
}

BEGIN {
    use_ok 'Thruk::Controller::cmd';
    use_ok('Thruk::Constants', ':peer_states');
};

TestUtils::set_test_user_token();
my $c              = TestUtils::get_c();
my($host,$service) = TestUtils::get_test_service();
my $hostgroup      = TestUtils::get_test_hostgroup();
my $servicegroup   = TestUtils::get_test_servicegroup();
my $post           = { test_only => 1, cmd_mod => 2, host => $host, 'service' => $service, 'servicegroup' => $servicegroup, 'hostgroup' => $hostgroup };

subtest 'bulk commands cannot contain additional command frames' => sub {
    my @sent;
    no warnings 'redefine';
    local *Thruk::Controller::cmd::_bulk_send_backend = sub {
        my(undef, $backend, $commands) = @_;
        push @sent, [$backend, [@{$commands}]];
        return 1;
    };

    my $valid = 'COMMAND [1] ADD_HOST_COMMENT;hostA;1;author;comment';
    for my $separator ("\n", "\r", "\r\n", "\n\n") {
        my @values = ($separator.$valid, $valid.$separator.'COMMAND [1] ADD_HOST_COMMENT;hostB;1;author;marker');
        push @values, $valid.$separator unless $separator eq "\n";
        for my $value (@values) {
            @sent = ();
            $c->stash->{'last_command_error'} = 'previous error';
            $c->stash->{'last_command_lines'} = ['previous command'];
            my $commands = {
                first  => [$valid],
                second => [(map { 'COMMAND [1] DEL_HOST_COMMENT;'.$_ } 1..101), $value],
            };
            ok(!Thruk::Controller::cmd::bulk_send($c, $commands), 'reject CR/LF remaining after chomp');
            is_deeply(\@sent, [], 'no backend or earlier bucket was sent');
            is($c->stash->{'last_command_error'}, 'command contains invalid CR/LF characters', 'report validation error');
            is_deeply($c->stash->{'last_command_lines'}, [], 'no stale command lines reported');
        }
    }

    my $commands = [$valid."\n", 'COMMAND [1] ADD_HOST_COMMENT;hostB;1;author;literal \\n;extra'];
    ok(Thruk::Controller::cmd::bulk_send($c, { first => $commands }), 'allow trailing newline, separate commands and literal backslash-n');
    is_deeply(\@sent, [['first', $commands]], 'preserve valid command entries');
    ok(!defined $c->stash->{'last_command_error'}, 'clear previous error for a valid batch');
    done_testing();
};

# test quick commands
my $backends = $c->db->get_peers();
@{$backends} = grep { !defined $_->{disabled} || $_->{disabled} != HIDDEN_LMD_PARENT } @{$backends}; # remove lmd parents, for this test
SKIP: {
    my $num = 21;
    skip "test is useless with only a single backend",                $num if (scalar @{$backends} <= 1);
    skip "test is requires authorized_for_all_service_commands role", $num if !$c->user->check_user_roles('authorized_for_all_service_commands');
    skip "test is requires authorized_for_all_host_commands role",    $num if !$c->user->check_user_roles('authorized_for_all_host_commands');

    TestUtils::test_page(
        'url'      => '/thruk/cgi-bin/cmd.cgi',
        'post'     => {
              'quick_command'       => '1',
              'selected_hosts'      => '',
              'selected_services'   => "host1;svc1;".$backends->[0]->{'key'}.'~~host1;svc1;'.$backends->[1]->{'key'},
              'spread'              => '0',
              'start_time'          => POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime(time()+10)),
              'referer'             => 'status.cgi',
        },
        'like'     => 'This item has moved',
        'redirect' => 1,
    );
    like($ENV{'THRUK_TEST_NO_AUDIT_LOG'}, '/\['.$backends->[0]->{'name'}.'\] cmd: COMMAND \[\d+\] SCHEDULE_SVC_CHECK;host1;svc1;\d+/', 'got first command');
    like($ENV{'THRUK_TEST_NO_AUDIT_LOG'}, '/\['.$backends->[1]->{'name'}.'\] cmd: COMMAND \[\d+\] SCHEDULE_SVC_CHECK;host1;svc1;\d+/', 'got second command');

    $ENV{'THRUK_TEST_NO_AUDIT_LOG'} = 1;
    $ENV{'THRUK_TEST_NO_LOG'}       = "";
    TestUtils::test_page(
        'url'      => '/thruk/cgi-bin/cmd.cgi',
        'post'     => {
              'cmd_mod'      => '2',
              'cmd_typ'      => '11',
              'start_time'   => POSIX::strftime("%Y-%m-%d %H:%M:%S", localtime(time()+10)),
              'referer'      => 'status.cgi',
              'backend'      => [$backends->[0]->{'key'}, $backends->[1]->{'key'}],
        },
        'like'     => 'This item has moved',
        'redirect' => 1,
    );
    my $backends_string = join(',', sort ($backends->[0]->{'name'}, $backends->[1]->{'name'}));
    like($ENV{'THRUK_TEST_NO_AUDIT_LOG'}, '/\['.$backends_string.'\] cmd: COMMAND \[\d+\] DISABLE_NOTIFICATIONS/', 'got combined command');
};

$ENV{'THRUK_TEST_NO_AUDIT_LOG'} = 1;
$ENV{'THRUK_TEST_NO_LOG'}       = "";

TestUtils::test_page(
    'url'      => '/thruk/cgi-bin/cmd.cgi?cmd_typ=96&host='.$host.'&backend='.$backends->[0]->{'key'}.'&backend='.$backends->[0]->{'key'},
    'like'     => 'Command Options',
);


for my $file (sort glob("templates/cmd/*")) {
    next if($file eq '.' or $file eq '..');

    # normal commands
    if($file =~ m/templates\/cmd\/cmd_typ_(\d+)\.tt/mx) {
        next if($1 == 200 || $1 == 201);
        $post->{cmd_typ} = $1;
        TestUtils::test_page(
            'url'     => '/thruk/cgi-bin/cmd.cgi?cmd_typ='.$1,
            'like'    => 'External Command Interface',
        );
        TestUtils::test_page(
            'url'     => '/thruk/cgi-bin/cmd.cgi',
            'post'    => $post,
            'like'    => 'External Command Interface',
        );
    }

    # quick commands
    elsif($file =~ m/templates\/cmd\/cmd_typ_c(\d+)\.tt/mx) {
        TestUtils::test_page(
            'url'     => '/thruk/cgi-bin/cmd.cgi?quick_command='.$1.'&confirm=no',
            'like'    => 'External Command Interface',
        );
    }
    else {
        BAIL_OUT("$0: found file which does not match cmd template: ".$file);
    }
}
