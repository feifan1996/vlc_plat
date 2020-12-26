// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : ../tb/tb_add_head_frame.v
// Author        : 
// Created On    : 2020-12-16 20:47
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef ___TB_ADD_HEAD_FRAME__
`define ___TB_ADD_HEAD_FRAME__

`timescale 1ns/1ps

module tb_add_head_frame;

	localparam  AD_CVER_WIDTH = 12;  // ad/da width
	localparam  ADDR_MEM_WIDTH	=	5;
	localparam  PAM_ORDER = 4;

	reg	clk, rst_n;
	reg	[2*AD_CVER_WIDTH-1:0] M_in_pam_data;
	reg	M_in_valid;
	wire M_in_ready;
	wire [AD_CVER_WIDTH-1:0] sent_data;
	
/***********************  ctrl signal set and clk generation *********************************/
	initial begin
		clk = 1'b0;
		rst_n = 1'b0;
		rst_all_signal;
		#10.5;
		rst_n = 1'b1;
	end
	always #1 clk <= ~clk;

/************************    input data       **************************/
	initial begin
		#5.5;
		input_data_wait_ready_variable_valid;
	end


task input_data_nowait_ready_variable_valid;
	integer i;
	begin
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_in_pam_data <= i;
			M_in_valid <= (1'b1 == i[2]) ? 1'b1:1'b0;
		end
			@(posedge clk);
			M_in_pam_data <= 'b0;
			M_in_valid <= 'b0;
	end
endtask
task input_data_wait_ready_variable_valid;
	integer i;
	begin
		wait(1'b1 == M_in_ready);
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_in_pam_data <= i;
			if(14 == i || 16 == i)
				M_in_valid <= 1'b0;
			else
				M_in_valid <= 1'b1;
		end
			@(posedge clk);
			M_in_pam_data <= 'b0;
			M_in_valid <= 'b0;
	end
endtask
task input_data_nowait_ready;
	integer i;
	begin
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_in_pam_data <= i;
			M_in_valid <= 1'b1;
		end
			@(posedge clk);
			M_in_pam_data <= 'b0;
			M_in_valid <= 'b0;
	end
endtask
task input_data_wait_ready;
	integer i;
	begin
		wait(1'b1 == M_in_ready);
		for(i=0;i<500;i=i+1) begin
			@(posedge clk);
			M_in_pam_data <= i;
			M_in_valid <= 1'b1;
		end
			@(posedge clk);
			M_in_pam_data <= 'b0;
			M_in_valid <= 'b0;
	end
endtask





task rst_all_signal;
	begin
		M_in_pam_data <= 'b0;
		M_in_valid <= 1'b0;
	end
endtask



add_head_frame#(
	.AD_CVER_WIDTH(AD_CVER_WIDTH),  // ad/da width
	.ADD_HEAD_MEM_ADDR_WIDTH(ADDR_MEM_WIDTH),
	.PAM_ORDER(PAM_ORDER)
) uut_add_head(
.clk							(clk				)				,
.rst_n							(rst_n				)				,
.PamMap2AddHead_data			(M_in_pam_data		)				,
.PamMap2AddHead_valid			(M_in_valid			)				,
.PamMap2AddHead_ready			(M_in_ready			)				,
.sent_data						(sent_data			)
);

endmodule

`endif

