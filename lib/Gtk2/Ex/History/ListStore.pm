# Copyright 2007, 2008, 2009, 2010 Kevin Ryde

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
# The TreeDragDest handlers here allow row dragging between the back,
# forward and current lists as displayed in Gtk2::Ex::History::Dialog.
#
# Cf DragByCopy in the drop handler.

package Gtk2::Ex::History::ListStore;
use 5.008;
use strict;
use warnings;
use List::Util;
use Gtk2;

# uncomment this to run the ### lines
#use Smart::Comments;

our $VERSION = 1;

use Glib::Object::Subclass
  'Gtk2::ListStore',
  interfaces => [ 'Gtk2::TreeDragDest' ];

use constant { COL_PLACE => 0 };

sub INIT_INSTANCE {
  my ($self) = @_;
  $self->set_column_types ('Glib::Scalar');
}

sub ROW_DROP_POSSIBLE {
  my ($self, $dst_path, $sel) = @_;
  ### History ListStore ROW_DROP_POSSIBLE

  $dst_path->get_depth == 1 or do {
    ### no, depth: $dst_path->get_depth
    return 0;
  };
  my ($src_model, $src_path) = $sel->get_row_drag_data
    or do {
      ### no, source data not a row
      return 0;
    };

  ### others: map {defined} $self->{'others'}
  ### others: @{$self->{'others'}}
  unless (List::Util::first { $src_model == ($_||0) }
          $self, @{$self->{'others'}}) {
    ### no, source not self or other
    return 0;
  }

  ### yes
  return 1;
}

# insert_with_values() always for code here and in Dialog
BEGIN {
  if (! Gtk2::ListStore->can('insert_with_values')) {
    eval "#line ".(__LINE__+1)." \"".__FILE__."\"\n" . <<'HERE' or die;
    sub insert_with_values {
      my $self = shift;
      my $pos = shift;
      $self->set ($self->insert($pos), @_);
    }
    1;
HERE
  }
}

sub DRAG_DATA_RECEIVED {
  my ($self, $dst_path, $sel) = @_;
  $self->ROW_DROP_POSSIBLE ($dst_path, $sel)
    or return 0;

  my ($src_model, $src_path) = $sel->get_row_drag_data
    or do {
      ### no, source data not a row
      return 0;
    };
  my $src_iter = $src_model->get_iter ($src_path) || do {
    ### oops, source row gone
    return 0;
  };
  my $place = $src_model->get($src_iter, 0);

  if ($self->{'current'}) {
    ### yes, by goto drop on current
    $self->{'history'}->goto ($place);
  } else {
    ### yes, by insert
    my ($dst_index) = $dst_path->get_indices;
    $self->insert_with_values ($dst_index, COL_PLACE, $place);
  }
  return 1;
}

1;
__END__
