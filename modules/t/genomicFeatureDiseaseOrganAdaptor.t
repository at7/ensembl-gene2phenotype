=head1 LICENSE
Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
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

use Test::More;
use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::Test::TestUtils;

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new('homo_sapiens');

my $g2pdb = $multi->get_DBAdaptor('gene2phenotype');

my $gfdoa = $g2pdb->get_GenomicFeatureDiseaseOrganAdaptor;
my $gfda = $g2pdb->get_GenomicFeatureDiseaseAdaptor;

ok($gfdoa && $gfdoa->isa('Bio::EnsEMBL::G2P::DBSQL::GenomicFeatureDiseaseOrganAdaptor'), 'isa GenomicFeatureDiseaseOrganAdaptor');

my $dbID = 111;
my $GFD_id = 49;
my $organ_id = 5;

my $GFDO = $gfdoa->fetch_by_dbID($dbID);
ok($GFDO->dbID == $dbID, 'fetch_by_dbID');

$GFDO = $gfdoa->fetch_by_GFD_id_organ_id($GFD_id, $organ_id);
ok($GFDO->dbID == $dbID, 'fetch_by_GFD_id_organ_id');

my $GFD = $gfda->fetch_by_dbID($GFD_id);
my $GFDOs = $gfdoa->fetch_all_by_GenomicFeatureDisease($GFD);
ok(scalar @$GFDOs == 2, 'fetch_all_by_GenomicFeatureDisease');

done_testing();
1;
