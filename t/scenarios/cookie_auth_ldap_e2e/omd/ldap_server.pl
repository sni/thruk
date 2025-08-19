#!/usr/bin/perl

package MockLDAPServer;
use warnings;
use strict;
use Net::LDAP::Constant qw(LDAP_SUCCESS LDAP_INVALID_CREDENTIALS);
use Net::LDAP::Entry;
use Net::LDAP::Server;
use fields qw(_bind);

use base 'Net::LDAP::Server';

sub new { shift->SUPER::new(@_) }

sub bind {
    my ($self, $req) = @_;
    if(lc($req->{'name'}) eq "uid=ldap,ou=people,dc=test,dc=local" && $req->{'authentication'}->{'simple'} eq "ldap") {
        $self->{'_bind'} = $req;
        return({
            'matchedDN'    => '',
            'errorMessage' => '',
            'resultCode'   => LDAP_SUCCESS,
        });
    }
    if($req->{'name'} eq "cn=Manager,dc=test,dc=local" && $req->{'authentication'}->{'simple'} eq "manager") {
        $self->{'_bind'} = $req;
        return({
            'matchedDN'    => '',
            'errorMessage' => '',
            'resultCode'   => LDAP_SUCCESS,
        });
    }
    return({
        'matchedDN'    => '',
        'errorMessage' => '',
        'resultCode'   => LDAP_INVALID_CREDENTIALS,
    });
}

sub unbind {
    my ($self, $req) = @_;
    return({
        'matchedDN'    => '',
        'errorMessage' => '',
        'resultCode'   => LDAP_SUCCESS,
    });
}

sub extended {
    my ($self, $req) = @_;
	if($req->{'requestName'} eq '1.3.6.1.4.1.4203.1.11.3') {
        return({
            'responseValue' => "dn:".$self->{'_bind'}->{'name'},
            'responseName'  => 'dn',
            'matchedDN'     => '',
            'errorMessage'  => '',
            'resultCode'    => LDAP_SUCCESS,
        });
    }
}

sub search {
    my ($self, $req) = @_;
    my @entries;
    my $base = $req->{'baseObject'};
    my $dn = "uid=ldap,ou=People,".$base;
    push @entries, Net::LDAP::Entry->new(
        $dn,
        objectClass => [qw( account posixAccount top shadowAccount )],
        uid         => 'ldap',
    );
    return({
        'matchedDN' => '',
        'errorMessage' => '',
        'resultCode' => LDAP_SUCCESS
    }, @entries);
}

################################################################################
package main;

use warnings;
use strict;
use IO::Select;
use IO::Socket;
use IO::Socket::INET;

my $sock = IO::Socket::INET->new(
        Listen    => 5,
        Proto     => 'tcp',
        Reuse     => 1,
        LocalPort => 9000,
);

my $sel = IO::Select->new($sock);
my %Handlers;
while(my @ready = $sel->can_read) {
    for my $fh (@ready) {
        if ($fh == $sock) {
            my $psock = $sock->accept;
            $sel->add($psock);
            $Handlers{*$psock} = MockLDAPServer->new($psock);
        } else {
            my $result = $Handlers{*$fh}->handle;
            if ($result) {
                $sel->remove($fh);
                $fh->close;
                delete $Handlers{*$fh};
            }
        }
    }
}

1;
