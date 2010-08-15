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
# Draw a history widget and write it to the given output file in PNG format.
# The default output file is /tmp/screenshot.png

use strict;
use warnings;
use File::Basename;
use FindBin;
use POSIX;
use Gtk2 '-init';
use Gtk2::Ex::History;
use Gtk2::Ex::History::Button;


# PNG spec 11.3.4.2 suggests RFC822 (or rather RFC1123) for CreationTime
use constant STRFTIME_FORMAT_RFC822 => '%a, %d %b %Y %H:%M:%S %z';

my $progname = $FindBin::Script; # basename part
print "progname '$progname'\n";
my $output_filename = (@ARGV >= 1 ? $ARGV[0] : '/tmp/screenshot.png');

my $history = Gtk2::Ex::History->new;
$history->goto ('Further forward');
$history->goto ('Thing forward');
$history->goto ('Thing now displayed');
$history->goto ('Thing last visited');
$history->goto ('The thing before');
$history->goto ('An old thing');
$history->back(2);

my $toplevel = Gtk2::Window->new('toplevel');
$toplevel->signal_connect (destroy => sub { Gtk2->main_quit });

my $vbox = Gtk2::VBox->new;
$toplevel->add ($vbox);

my $button = Gtk2::Ex::History::Button->new (history => $history,
                                             way => 'back');
$vbox->pack_start ($button, 0,0,0);

Glib::Timeout->add
  (2000,
   sub {
     my $window = $toplevel->window;
     my ($width, $height) = $window->get_size;
     my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable ($window,
                                                        undef, # colormap
                                                        0,0, 0,0,
                                                        $width, $height);
     $pixbuf->save
       ($output_filename, 'png',
        'tEXt::Title'         => 'History Button Screenshot',
        'tEXt::Author'        => 'Kevin Ryde',
        'tEXt::Copyright'     => 'Copyright 2010 Kevin Ryde',
        'tEXt::Creation Time' => POSIX::strftime (STRFTIME_FORMAT_RFC822,
                                                  localtime(time)),
        'tEXt::Description'   => 'A sample screenshot of a Gtk2::Ex::History::Button display',
        'tEXt::Software'      => "Generated by $progname",
        'tEXt::Homepage'      => 'http://user42.tuxfamily.org/gtk2-ex-history/index.html',
        # must be last or gtk 2.18 botches the text keys
        compression           => 9,
       );
     print "wrote $output_filename\n";
     Gtk2->main_quit;
     return 0; # Glib::SOURCE_REMOVE
   });

$toplevel->show_all;
Gtk2->main;
exit 0
