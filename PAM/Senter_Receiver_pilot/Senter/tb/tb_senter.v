// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : ../tb/tb_senter.v
// Author        : 
// Created On    : 2020-12-18 10:40
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef ___TB_SENTER_V__
`define ___TB_SENTER_V__

`timescale 1ns/1ps

module tb_senter;

	
/**************************** parameter and variable define  *****************************/
	/**************************  parameter define *************************************/
	parameter DATA_WIDTH = 32, // the width of received data
			  PAM_ORDER = 4, // the order of PAM
			  MEM_ADDR_WIDTH = 5, // width of addr of mem for pam map
			  AD_CVER_WIDTH = 12,  // ad/da width
			  ADDR_MEM_WIDTH = 5;// width of addr of mem for add head

	/**************************** tb variable define  ***********************************/
	reg clk, arst_n;
	/**********************  interface with axi stream fifo ******************************/	
	reg [DATA_WIDTH-1:0] M_AXIS_tdata;
	reg M_AXIS_tlast;
	reg [(DATA_WIDTH >> 3)-1:0]	 M_AXIS_tkeep;
	reg M_AXIS_tvalid;
	wire M_AXIS_tready;
	/*************************** interface with ad/da  *************************************/
	wire [AD_CVER_WIDTH-1:0] sent_data;

	/********************* rst signal and generate clock    *****************************/
	initial begin	
		arst_n = 1'b0;
		clk = 1'b0;
		rst_signal;
		#5.5;
		arst_n = 1'b1;
	end
	always #1 clk <= ~clk;


	initial begin
		#11.5;
		send_data;
	end


	task send_data;
		integer i;
		begin
			wait(1'b1 == M_AXIS_tready);
			for(i = 0; i < 1000; i = i) begin
				if(1'b1 == M_AXIS_tready) begin
					M_AXIS_tvalid <= 1'b1;
					M_AXIS_tkeep <= 4'hF;
					M_AXIS_tdata <= 32'h1234_5670 + i;
					//i <= i + 1;
				end
				else begin
					M_AXIS_tvalid <= 1'b0;
					M_AXIS_tkeep <= 4'h0;
					M_AXIS_tdata <= 32'h1234_5670 + i;
					//i <= i;
				end
				@(posedge clk);
				i = ( M_AXIS_tvalid && M_AXIS_tready ) ? i+1 : i;
			end
		end
	endtask



	task  rst_signal;
		begin
			M_AXIS_tdata <= 'b0;
			M_AXIS_tlast <= 'b0;
			M_AXIS_tkeep <= 'b0;
			M_AXIS_tvalid <= 'b0;
		end
	endtask


senter#(	
/******************** pam map ***************************/
	.DATA_WIDTH(DATA_WIDTH) , // the width of received data
	.PAM_ORDER(PAM_ORDER), // the order of PAM
	.MEM_ADDR_WIDTH(MEM_ADDR_WIDTH), // width of addr of mem for pam map
	.AD_CVER_WIDTH (AD_CVER_WIDTH),  // ad/da width
/*************** add head for frame ********************/	
	.ADDR_MEM_WIDTH(ADDR_MEM_WIDTH)// width of addr of mem for add head
) uut_senter(
	/**********************  ctrl signal ******************************/
	.clk				(clk				)										,
	.arst_n				(arst_n				)										,
/**********************  interface with axi stream fifo ******************************/	
	.M_AXIS_tdata		(M_AXIS_tdata				)								,
	.M_AXIS_tlast		(M_AXIS_tlast		   		)								,
	.M_AXIS_tkeep		(M_AXIS_tkeep 		   		)								,
	.M_AXIS_tvalid		(M_AXIS_tvalid		   		)								,
	.M_AXIS_tready		(M_AXIS_tready		   		)								,
/*************************** interface with ad/da  *************************************/
	.sent_data			(sent_data					)
);


endmodule

`endif

