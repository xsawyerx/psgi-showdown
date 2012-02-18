#!/usr/bin/perl

use strict;
use warnings;
use Plack::Util;
use Text::Xslate;

# TODO: add the following:
# CGI, Apache1, Apache2, Plack::Handler::FCGI, Plack::Handler::SCGI, Plack::Handler::*

# no buffer shortlist:
# Plack::Handler::FCGI, FCGI, uwsgi, CGI

# to check:
# fastcgi, mod_fcgi, mod_fastcgi, mod_fcgid, nginx's fcgi, lighttpd's fcgi

my $tx   = Text::Xslate->new;
my $tmpl = do { undef $/; <DATA> };

my @parameters = qw/
    psgi.version
    psgi.run_once
    psgi.nonblocking
    psgi.multithread
    psgi.multiprocess
    psgi.streaming

    psgix.input.buffered
    psgix.output.buffered
    psgix.harakiri
/;

my %servers = (
    'Perlbal::Plugin::PSGI' => {
        'psgi.version'         => [ 1, 0 ],
        'psgi.nonblocking'     => Plack::Util::TRUE,
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::FALSE,
        'psgi.streaming'       => Plack::Util::TRUE,
    },

    'HTTP::Server::PSGI' => {
        'psgi.version'         => [ 1, 1 ],
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::FALSE,
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.nonblocking'     => Plack::Util::FALSE,
        'psgix.input.buffered' => Plack::Util::TRUE,
    },

    'HTTP::Server::Simple::PSGI' => {
        'psgi.version'         => [1,1],
        'psgi.multithread'     => 0,
        'psgi.multiprocess'    => 0,
        'psgi.run_once'        => 0,
        'psgi.streaming'       => 1,
        'psgi.nonblocking'     => 0, 
    },

    'POE::Component::Server::PSGI' => {
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.nonblocking'     => Plack::Util::TRUE,
        'psgi.runonce'         => Plack::Util::FALSE,
    },

    'Twiggy' => {
        'psgi.version'         => [ 1, 0 ],
        'psgi.nonblocking'     => Plack::Util::TRUE,
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::FALSE,
        'psgix.input.buffered' => Plack::Util::TRUE,
    },

    'Starman' => {
        'psgi.version'         => [ 1, 1 ],
        'psgi.nonblocking'     => Plack::Util::FALSE,
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::TRUE,
        'psgix.input.buffered' => Plack::Util::TRUE,
        'psgix.harakiri'       => Plack::Util::TRUE,
    },

    'Corona' => {
        'psgi.version'      => [ 1, 0 ],
        'psgi.nonblocking'  => Plack::Util::TRUE,
        'psgi.run_once'     => Plack::Util::FALSE,
        'psgi.multithread'  => Plack::Util::TRUE,
        'psgi.multiprocess' => Plack::Util::FALSE,
        'psgi.streaming'    => Plack::Util::TRUE,
    },

    'Starlet' => {
        'psgi.version'         => [ 1, 1 ],
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::FALSE,
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.nonblocking'     => Plack::Util::FALSE,
        'psgix.input.buffered' => Plack::Util::TRUE,
    },

    'Gepok' => {
        'psgi.version'         => [ 1, 1 ],
        'psgi.run_once'        => Plack::Util::FALSE,
        'psgi.multithread'     => Plack::Util::FALSE,
        'psgi.multiprocess'    => Plack::Util::TRUE,
        'psgi.streaming'       => Plack::Util::TRUE,
        'psgi.nonblocking'     => Plack::Util::FALSE,
        'psgix.input.buffered' => Plack::Util::TRUE,
        'psgix.harakiri'       => Plack::Util::TRUE,
    },

    'FCGI::Async' => {
        'psgi.version'      => [ 1, 0 ],
        'psgi.multithread'  => 0,
        'psgi.multiprocess' => 0,
        'psgi.run_once'     => 0,
        'psgi.nonblocking'  => 1,
        'psgi.streaming'    => 1,
    },

    'FCGI::Engine::PSGI' => {
        'psgi.version'      => [ 1, 0 ],
        'psgi.multithread'  => Plack::Util::FALSE,
        'psgi.multiprocess' => Plack::Util::TRUE,
        'psgi.run_once'     => Plack::Util::FALSE,
        'psgi.streaming'    => Plack::Util::TRUE,
        'psgi.nonblocking'  => Plack::Util::FALSE,
    },

    'Feersum' => {
        # XXX: in XS version seems 1.1
        # av_push(psgi_ver, newSViv(1));
        # av_push(psgi_ver, newSViv(1));
        'psgi.version'           => [ 1, 0 ],
        'psgi.run_once'          => 0,
        'psgi.nonblocking'       => 1,
        'psgi.multithread'       => 0,
        'psgi.multiprocess'      => 0,
        'psgi.streaming'         => 1,
        'psgix.input.buffered'   => 1,
        'psgix.output.buffered'  => 1,

# non-standard
#        'psgix.body.scalar_refs' => 1,
#        'psgix.output.guard'     => 1,
    },

    'Tatsumaki' => 'Twiggy',

    'Web::Simple' => {
        'psgi.version'      => [ 1, 0 ],
        'psgi.multithread'  => Plack::Util::FALSE,
        'psgi.multiprocess' => Plack::Util::TRUE,
        'psgi.run_once'     => Plack::Util::TRUE,
    },
);

# features that are actually supported when off
my %backward_features = (
    'psgix.input.buffered' => 1,
    'psgi.output.buffered' => 1,
);

my @servers = sort keys %servers;

my %data = ();
foreach my $param (@parameters) {
    foreach my $server (@servers) {
        my $server_data = $servers{$server};

        # if the data isn't a reference, it means
        # the data should come from a different server
        if ( ! ref $server_data ) {
            # data is like some other server
            $server_data = $servers{$server_data};
        }

        # if it's an array, join it with dots, it's a version!
        my $value = $server_data->{$param};
        if ( defined $value && ref $value && ref $value eq 'ARRAY' ) {
            $value = join '.', @{$value};
        }

        if ( defined $value ) {
            if ($value) {
                $data{$server}{$param} = [ 'green', 'Yes' ];
            } else {
                $data{$server}{$param} = [ 'red', 'No' ];
            }
        } else {
            $data{$server}{$param} = [ 'yellow', 'N/A' ];
        }
    }
}

print $tx->render_string(
    $tmpl,
    {
        params  => \@parameters,
        servers => \@servers,
        data    => \%data,
    },
);

__DATA__
<html>
    <head>
        <title>PSGI servers breakdown</title>
        <link rel="stylesheet" type="text/css" href="css/ui.css"/>
    </head>
<body>

<table>
    <tr>
        <td></td>
        : for $servers -> $server {
        <td class="ui-message ui-message-black"><: $server :></td>
        : }
    </tr>

    : for $params -> $param {
        <tr>
        <td class="ui-message ui-message-black"><: $param :></td>
        : for $servers -> $server {
            : if $param == "psgi.version" {
        <td class="ui-message ui-message-blue"><: $all_data[$server][$param] :></td>
            : } else {
        <td class="ui-message ui-message-<: $data[$server][$param][0] :>"><: $data[$server][$param][1] :></td>
            : }
        : }
        </tr>
    : }
</table>

<br/><br/>
<p><b>Feersum</b> maintains two additional non-standard <tt>psgix</tt> parameter
variables:</p>

<ul>
  <li>- <tt>psgix.body.scalar_refs</tt></li>
  <li>- <tt>psgix.output.guard</tt><li>
</ul>

</body>
</html>
