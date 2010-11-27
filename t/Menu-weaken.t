#!/usr/bin/perl -w

# Copyright 2010 Kevin Ryde

# This file is part of Gtk2-Ex-WidgetBits.
#
# Gtk2-Ex-WidgetBits is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# Gtk2-Ex-WidgetBits is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for more details.
#
# You should have received a copy of the GNU General Public License along
# with Gtk2-Ex-WidgetBits.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Test::More;

use lib 't';
use MyTestHelpers;
BEGIN { MyTestHelpers::nowarnings() }

# Test::Weaken 3 for "contents"
eval "use Test::Weaken 3; 1"
  or plan skip_all => "Test::Weaken 3 not available -- $@";

require Gtk2::Ex::History;
require Gtk2::Ex::History::Menu;

require Gtk2;
Gtk2->init_check
  or plan skip_all => 'due to no DISPLAY available';
plan tests => 2;

require Test::Weaken::Gtk2;
{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $history = Gtk2::Ex::History->new;
         my $menu = Gtk2::Ex::History::Menu->new (history => $history);
         return [ $menu, $history ];
       },
       destructor => \&Test::Weaken::Gtk2::destructor_destroy,
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'Test::Weaken deep garbage collection');
  if ($leaks) {
    eval { diag "Test-Weaken ", explain($leaks) }; # explain in Test::More 0.82
  }
}

{
  my $leaks = Test::Weaken::leaks
    ({ constructor => sub {
         my $history = Gtk2::Ex::History->new;
         my $menu = Gtk2::Ex::History::Menu->new_popup (history => $history);
         return [ $menu, $history ];
       },
       destructor => \&Test::Weaken::Gtk2::destructor_destroy,
       contents => \&Test::Weaken::Gtk2::contents_container,
     });
  is ($leaks, undef, 'Test::Weaken deep garbage collection - with popup');
  if ($leaks) {
    eval { diag "Test-Weaken ", explain($leaks) }; # explain in Test::More 0.82
  }
}

exit 0;
