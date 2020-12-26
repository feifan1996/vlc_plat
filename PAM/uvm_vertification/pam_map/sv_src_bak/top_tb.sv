`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "my_if_p2fr.sv"
`include "my_if_f2p.sv"
`include "my_packet_sent.sv"
`include "my_packet_rec.sv"
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor_f2p.sv"
`include "my_monitor_p2fr.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_sequence.sv"
`include "my_env.sv"
`include "base_test.sv"

module top_tb;

	parameter	AXI_DATA_WIDTH = 32,
				AD_CVER_WIDTH  = 12;

int max_cycle_t = 1000;//wait time for test
reg clk;
reg arst_n;

my_if_f2p#(AXI_DATA_WIDTH) f2p_inf(clk, arst_n);
my_if_p2fr#(AD_CVER_WIDTH) p2fr_inf(clk, arst_n);

pam_map#(
	.PAM_MAP_AXI_DATA_WIDTH(AXI_DATA_WIDTH), // the width of received data
	.AD_CVER_WIDTH(AD_CVER_WIDTH)  // ad/da width
) my_dut (
/**********************  ctrl signal ******************************/
	.clk(clk),
	.arst_n(arst_n),
/**********************  interface with axi stream fifo ******************************/	
	.M_AXIS_tdata	(f2p_inf.M_AXIS_tdata		),
	.M_AXIS_tlast	(),
	.M_AXIS_tkeep	(f2p_inf.M_AXIS_tkeep		),
	.M_AXIS_tvalid	(f2p_inf.M_AXIS_tvalid		),
	.M_AXIS_tready	(f2p_inf.M_AXIS_tready		),
/**********************  interface with add_frame_head ******************************/	
	.PamMap2AddHead_ready	(p2fr_inf.p2a_ready		)			,
	.PamMap2AddHead_valid	(p2fr_inf.p2a_valid		)			,
	.PamMap2AddHead_data	(p2fr_inf.p2a_data		)
);


initial begin
   clk = 0;
   forever begin
      #100 clk = ~clk;
   end
end

initial begin
   arst_n = 1'b0;
   #1000;
   arst_n = 1'b1;
end

initial begin
   run_test("base_test");
end

initial begin
   uvm_config_db#(virtual my_if_f2p#(AXI_DATA_WIDTH))::set(null, "uvm_test_top.env.i_agt.drv", "vif_f2p", f2p_inf);
   uvm_config_db#(virtual my_if_p2fr#(AD_CVER_WIDTH))::set(null, "uvm_test_top.env.i_agt.drv", "vif_p2fr", p2fr_inf);
   uvm_config_db#(virtual my_if_f2p#(AXI_DATA_WIDTH))::set(null, "uvm_test_top.env.i_agt.mon_f2p", "vif_f2p", f2p_inf);
   uvm_config_db#(virtual my_if_p2fr#(AD_CVER_WIDTH))::set(null, "uvm_test_top.env.o_agt.mon_p2fr", "vif_p2fr", p2fr_inf);
   uvm_config_db#(int)::set(null, "uvm_test_top.env.i_agt.drv", "max_cycle_t", max_cycle_t);
end

endmodule
