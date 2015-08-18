package Virtuoso;
use Mojo::Base qw/-base/;
use Mojo::Log;
use Path::Class qw/file/;
use IPC::Run qw/run timeout/;
use Cwd qw/abs_path/;
use v5.14;

has 'isql' => sub { state $isql ||= 'isql'; $isql; };
has 'user' => sub { die "no user" };
has 'pass' => sub { die "no pass" };
has 'port' => 1111;
has 'graph_uri';
has 'logger' => sub { state $log ||= Mojo::Log->new->path("/tmp/import-gcis.$$.log") };

sub load_ttl_file {
    my $s         = shift;
    my $file      = shift or return;
    my $graph_uri = $s->graph_uri;
    my $full      = abs_path("$file");
    $s->_do_isql( "DB.DBA.TTLP_MT(file_to_string_output('$full'),'','$graph_uri', 255);" );
    return 1;
}

sub drop_graph {
    my $s = shift;
    my $graph_uri = shift || $s->graph_uri;
    $s->_do_isql("SPARQL CLEAR GRAPH <".$graph_uri.">");
}

sub rename_graph_to {
    my $s = shift;
    my $name = shift;
    my $old = $s->graph_uri;
	$s->_do_isql(join "\n",
        qq[log_enable(3);],
        qq[update DB.DBA.RDF_QUAD TABLE OPTION (index RDF_QUAD_GS) set g = iri_to_id ('$name') where g = iri_to_id ('$old');],
        qq[log_enable(1);],
    );

    $s->graph_uri($name);
    return $s;
}

sub _do_isql {
    my $s = shift;
    my $sql = shift or die "missing sql";
    $sql .= ';' unless $sql =~ /;$/;
    my @cmd = ( $s->isql, $s->port, $s->user, $s->pass );
    my ( $out, $err );
    run \@cmd, \$sql, \$out, \$err, timeout(10) or die "@cmd : $!";
    $s->logger->debug("$sql : $out : $err");
    return 1;
}

1;

