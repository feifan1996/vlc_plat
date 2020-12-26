`ifndef MY_AGENT__SV
`define MY_AGENT__SV

class my_agent extends uvm_agent ;
	my_sequencer  sqr;
	my_driver     drv;
	my_monitor_f2p    mon_f2p;
	my_monitor_p2fr    mon_p2fr;
	
	uvm_analysis_port #(my_packet_sent)  ap_sent;
	uvm_analysis_port #(my_packet_rec)  ap_rec;
	
	function new(string name, uvm_component parent);
	   super.new(name, parent);
	endfunction 
	
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
	
	`uvm_component_utils(my_agent)
endclass 


function void my_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (is_active == UVM_ACTIVE) begin
		sqr = my_sequencer::type_id::create("sqr", this);
		drv = my_driver::type_id::create("drv", this);
		mon_f2p = my_monitor_f2p::type_id::create("mon_f2p",this);
	end
	else
		mon_p2fr = my_monitor_p2fr::type_id::create("mon_p2fr", this);
endfunction 

function void my_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if (is_active == UVM_ACTIVE) begin
		drv.seq_item_port.connect(sqr.seq_item_export);
		ap_sent = mon_f2p.ap;
	end
	else
		ap_rec  = mon_p2fr.ap;
endfunction

`endif

