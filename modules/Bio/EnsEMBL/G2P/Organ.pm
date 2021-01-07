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

package Bio::EnsEMBL::G2P::Organ;

use Bio::EnsEMBL::Storable;
use Bio::EnsEMBL::Utils::Argument qw(rearrange);

our @ISA = ('Bio::EnsEMBL::Storable');

sub new {
  my $caller = shift;
  my $class = ref($caller) || $caller;

  my ($organ_id, $name, $panel_id, $adaptor) =
    rearrange(['organ_id', 'name', 'panel_id', 'adaptor'], @_);

  my $self = bless {
    'organ_id' => $organ_id,
    'name' => $name,
    'panel_id' => $panel_id,
    'adaptor' => $adaptor,
  }, $class;

  return $self;
}

sub organ_id {
  my $self = shift;
  $self->{organ_id} = shift if @_;
  return $self->{organ_id};
}

sub dbID {
  my $self = shift;
  $self->{organ_id} = shift if @_;
  return $self->{organ_id};
}

sub name {
  my $self = shift;
  $self->{name} = shift if @_;
  return $self->{name};
}

sub panel_id {
  my $self = shift;
  $self->{panel_id} = shift if @_;
  return $self->{panel_id};
}

1;
