`ifndef MY_MONITOR_F2P__SV
`define MY_MONITOR_F2P__SV
class my_monitor_f2p#(int AXI_DATA_WIDTH=32) extends uvm_monitor;

	virtual my_if_f2p#(AXI_DATA_WIDTH) vif_f2p;
	
	uvm_analysis_port #(my_packet_sent#(AXI_DATA_WIDTH))  ap;
	
	`uvm_component_param_utils(my_monitor_f2p#(AXI_DATA_WIDTH))
	function new(string name = "my_monitor_f2p", uvm_component parent = null);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual my_if_f2p#(AXI_DATA_WIDTH))::get(this, "", "vif_f2p", vif_f2p))
			`uvm_fatal("my_monitor_f2p", "virtual interface must be set for vif_f2p!!!")
		ap = new("ap", this);
	endfunction
	
	extern task main_phase(uvm_phase phase);
	extern task collect_one_pkt(my_packet_sent#(AXI_DATA_WIDTH) pkt_sent);
endclass

task my_monitor_f2p::main_phase(uvm_phase phase);
	my_packet_sent pkt_sent;
	while(1) begin
		pkt_sent = new("pkt_sent");
		collect_one_pkt(pkt_sent);
		ap.write(pkt_sent);
	end
endtask

task my_monitor_f2p::collect_one_pkt(my_packet_sent pkt_sent);
	
	bit [AXI_DATA_WIDTH-1:0] data_q;
	bit [(AXI_DATA_WIDTH>>3)-1:0] keep_q;
	
   
	while(1) begin 
		@(posedge vif_f2p.clk);
		if(vif_f2p.M_AXIS_tvalid && vif_f2p.M_AXIS_tready) 
			break;
	end

	`uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
		pkt_sent.data = vif_f2p.M_AXIS_tdata;
		pkt_sent.keep = vif_f2p.M_AXIS_tkeep;
	`uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
