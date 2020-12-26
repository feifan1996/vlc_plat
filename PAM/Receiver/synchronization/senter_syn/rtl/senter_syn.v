// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : senter_syn.v
// Author        : 
// Created On    : 2020-12-18 16:15
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __SENTER_SYN_V__
`define __SENTER_SYN_V__

`timescale 1ns/1ps

module senter_syn#(
	parameter		DATA_WIDTH = 32, // the width of received data
					PAM_ORDER = 4, // the order of PAM
					MEM_ADDR_WIDTH = 10, // width of addr of mem for pam map
			 		AD_CVER_WIDTH = 12,  // ad/da width
					ADDR_MEM_WIDTH	=	10,// width of addr
					WIDTH_RESULT = 6,// the width of cov result
					LENGTH_DATA = 1024,//the lentgh of data
//					LENGTH_PILOT = 16,// the lentgh of pilot
					LENTGRH_M_SEQ = 31,// lentgh of m sequence
					THRESHOLD = 10,
					SYN_MEM_ADDR_WIDTH = 7 // width of addr of mem
)(
	/**************************** ctrl signal  ******************************************/
	input																		clk,
	input																		arst_n,
	/************************ interface with axi_stream fifo  ******************/
	input			[DATA_WIDTH-1:0]											M_AXIS_tdata,
	input 																		M_AXIS_tlast,
	input			[(DATA_WIDTH >> 3)-1:0]									    M_AXIS_tkeep,
	input																		M_AXIS_tvalid,
	output			     														M_AXIS_tready,
	/************************* interface with demodulation *****************************/
	input																	syn_demodu_ready,
	output																	syn_demodu_valid,
	output			[AD_CVER_WIDTH-1:0]										syn_demodu_data
);	



	wire [AD_CVER_WIDTH-1:0]	ad_rec_data;

syn#(
		.AD_CVER_WIDTH(AD_CVER_WIDTH), // the width of received data
		.PAM_ORDER(PAM_ORDER), // the order of PAM
		.WIDTH_RESULT(WIDTH_RESULT),// the width of cov result
		.LENGTH_DATA(LENGTH_DATA),//the lentgh of data
		.LENTGRH_M_SEQ(LENTGRH_M_SEQ),// lentgh of m sequence
		.THRESHOLD(THRESHOLD),
		.MEM_ADDR_WIDTH(SYN_MEM_ADDR_WIDTH) // width of addr of mem
)
uut_syn(
/**********************  ctrl signal ******************************/
	.clk				(clk				)				,
	.arst_n				(arst_n				)				,
/**********************  interface with AD ******************************/	
	.ad_rec_data		(ad_rec_data		)				,
/**********************  interface with demodulation ******************************/	
	.syn_demodu_ready	(syn_demodu_ready	)				,
	.syn_demodu_valid	(syn_demodu_valid	)				,
	.syn_demodu_data	(syn_demodu_data	)
);






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
	.sent_data			(ad_rec_data				)
);



endmodule

`endif

