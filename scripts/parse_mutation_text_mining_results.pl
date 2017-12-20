use strict;
use warnings;

use FileHandle;
use Bio::EnsEMBL::Registry;

my $working_dir = '/hps/nobackup/production/ensembl/anja/G2P/text_mining/';
my $registry_file = "$working_dir/registry_file_live";
my $registry = 'Bio::EnsEMBL::Registry';
$registry->load_all($registry_file);
my $dbh = $registry->get_DBAdaptor('human', 'gene2phenotype')->dbc->db_handle;

my $g2p_pmids = {};
my $g2p_pmid_2_gene_symbol = {};

my $amino_acid_code = {
  'A' => 'Ala',
  'R' => 'Arg',
  'N' => 'Asn',
  'D' => 'Asp',
  'B' => 'Asx',
  'C' => 'Cys',
  'E' => 'Glu',
  'Q' => 'Gln',
  'Z' => 'Glx',
  'G' => 'Gly',
  'H' => 'His',
  'I' => 'Ile',
  'L' => 'Leu',
  'K' => 'Lys',
  'M' => 'Met',
  'F' => 'Phe',
  'P' => 'Pro',
  'S' => 'Ser',
  'T' => 'Thr',
  'W' => 'Trp',
  'Y' => 'Tyr',
  'V' => 'Val', 
  'X' => 'Xaa',
};

my $sth = $dbh->prepare(q{
  SELECT distinct p.pmid, p.publication_id from genomic_feature_disease_publication gfdp, publication p WHERE gfdp.publication_id = p.publication_id;
}, {mysql_use_result => 1});
$sth->execute() or die $dbh->errstr;
my ($pmid, $publication_id);
$sth->bind_columns(\($pmid, $publication_id));
while ($sth->fetch) {
  $g2p_pmids->{$pmid} = $publication_id;
}
$sth->finish;

print scalar keys %$g2p_pmids, "\n";

$sth = $dbh->prepare(q{SELECT distinct pg.pmid, gf.gene_symbol from genomic_feature_disease_publication gfdp, text_mining_pmid_gene pg, genomic_feature gf where gfdp.publication_id = pg.publication_id and pg.genomic_feature_id = gf.genomic_feature_id}, {mysql_use_result => 1});
$sth->execute() or die $dbh->errstr;
my ($gene_symbol);
$sth->bind_columns(\($pmid, $gene_symbol));
while ($sth->fetch) {
  $g2p_pmid_2_gene_symbol->{$pmid}->{$gene_symbol} = 1;
}
$sth->finish;

print scalar keys %$g2p_pmid_2_gene_symbol, "\n";


my $fh_out = FileHandle->new("$working_dir/results/gene_hgvs_pmid_20171212", 'w');
my $fh_rsid_out = FileHandle->new("$working_dir/results/gene_rsid_pmid_20171212", 'w');

my $fh = FileHandle->new("$working_dir/data/mutation2pubtator", 'r');

my $coord_types = {};
my $mutation_types = {};

#PMID  Components  Mentions  Resource
while (<$fh>) {
  chomp;
  next if (/^PMID/);
  my ($pmid, $components, $mentions, $resources) = split/\t/;

  next if (!$g2p_pmids->{$pmid});

  my ($hgvs, $rsids) = parse_components($components);

  next if (!$g2p_pmids->{$pmid});

  if ($mentions =~ /^(rs|Rs|RS|SS|ss)/) {
    my $lc_mentions = lc $mentions;
    print $fh_rsid_out "rs\t$lc_mentions\t$pmid\n";
    next;
  }

  my $hgvs = undef;
  my $tmvar_rsid = undef;
  if ($components =~ /;/) {
    my @values = split(';', $components);
    if (scalar @values != 2) {
      print scalar @values, "\n";
    }
    $hgvs = parse_hgvs($values[0]);
    my @tm_rs_values = split(':', $values[1]);
    $tmvar_rsid = "rs" . $tm_rs_values[1];
  } else {
  #   p|SUB|F|256|S
    $hgvs =  parse_hgvs($components);
  }

  if ($hgvs) {
    if ($g2p_pmid_2_gene_symbol->{$pmid}) {
      my @gene_symbols = keys %{$g2p_pmid_2_gene_symbol->{$pmid}};
      foreach my $gene_symbol (@gene_symbols) {
        if ($tmvar_rsid) {
          print $fh_rsid_out "hgvs\t$gene_symbol:$hgvs\t$pmid\t$tmvar_rsid\n";
        } else {
          print $fh_out "hgvs\t$gene_symbol:$hgvs\t$pmid\n";
        }
      }
    }
  }  else {
    if ($tmvar_rsid) {
      print $fh_rsid_out "rs\t$tmvar_rsid\t$pmid\n";
    } else {
      print STDERR "No HGVS for $_\n";
    }
  }   
}

print join(', ', keys %$coord_types), "\n";
print join(', ', keys %$mutation_types), "\n";


$fh->close;
$fh_out->close;
$fh_rsid_out->close; 

sub parse_hgvs {
  my $components = shift;
  my @split_components = split('\|', $components);
 
  if (scalar @split_components == 5) {
    my $coord_type = $split_components[0];
    my $mutation_type = $split_components[1];
    my $ref_sequence = $split_components[2];
    my $alt_sequence = $split_components[4];
    my $location = $split_components[3];
    if (is_number($location) && is_literal($ref_sequence) && is_literal($alt_sequence)) {
      if ($mutation_type eq 'SUB') {
        if ($coord_type eq 'p') {
          $ref_sequence = to_3_letter_code($ref_sequence);
          $alt_sequence = to_3_letter_code($alt_sequence);
          if ($ref_sequence && $alt_sequence) {
            return "$coord_type.$ref_sequence$location$alt_sequence";
          } else {
            return undef;
          }
        } elsif ($coord_type eq 'c') {
          return "$coord_type.$location$ref_sequence>$alt_sequence";
        } 
      } else {
        print $components, "\n";
      }
    }
  } elsif (scalar @split_components == 4) {
#p|DEL|295|I
#c|DEL|322|C
#c|INS|322|C
#p|DEL|396|C
    my $coord_type = $split_components[0];
    my $mutation_type = $split_components[1];
    my $location = $split_components[2];
    my $alt_sequence = $split_components[3];
    if ($mutation_type eq 'DEL' || $mutation_type eq 'INS') {
      if (is_number($location) && (is_literal($alt_sequence) || is_number($alt_sequence))) {
        if ($coord_type eq 'c') {
          return "$coord_type.$location$mutation_type$alt_sequence";
        } elsif ($coord_type eq 'p') {
          $alt_sequence = to_3_letter_code($alt_sequence);
          if ($alt_sequence) {
            return "$coord_type.$location$mutation_type$alt_sequence";
          } else {
            return "$coord_type.$location$mutation_type";
          }
        }
      }
    }
  } elsif (scalar @split_components == 3) {
    my $coord_type = $split_components[0];
    my $mutation_type = $split_components[1];
    my $location = $split_components[2];
    return "$coord_type.$location$mutation_type";
  }
  else {
  }
  return undef;
}

sub is_number {
  my $number = shift;
  return ($number =~ m/^([0-9]|\,|\_|\+)+$/);
}

sub is_literal {
  my $literal = shift;
  return ($literal =~ m/^[a-zA-Z]+$/);
}

sub is_empty {
  my $is_empty = shift;
  return !defined($is_empty);
}

sub to_3_letter_code {
  my $sequence = shift;
  my @letters = split('', $sequence);
  my @new_sequence = ();
  foreach my $letter (@letters) {
    my $aa = $amino_acid_code->{$letter};
    if (!$aa) {
      warn "No 3 letter code for $letter\n";
      return undef;
    }
    push @new_sequence, $aa;
  }
  return join('', @new_sequence);
}

