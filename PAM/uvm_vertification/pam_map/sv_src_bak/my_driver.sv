`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver#(int AXI_DATA_WIDTH = 32, AD_CVER_WIDTH = 12) extends uvm_driver#(my_transaction#(AXI_DATA_WIDTH));

   virtual my_if_f2p#(AXI_DATA_WIDTH) vif_f2p;
   virtual my_if_p2fr#(AD_CVER_WIDTH) vif_p2fr;
   int max_cycle_t;

   `uvm_component_param_utils(my_driver#(AXI_DATA_WIDTH,AD_CVER_WIDTH))
   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual my_if_f2p#(AXI_DATA_WIDTH))::get(this, "", "vif_f2p", vif_f2p))
			`uvm_fatal("my_driver", "virtual interface must be set for vif_f2p!!!")
		if(!uvm_config_db#(virtual my_if_p2fr#(AD_CVER_WIDTH))::get(this, "", "vif_p2fr", vif_p2fr))
			`uvm_fatal("my_driver", "virtual interface must be set for vif_p2fr!!!")  
		if(!uvm_config_db#(int)::get(this, "", "max_cycle_t", max_cycle_t))
			`uvm_fatal("my_driver", "virtual interface must be set for vif_p2fr!!!")  
	endfunction

   extern task main_phase(uvm_phase phase);
   extern task lauch_dut(my_transaction tr);
   extern task drive_one_pkt(my_transaction tr);
   extern task receive_one_pkt(my_transaction tr);
   extern task overtime(int t);
endclass

task my_driver::main_phase(uvm_phase phase);
   vif_f2p.M_AXIS_tdata <= 'b0;
   vif_f2p.M_AXIS_tkeep <= 'b0;
   vif_f2p.M_AXIS_tvalid <= 'b0;
   vif_p2fr.p2a_ready <= 'b0;
   while(!vif_f2p.arst_n)
      @(posedge vif_f2p.clk);
   while(1) begin
      seq_item_port.get_next_item(req);
      lauch_dut(req);
      seq_item_port.item_done();
   end
endtask


task my_driver::lauch_dut(my_transaction tr);
	fork:enable_dut 
		fork //thread0:drive signal to dut
			drive_one_pkt(tr);
			receive_one_pkt(tr);
		join
		overtime(max_cycle_t);//thread1:
	join_any
	disable enable_dut;
endtask

task my_driver::drive_one_pkt(my_transaction tr);

	int  data_size;

	data_size = tr.data.size; 
	`uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
	
	for(int i=0; i < data_size; i=i) begin
		@(posedge vif_f2p.clk);
		vif_f2p.M_AXIS_tdata <= tr.data[i];
		vif_f2p.M_AXIS_tkeep <= tr.keep[i];
		vif_f2p.M_AXIS_tvalid <= 1'b1;
		if(1'b1 == vif_f2p.M_AXIS_tready) 
			i = i + 1;
		for(int j=0; j<tr.num_interval_valid; j++ ) begin
			@(posedge vif_f2p.clk);
			vif_f2p.M_AXIS_tvalid <= 1'b0;
		end
	end
	
	@(posedge vif_f2p.clk) begin
		vif_f2p.M_AXIS_tdata <= 'b0;
		vif_f2p.M_AXIS_tkeep <= 'b0;
		vif_f2p.M_AXIS_tvalid <= 'b0;
	end

	`uvm_info("my_driver", "end drive one pkt", UVM_LOW);

endtask

task my_driver::receive_one_pkt(my_transaction tr);// need rewrite 

	int  data_size;

	data_size = tr.calc_sum_1_array()/2; 
	`uvm_info("my_driver", "begin to receive one pkt", UVM_LOW);
	
	for(int i=0; i < data_size; i=i) begin
		@(posedge vif_p2fr.clk);
		vif_p2fr.p2a_ready <= 1'b1;
		if(1'b1 == vif_p2fr.p2a_valid) 
			i = i + 1;
		for(int j=0; j<tr.num_interval_ready; j++ ) begin
			@(posedge vif_p2fr.clk);
			vif_p2fr.p2a_ready <= 1'b1;
		end

	end
	
	@(posedge vif_p2fr.clk) 
		vif_p2fr.p2a_ready <= 'b0;

	`uvm_info("my_driver", "end receive one pkt", UVM_LOW);

endtask

task my_driver::overtime(int t);

	repeat(t) @(vif_f2p.clk);
	
	`uvm_info("my_driver", "over run time!!!!", UVM_LOW);

endtask


`endif
