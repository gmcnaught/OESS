#!/usr/bin/perl

use strict;
use Data::Dumper;
use Net::DBus;
use FindBin;
use Net::DBus::Reactor;
use lib "$FindBin::Bin/lib/";
use Test::Mock::Nox;


### Quick script to run a fake NOX dbus on org.nddi.openflow/controller1 to remove it as a dependency

my $bus = Net::DBus->system;
my $service = $bus->export_service("org.nddi.openflow");
my $nox = Test::Mock::Nox->new($service);

sub dummy_callback {
    warn Dumper($nox);
    return 1;
}
