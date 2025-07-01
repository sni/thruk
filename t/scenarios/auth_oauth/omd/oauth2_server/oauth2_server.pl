#!/usr/bin/perl

use warnings;
use strict;
use utf8;

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'config';
}
use Dancer2;
use Dancer2::Plugin::OAuth2::Server;

get '/oauth/userinfo/1' => oauth_scopes 'openid' => sub {
    return to_json {
        login => "clientö",
        groups => [],
    };
};

get '/oauth/userinfo/2' => oauth_scopes 'openid' => sub {
    return to_json {
        login => "omdadmin",
        groups => ["group1", "group2"],
    };
};

dance;
