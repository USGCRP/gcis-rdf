#!/usr/bin/env perl

use Mojo::UserAgent;
use Data::Dumper;
use v5.14;

my $rdf_source_url = shift || 'http://data.globalchange.gov';

my $ua = Mojo::UserAgent->new();
my $src = "$rdf_source_url/resources.json";
my $data = $ua->get($src)->res->json;
#say Dumper($data);

for my $src (keys %{ $data->{rdf_sources} }) {
    my $url = $data->{rdf_sources}{$src} or next;
    say $src;
    #say $url;
    my $tx = $ua->get($url);
    my $res = $tx->success or do {
        say "error getting $url ".Dumper($tx->error);
        next;
    };
    $res->content->asset->move_to("/tmp/gcis_$src.rdf");
    say "wrote /tmp/gcis_$src.rdf";
    my $type = 'rdf';
    $type = 'ttl' if $url =~ /ttl$/;
    system("vload rdf /tmp/gcis_$src.rdf http://data.globalchange.gov")==0 or say "error loading $src";
}


