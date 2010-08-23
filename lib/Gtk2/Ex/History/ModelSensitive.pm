# Copyright 2010 Kevin Ryde

# This file is part of Gtk2-Ex-History.
#
# Gtk2-Ex-History is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 3, or (at your option) any later
# version.
#
# Gtk2-Ex-History is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-History.  If not, see <http://www.gnu.org/licenses/>.


# An internal part of Gtk2::Ex::History.
#
# act on 'sensitive' property, or set_sensitive() method?

package Gtk2::Ex::History::ModelSensitive;
use 5.008;
use strict;
use warnings;
use Gtk2 1.220;
use Gtk2::Ex::History;
use Scalar::Util;
use Glib::Ex::SignalIds;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 2;

sub new {
  my ($class, $target, $model) = @_;
  ### ModelSensitive: $target && "$target", $model && "$model"
  my $self = bless {}, $class;
  $self->set_target ($target);
  $self->set_model ($model);
  return $self;
}

sub set_target {
  my ($self, $target) = @_;
  Scalar::Util::weaken ($self->{'target'} = $target);
  _update_sensitive ($self);
}
sub set_model {
  my ($self, $model) = @_;
  Scalar::Util::weaken ($self->{'model'} = $model);
  $self->{'ids'} = $model && do {
    Scalar::Util::weaken (my $weak_self = $self);
    ### ModelSensitive connect
    Glib::Ex::SignalIds->new
        ($model,
         $model->signal_connect (row_inserted => \&_do_model_insdel,
                                 \$weak_self),
         $model->signal_connect (row_deleted => \&_do_model_insdel,
                                 \$weak_self));
  };
  _update_sensitive ($self);
}

# 'row-inserted' and 'row-deleted' handler for the model
sub _do_model_insdel {
  ### ModelSensitive _do_model_insdel
  # different args for inserted and deleted, but last is userdata
  my $ref_weak_self = $_[-1];
  my $self = $$ref_weak_self || return;
  _update_sensitive ($self);
}

sub _update_sensitive  {
  my ($self) = @_;
  ### ModelSensitive _update_sensitive: $self->{'target'} && "$self->{'target'}", $self->{'model'} && $self->{'model'}->get_iter_first
  if (my $target = $self->{'target'}) {
    $target->set_sensitive
      ($self->{'model'} && $self->{'model'}->get_iter_first);
  }
}

1;
__END__
