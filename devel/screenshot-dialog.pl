#!/usr/bin/perl -w

# Copyright 2008, 2009, 2010 Kevin Ryde

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


# Usage: perl screenshot.pl [outputfile.png]
#
# Make a screenshot of a sample history dialog and write it to the given
# output file in PNG format.  The default output file is
# /tmp/screenshot-dialog.png
#

use strict;
use warnings;
use File::Basename;
use POSIX;
use Gtk2 '-init';
use Gtk2::Ex::History;
use Gtk2::Ex::History::Dialog;
use Gtk2::Ex::Units;

use lib::abs '.';
use Gtk2ExWindowManagerFrame;

# PNG spec 11.3.4.2 suggests RFC822 (or rather RFC1123) for CreationTime
use constant STRFTIME_FORMAT_RFC822 => '%a, %d %b %Y %H:%M:%S %z';

use FindBin;
my $progname = $FindBin::Script; # basename part
print "progname '$progname'\n";
my $output_filename = (@ARGV >= 1 ? $ARGV[0] : '/tmp/screenshot-dialog.png');

my $history = Gtk2::Ex::History->new;
$history->goto ('Further forward');
$history->goto ('Thing forward');
$history->goto ('Thing now displayed');
$history->goto ('Thing last visited');
$history->goto ('The thing before');
$history->goto ('An old thing');
$history->back(2);

my $dialog = Gtk2::Ex::History::Dialog->new (history => $history);
$dialog->signal_connect (destroy => sub { Gtk2->main_quit });

Glib::Timeout->add
  (2000,
   sub {
     my $pixbuf = Gtk2ExWindowManagerFrame::widget_to_pixbuf_with_frame ($dialog);
     $pixbuf->save
       ($output_filename, 'png',
        'tEXt::Title'         => 'History Dialog Screenshot',
        'tEXt::Author'        => 'Kevin Ryde',
        'tEXt::Copyright'     => 'Copyright 2010 Kevin Ryde',
        'tEXt::Creation Time' => POSIX::strftime (STRFTIME_FORMAT_RFC822,
                                                  localtime(time)),
        'tEXt::Description'   => 'A sample screenshot of a Gtk2::Ex::History::Dialog display',
        'tEXt::Software'      => "Generated by $progname",
        'tEXt::Homepage'      => 'http://user42.tuxfamily.org/gtk2-ex-history/index.html',
        # must be last or gtk 2.18 botches the text keys
        compression           => 9,
       );
     print "wrote $output_filename\n";
     Gtk2->main_quit;
     return 0; # Glib::SOURCE_REMOVE
   });

Gtk2::Ex::Units::set_default_size_with_subsizes
  ($dialog, [ $dialog->{'back_treeview'}, '30 ems', '8 lines' ]);
$dialog->show_all;
Gtk2->main;
exit 0
