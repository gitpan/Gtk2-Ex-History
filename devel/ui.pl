#!/usr/bin/perl -w

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

use strict;
use warnings;
use Gtk2 '-init';
use Gtk2::Ex::History;
use Gtk2::Ex::History::Action;

use FindBin;
my $progname = $FindBin::Script;

my $history = Gtk2::Ex::History->new;
$history->goto ('AAA');
$history->goto ('BBB');
$history->goto ('CCC');
$history->goto ('DDD');
$history->goto ('EEE');
$history->goto ('FFF');
$history->goto ('GGG');
$history->back(3);
$history->signal_connect
  ('notify::current' => sub {
     print "$progname: notify::current ",$history->get('current'),"\n";;
   });

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit; });

my $actiongroup = Gtk2::ActionGroup->new ("main");
$actiongroup->add_action
  (Gtk2::Ex::History::Action->new (name    => 'Back',
                                   way     => 'back',
                                   history => $history));
$actiongroup->add_action
  (Gtk2::Ex::History::Action->new (name    => 'Forward',
                                   way     => 'forward',
                                   history => $history));

my $ui = Gtk2::UIManager->new;
$ui->insert_action_group ($actiongroup, 0);
$toplevel->add_accel_group ($ui->get_accel_group);
$ui->add_ui_from_string ("
<ui>
  <toolbar  name='ToolBar'>
    <toolitem action='Back'/>
    <toolitem action='Forward'/>
  </toolbar>
</ui>");

my $toolbar = $ui->get_widget ('/ToolBar');
$toplevel->add ($toolbar);

my $req = $toolbar->size_request;
$toplevel->set_default_size (200, 100);

$toplevel->show_all;
Gtk2->main;
exit 0;
