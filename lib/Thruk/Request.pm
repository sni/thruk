package Thruk::Request;
use warnings;
use strict;
use Encode ();
use Hash::MultiValue;
use Plack 1.0046;
use URI::Escape qw/uri_unescape/;

use Thruk::Base ();

use parent qw/Plack::Request/;

use constant KEY_BASE_NAME    => 'thruk.request';
use constant DEFAULT_ENCODING => 'utf-8';

sub encoding {
    return(Encode::find_encoding(DEFAULT_ENCODING));
}

sub body_parameters {
    my $self = shift;
    return($self->env->{KEY_BASE_NAME.'.body'} ||= $self->_body_parameters_hash_multi()->mixed);
}

sub _body_parameters_hash_multi {
    my $self = shift;
    return($self->env->{KEY_BASE_NAME.'.body_hash_multi'} ||= $self->_decode_parameters($self->SUPER::body_parameters));
}

sub query_parameters {
    my $self = shift;
    return($self->env->{KEY_BASE_NAME.'.query'} ||= $self->_query_parameters_hash_multi()->mixed);
}

sub _query_parameters_hash_multi {
    my $self = shift;
    return($self->env->{KEY_BASE_NAME.'.query_hash_multi'} ||= $self->_decode_parameters($self->SUPER::query_parameters));
}

sub parameters {
    my($self, $val) = @_;
    if($val) {

        # reset parameters
        delete $self->env->{KEY_BASE_NAME.'.merged'};
        delete $self->env->{KEY_BASE_NAME.'.query'};
        delete $self->env->{KEY_BASE_NAME.'.query_hash_multi'};
        delete $self->env->{KEY_BASE_NAME.'.body'};
        delete $self->env->{KEY_BASE_NAME.'.body_hash_multi'};
        delete $self->env->{KEY_BASE_NAME.'.hash_multi'};

        if(ref $val eq 'ARRAY') {
            $self->env->{KEY_BASE_NAME.'.hash_multi'} = Hash::MultiValue->new(@{$val});
        } else {
            $self->env->{KEY_BASE_NAME.'.hash_multi'} = Hash::MultiValue->from_mixed($val);
        }
    }
    return($self->env->{KEY_BASE_NAME.'.merged'} ||= $self->_parameters_hash_multi()->mixed());
}

# return parameters as Hash::MultiValue
sub _parameters_hash_multi {
    my($self) = @_;
    return($self->env->{KEY_BASE_NAME.'.hash_multi'} ||= do {
        my $query = $self->_query_parameters_hash_multi();
        my $body  = $self->_body_parameters_hash_multi();
        Hash::MultiValue->new($query->flatten, $body->flatten);
    });
}

# return parameter keys in original order
sub parameter_keys {
    my($self) = @_;

    my @keys = $self->_parameters_hash_multi()->keys();

    # merge with new keys
    push(@keys, keys %{$self->parameters()});

    my $uniq = Thruk::Base::array_uniq(\@keys);

    # remove all keys which do not exist anymore
    my @list;
    my $params = $self->parameters();
    for my $k (@{$uniq}) {
        if(exists $params->{$k}) {
            push @list, $k;
        }
    }

    return(@list);
}

sub _decode_parameters {
    my ($self, $stuff) = @_;
    my $encoding = $self->encoding;
    my @flatten  = $stuff->flatten;
    my @decoded;
    while(my($k, $v) = splice(@flatten, 0, 2)) {
        # skip all request parameters with illegal characters in their name
        next if $k !~ m/^[a-zA-Z0-9\/\.:,;\+\-_\[\]\(\)\{\}\*]+$/mx;

        my $v_decoded;
        if (ref $v eq 'ARRAY') {
            foreach (@{$v}) {
                push @{$v_decoded}, $encoding->decode($_);
            }
        } else {
                $v_decoded = $encoding->decode($v);
        }
        push @decoded, $encoding->decode($k), $v_decoded;
    }
    return Hash::MultiValue->new(@decoded);
}

sub url {
    my($self) = @_;
    return($self->env->{KEY_BASE_NAME.'.url'} ||= $self->_url());
}

sub _url {
    my($self) = @_;
    my $url = uri_unescape("".$self->uri);
    $url =~ s/\n/%0a/gmx; # newlines get lost otherwise on redirects
    return unless $url;
    return($self->encoding->decode($url));
}

sub unescape {
    my($self, $param) = @_;
    return(URI::Escape::uri_unescape($param));
}

# returns uri, but applies HTTP_X_FORWARDED_* environment if set
sub uri {
    my($self) = @_;
    my $uri = $self->SUPER::uri(@_);

    my $scheme = $self->{'env'}->{'HTTP_X_FORWARDED_PROTO'};  # from X-FORWARDED-PROTO http header
    $scheme =~ s/\s*,.*$//mx if $scheme; # use first in list
    if($scheme && $scheme =~ m/^https?$/mx) {
        $uri->scheme($scheme);
    }

    my $host = $self->{'env'}->{'HTTP_X_FORWARDED_HOST'}; # from X-FORWARDED-HOST http header
    $host =~ s/\s*,.*$//mx if $host; # use first in list
    if($host && _is_valid_hostname($host)) {
        $uri->host($host);
    }

    my $port = $self->{'env'}->{'HTTP_X_FORWARDED_PORT'}; # from X-FORWARDED-PORT http header
    $port =~ s/\s*,.*$//mx if $port; # use first in list
    if($port && $port != $uri->port && $port =~ m/^\d+$/mx) {
        $uri->port($port);
    }
    return($uri);
}

sub _is_valid_hostname {
    my($host) = @_;
    # from https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch08s10.html
    if($host =~ m/^
        ([a-z0-9\-._~%]+     # Named host
        |\[[a-f0-9:.]+\])    # IPv6 host
        $/mx) {
        return 1;
    }
    return;
}

sub as_string {
    my($self) = @_;

    # Get request method and path
    my $method = $self->method;
    my $path   = $self->path_info || '/';

    # Build the query string if it exists
    my $query_string = $self->query_string;
    $path .= "?$query_string" if $query_string;

    # Get headers
    my $headers = $self->headers; # This is an HTTP::Headers object
    my @header_lines;
    $headers->scan(sub {
        my ($key, $value) = @_;
        push @header_lines, "$key: $value";
    });

    # Get the request body
    my $body = $self->raw_body || '';

    # Assemble the full request as a string
    return join("\n",
        "$method $path HTTP/1.1",
        @header_lines,
        '',
        $body,
    );
}

1;
__END__

=head1 NAME

Thruk::Request - Subclass of L<Plack::Request> which supports encoding.

=head1 DESCRIPTION

based on Plack::Request::WithEncoding.

=head1 WMETHODS

=head2 encoding

Returns a encoding method to use to decode parameters.

=head2 query_parameters

Returns a reference to a hash containing B<decoded> query string (GET)
parameters.

=head2 body_parameters

Returns a reference to a hash containing B<decoded> posted parameters in the
request body (POST). As with C<query_parameters>.

=head2 parameters

Returns a hash reference containing B<decoded> (and merged) GET
and POST parameters.

=head2 parameter_keys

Returns parameter keys in original order as array.

=head2 param

Returns B<decoded> GET and POST parameters.

=head2 url

Returns urldecoded utf8 uri as string.

=head2 uri

Returns L<Uri> object, but applies HTTP_X_FORWARDED_* environment if set.

=head2 unescape

Returns B<uri_unescape> for given value.

=head2 as_string

Returns request as string for debugging purposes.

=head1 SEE ALSO

L<Plack::Request>, L<Plack::Request::WithEncoding>

=cut
