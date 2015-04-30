#!/usr/bin/perl
use strict;
use FindBin;
use Carp::Always;
use Data::Dumper;
use Test::More  tests => 7;#skip_all => 'Need to try using Dbus::MockObject / MockService';
use Net::DBus;
use OESS::DBus;

my $path;

BEGIN {
    if($FindBin::Bin =~ /(.*)/){
	$path = $1;
    }
}
use lib "$path";
use lib "$path/../lib/";
use OESS::Traceroute;
use OESS::Circuit;
use OESSDatabaseTester;

my $circuit_id = 101;

Log::Log4perl::init_and_watch('t/conf/logging.conf',10);

my $db = OESS::Database->new( config => OESSDatabaseTester::getConfigFilePath() );

my $circuit = OESS::Circuit->new( circuit_id => 101, db => $db);

my $bus = Net::DBus->test();
my $service = $bus->export_service("org.nddi.traceroute");

configure_mock_objects();

my $trace = OESS::Traceroute->new( $service,$db );

#get circuit_id;


#create circuit;
#my $circuit = OESS::Circuit->new(db => $db, circuit_id => $circuit_id);
ok(defined($circuit));
#diag Dumper($circuit);
my $endpoints = $circuit->get_endpoints;
ok(defined($endpoints));
diag Dumper ($endpoints);
#includes nox calls, going to test building traceroute flowrules first
#init_circuit_trace($circuit_id, $endpoints->[0]->{'interface_id'});

my $success =$trace->add_traceroute_transaction( circuit_id => $circuit_id,
                                                 ttl => 30,
                                                 remaining_endpoints => 1,#scalar @{$circuit->get_endpoints} -1,
                                                 source_endpoint => { dpid => 155569068800,
                                                                      port_no => $endpoints->[0]->{'port_no'}
                                                 }
    );
ok($success, "added traceroute transaction for circuit");
my $rules = $trace->build_trace_rules($circuit_id);
ok(defined $rules);
is ( scalar @$rules, scalar @{$circuit->get_flows()}, "number of rules in circuit matches number of rules in traceroute");
diag "Flows from Circuit: ". Dumper ($circuit->get_flows());
diag "Rules built by traceroute: ". Dumper ($rules);
#diag "traceroute transactions: ".Dumper ($trace->get_traceroute_transactions());

my $ttl = $trace->get_traceroute_transactions({circuit_id => $circuit_id});
diag Dumper($ttl);
is($ttl->{'ttl'},30, "TTL is set to 30");
#hitting process_trace_packet() to handle 
# 'dpid' => '155569080320',
#                    'match' => {
#                                 'dl_vlan' => 105,
#                                 'dl_dst' => '7295272898569',
#                                 'in_port' => '674',
#                                 'dl_type' => 34997
#                               },

$trace->process_trace_packet(155569080320,674,101);

#diag(Dumper($trace));
$ttl = $trace->get_traceroute_transactions({circuit_id => $circuit_id});
is ($ttl->{'ttl'},29,"ttl was decremented to 29");

#TODO test removal of traceroute when an impacted dpid/port combo goes down
#$trace->link_event_callback( );



sub configure_mock_objects{
    my $bus = shift;

    *{OESS::DBus::start_reactor} = sub { return 1 };

    return ;
}


