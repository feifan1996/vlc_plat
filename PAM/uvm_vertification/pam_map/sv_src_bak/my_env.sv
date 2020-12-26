`ifndef MY_ENV__SV
`define MY_ENV__SV

class my_env#(int AXI_DATA_WIDTH=32, AD_CVER_WIDTH=12) extends uvm_env;

	my_agent#(AXI_DATA_WIDTH,AD_CVER_WIDTH)   i_agt;
	my_agent#(AXI_DATA_WIDTH,AD_CVER_WIDTH)   o_agt;
	my_model#(AXI_DATA_WIDTH,AD_CVER_WIDTH)   mdl;
	my_scoreboard#(AD_CVER_WIDTH) scb;
	
	uvm_tlm_analysis_fifo #(my_packet_rec#(AD_CVER_WIDTH)) agt_scb_fifo;
	uvm_tlm_analysis_fifo #(my_packet_sent#(AXI_DATA_WIDTH)) agt_mdl_fifo;
	uvm_tlm_analysis_fifo #(my_packet_rec#(AD_CVER_WIDTH)) mdl_scb_fifo;
	
	function new(string name = "my_env", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		i_agt = my_agent#(AXI_DATA_WIDTH,AD_CVER_WIDTH)::type_id::create("i_agt", this);
		o_agt = my_agent#(AXI_DATA_WIDTH,AD_CVER_WIDTH)::type_id::create("o_agt", this);
		i_agt.is_active = UVM_ACTIVE;
		o_agt.is_active = UVM_PASSIVE;
		mdl = my_model#(AXI_DATA_WIDTH,AD_CVER_WIDTH)::type_id::create("mdl", this);
		scb = my_scoreboard#(AD_CVER_WIDTH)::type_id::create("scb", this);
		agt_scb_fifo = new("agt_scb_fifo", this);
		agt_mdl_fifo = new("agt_mdl_fifo", this);
		mdl_scb_fifo = new("mdl_scb_fifo", this);
	endfunction
	
	extern virtual function void connect_phase(uvm_phase phase);
	
	`uvm_component_param_utils(my_env#(AXI_DATA_WIDTH,AD_CVER_WIDTH))
endclass

function void my_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	i_agt.ap_sent.connect(agt_mdl_fifo.analysis_export);
	mdl.port.connect(agt_mdl_fifo.blocking_get_export);
	mdl.ap.connect(mdl_scb_fifo.analysis_export);
	scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
	o_agt.ap_rec.connect(agt_scb_fifo.analysis_export);
	scb.act_port.connect(agt_scb_fifo.blocking_get_export); 
endfunction

`endif
