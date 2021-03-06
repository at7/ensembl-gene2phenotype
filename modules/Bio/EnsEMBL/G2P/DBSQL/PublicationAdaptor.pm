=head1 LICENSE
 
See the NOTICE file distributed with this work for additional information
regarding copyright ownership.
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
=cut
use strict;
use warnings;

package Bio::EnsEMBL::G2P::DBSQL::PublicationAdaptor;

use Bio::EnsEMBL::G2P::DBSQL::BaseAdaptor;
use Bio::EnsEMBL::G2P::Publication;
our @ISA = ('Bio::EnsEMBL::G2P::DBSQL::BaseAdaptor');

sub store {
  my $self = shift;
  my $publication = shift;  
  my $dbh = $self->dbc->db_handle;

  my $sth = $dbh->prepare(q{
    INSERT INTO publication (
      pmid,
      title,
      source
    ) VALUES (?,?,?);
  });
  $sth->execute(
    $publication->pmid || undef,
    $publication->title || undef,
    $publication->source || undef,
  );

  $sth->finish();

  # get dbID
  my $dbID = $dbh->last_insert_id(undef, undef, 'publication', 'publication_id');
  $publication->{publication_id} = $dbID;
  return $publication;
}

sub fetch_by_publication_id {
  my $self = shift;
  my $publication_id = shift;
  return $self->SUPER::fetch_by_dbID($publication_id);
}

sub fetch_by_dbID {
  my $self = shift;
  my $publication_id = shift;
  return $self->SUPER::fetch_by_dbID($publication_id);  
}

sub fetch_by_PMID {
  my $self = shift;
  my $pmid = shift;
  my $constraint = "p.pmid=$pmid";
  my $result = $self->generic_fetch($constraint);
  return $result->[0];
}

sub _columns {
  my $self = shift;
  my @cols = (
    'p.publication_id',
    'p.pmid',
    'p.title',
    'p.source',
  );
  return @cols;
}

sub _tables {
  my $self = shift;
  my @tables = (
    ['publication', 'p'],
  );
  return @tables;
}

sub _objs_from_sth {
  my ($self, $sth) = @_;
  my ($publication_id, $pmid, $title, $source);
  $sth->bind_columns(\($publication_id, $pmid, $title, $source));
  my @objs;
  while ($sth->fetch()) {
    my $obj = Bio::EnsEMBL::G2P::Publication->new(
      -publication_id => $publication_id,
      -pmid => $pmid,
      -title => $title,
      -source => $source,
      -adaptor => $self,  
    );
    push(@objs, $obj);  
  }
  return \@objs;
}

1;
