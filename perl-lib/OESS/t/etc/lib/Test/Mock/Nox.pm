package Test::Mock::Nox;

use Net::DBus::Exporter qw(org.nddi.openflow);

use base qw(Net::DBus::Object);


sub new {
    my $class = shift;
    my $service = shift;
    my $self = $class->SUPER::new($service,"/controller1");
    
    bless $self, $class;

    dbus_signal("link_event",['uint64','int16','uint64','int16','string']);
    dbus_signal("traceroute_packet_in",['uint64','int16','uint64','int16','string']); 
    #dbus_signal("topo_port_status",[]);
    dbus_method("register_for_traceroute_in",[],['uint16']);

    dbus_method("install_datapath_flow",[],['uint64']);
    dbus_method("send_traceroute_packet",['uint64','int32','uint64','uint64'],[]);
    dbus_method("send_datapath_flow",['uint64',['dict','string',['variant']],['array',['struct','uint16',['variant']] ] ],['uint64']);
    dbus_method("send_barrier",['uint64'],['uint64']);
    my $reactor = Net::DBus::Reactor->main();
$reactor->add_timeout('15000',Net::DBus::Callback->new( method => sub { return; } ) );
$reactor->run();

    
    return $self;
    }
   

sub register_for_traceroute_in {

    return 1;
}

sub send_datapath_flow {

    return 1;
}

sub send_traceroute_packet {

    return;
}

sub send_datapath_flow {

    return 1;
}

sub send_barrier {

    return 1;
}



    
1;
