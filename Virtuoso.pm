package Virtuoso;
use Mojo::Base qw/-base/;
use Path::Class qw/file/;
use IPC::Run qw/run timeout/;
use Cwd qw/abs_path/;
use v5.14;

has 'isql' => sub { state $isql ||= 'isql'; $isql; };
has 'user' => sub { die "no user" };
has 'pass' => sub { die "no pass" };
has 'port' => 1111;
has 'graph_uri';

sub load_ttl_file {
    my $s = shift;
    my $file = shift;
    my $in;
    my ($out, $errs);
    my $graph_uri = $s->graph_uri;
    #my @cmd = ('vload','ttl', $file, $graph_uri  );
    #run \@cmd, \$in, \$out, \$errs, timeout(30) or die $!;
    my $full = abs_path("$file");
    my $isql = "DB.DBA.TTLP_MT(file_to_string_output('$full'),'','$graph_uri', 255);";
    $s->_do_isql($isql);
}

sub drop_graph {
    my $s = shift;
    $s->_do_isql("SPARQL CLEAR GRAPH <".$s->graph_uri.">");
}

sub _do_isql {
    my $s = shift;
    my $sql = shift or die "missing sql";
    $sql .= ';' unless $sql =~ /;$/;
    my @cmd = ($s->isql,$s->port,$s->user,$s->pass);
    my ($out, $err);
    run \@cmd, \$sql, \$out, $err, timeout(10) or die "@cmd : $!";
    return 1;
}

1;

