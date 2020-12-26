// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : tb_Bit_Align.v
// Author        : 
// Created On    : 2020-12-16 11:12
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __TB_PAM_MAP_V__
`define __TB_PAM_MAP_V__

`timescale 1ns/1ps

module tb_pam_map;

localparam	DATA_WIDTH = 32;
localparam PAM_ORDER = 4;
localparam MEM_ADDR_WIDTH = 7;
localparam AD_CVER_WIDTH = 12;

/*************************  interface define ***********************************/
	reg clk,arst_n;
	/*********  interface with axi stream fifo ******************************/	
	reg	[DATA_WIDTH-1:0] M_AXIS_tdata;
	reg M_AXIS_tlast, M_AXIS_tvalid;
	reg	[(DATA_WIDTH >> 3)-1:0] M_AXIS_tkeep;
	wire M_AXIS_tready;
	/*********  interface with add_frame_head ******************************/	
	reg	M_out_ready;
	wire M_out_valid;
	wire [2*AD_CVER_WIDTH-1:0]	M_out_pam_data;

	/******************* data clear and clk generation  ********************/
	initial begin
		clk = 1'b0;
		arst_n = 1'b0;
		rst_all_signal;
		#9.5;
		arst_n = 1'b1;
	end
	always #1 clk <= ~clk;

/*****************  input simulation data ************************************/
	initial begin //test keep signal and mem
		#1.1;
		//input_data_wait_ready_full_keep;
		//#10;
		//input_data_wait_ready_unfull_keep;
		//#10;
		//input_data_nowait_ready_full_keep;
		//#10;
		//input_data_nowait_ready_unfull_keep;
	end

	initial begin //test valid signal
		#1.1;
		//input_data_nowait_ready_variable_valid;
		//#10;
		//input_data_wait_ready_variable_valid;
	end

	initial begin //test variable ready
		#1.1;
		fork
			input_data_wait_ready_full_keep_vs_out;
			#20 out_data_variable_ready;
		join
	end

task out_data_variable_ready;
	integer i;
	begin
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_out_ready <= (1'b1 == i[2]) ? 1'b1:1'b0;
		end
		@(posedge clk);
		M_out_ready <= 1'b0;
	end
endtask

task input_data_nowait_ready_variable_valid;
	integer i;
	begin
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= i;
			M_AXIS_tkeep <= 4'b1111;
			M_AXIS_tvalid <= (1'b1 == i[2]) ? 1'b1:1'b0;
		end
			@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask

task input_data_wait_ready_variable_valid;
	integer i;
	begin
		wait(1'b1 == M_AXIS_tready);
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= i;
			M_AXIS_tkeep <= 4'b1111;
			M_AXIS_tvalid <= (1'b1 == i[2]) ? 1'b1:1'b0;

		end
			@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask

task input_data_wait_ready_unfull_keep;
	integer i;
	begin
		wait(1'b1 == M_AXIS_tready);
		for(i = 0; i < 500; i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= 32'hff_11_ff_00 + i;
			M_AXIS_tvalid <= 1'b1;
			M_AXIS_tkeep <= 4'b1110;
		end
		@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask

task input_data_nowait_ready_unfull_keep;
	integer i;
	begin
		for(i = 0; i < 500; i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= 32'hff_11_ff_00 + i;
			M_AXIS_tvalid <= 1'b1;
			M_AXIS_tkeep <= 4'b1110;
		end
		@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask


task input_data_nowait_ready_full_keep;
	integer i;
	begin
		for(i = 0; i < 500; i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= i;
			M_AXIS_tvalid <= 1'b1;
			M_AXIS_tkeep <= 4'b1111;
		end
		@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask

task input_data_wait_ready_full_keep;
	integer i;
	begin
		wait(1'b1 == M_AXIS_tready);
		for(i = 0; i < 500; i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= i;
			M_AXIS_tvalid <= 1'b1;
			M_AXIS_tkeep <= 4'b1111;
		end
		@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask

task input_data_wait_ready_full_keep_vs_out;
	integer i;
	begin
		wait(1'b1 == M_AXIS_tready);
		for(i = 0; i < 500; i=i+1) begin
			@(posedge clk);
			M_AXIS_tdata <= 32'h12_34_56_00 + i;
			M_AXIS_tvalid <= 1'b1;
			M_AXIS_tkeep <= 4'b1111;
		end
		@(posedge clk);
			M_AXIS_tdata <= 'b0;
			M_AXIS_tvalid <= 'b0;
			M_AXIS_tkeep <= 'b0;
	end
endtask



task rst_all_signal;
	begin
		M_AXIS_tdata <= 'b0;
		M_AXIS_tlast <= 1'b0;
		M_AXIS_tkeep <= 'b0;
		M_AXIS_tvalid <= 1'b0;
		M_out_ready <= 1'b0;
	end
endtask



pam_map #(
	.PAM_MAP_AXI_DATA_WIDTH(DATA_WIDTH),
	.PAM_ORDER(PAM_ORDER),
	.PAM_MAP_MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
	.AD_CVER_WIDTH(AD_CVER_WIDTH)
) uut_pam_map(
	.clk					(clk				)				,	
	.arst_n					(arst_n				)				,
	.M_AXIS_tdata			(M_AXIS_tdata		)				,
	.M_AXIS_tlast			(M_AXIS_tlast		)				,
	.M_AXIS_tkeep			(M_AXIS_tkeep		)				,
	.M_AXIS_tvalid			(M_AXIS_tvalid		)				,
	.M_AXIS_tready			(M_AXIS_tready		)				,
	.PamMap2AddHead_ready	(M_out_ready		)				,
	.PamMap2AddHead_valid	(M_out_valid		)				,
	.PamMap2AddHead_data	(M_out_pam_data		)				
);
endmodule

`endif

