`ifndef MY_MONITOR_P2FR__SV
`define MY_MONITOR_P2FR__SV
class my_monitor_p2fr extends uvm_monitor;

	localparam	AD_CVER_WIDTH = 12;

	virtual my_if_p2fr vif_p2fr;
	
	uvm_analysis_port #(my_packet_rec)  ap;
	
	`uvm_component_utils(my_monitor_p2fr)
	function new(string name = "my_monitor_p2fr", uvm_component parent = null);
		super.new(name, parent);
	endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if_p2fr)::get(this, "", "vif_p2fr", vif_p2fr))
         `uvm_fatal("my_monitor_p2fr", "virtual interface must be set for vif_p2fr!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(my_packet_rec pkt_rec);
endclass

task my_monitor_p2fr::main_phase(uvm_phase phase);
   my_packet_rec pkt_rec;
   while(1) begin
      pkt_rec = new("pkt_rec");
      collect_one_pkt(pkt_rec);
      ap.write(pkt_rec);
   end
endtask

task my_monitor_p2fr::collect_one_pkt(my_packet_rec pkt_rec);
	
	bit [2*AD_CVER_WIDTH-1:0] data_q;
   
	while(1) begin 
		@(posedge vif_p2fr.clk);
		if(vif_p2fr.p2a_valid && vif_p2fr.p2a_ready) 
			break;
	end

	`uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
		pkt_rec.data = vif_p2fr.p2a_data;
		//pkt_rec.print();
	`uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
