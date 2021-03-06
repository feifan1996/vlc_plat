// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : senter.v
// Author        : 
// Created On    : 2020-12-18 10:15
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __SENTER_V__
`define __SENTER_V__

`timescale 1ns/1ps

module senter#(	
/******************** pam map ***************************/
	parameter		DATA_WIDTH = 32, // the width of received data
	parameter		PAM_ORDER = 4, // the order of PAM
	parameter		MEM_ADDR_WIDTH = 10, // width of addr of mem for pam map
	parameter 		AD_CVER_WIDTH = 12,  // ad/da width
/*************** add head for frame ********************/	
	parameter		ADDR_MEM_WIDTH	=	10// width of addr of mem for add head
)
(
	/**********************  ctrl signal ******************************/
	input																		clk,
	input																		arst_n,
/**********************  interface with axi stream fifo ******************************/	
	input			[DATA_WIDTH-1:0]											M_AXIS_tdata,
	input 																		M_AXIS_tlast,
	input			[(DATA_WIDTH >> 3)-1:0]									    M_AXIS_tkeep,
	input																		M_AXIS_tvalid,
	output			     														M_AXIS_tready,
/*************************** interface with ad/da  *************************************/
	output		[AD_CVER_WIDTH-1:0]						sent_data
);
	wire PamMap2AddHead_ready,PamMap2AddHead_valid;
	wire	[2*AD_CVER_WIDTH-1:0]	PamMap2AddHead_data;

pam_map#(
	.PAM_MAP_AXI_DATA_WIDTH(DATA_WIDTH),
	.PAM_ORDER(PAM_ORDER), 
	.PAM_MAP_MEM_ADDR_WIDTH(MEM_ADDR_WIDTH), 
 	.AD_CVER_WIDTH(AD_CVER_WIDTH)
) uut_pam_map(
/**********************  ctrl signal ******************************/
	.clk						(clk					)									,
	.arst_n						(arst_n					)									,
/**********************  interface with axi stream fifo ******************************/	
	.M_AXIS_tdata				(M_AXIS_tdata			)									,
	.M_AXIS_tlast				(M_AXIS_tlast			)									,
	.M_AXIS_tkeep				(M_AXIS_tkeep			)									,
	.M_AXIS_tvalid				(M_AXIS_tvalid			)									,
	.M_AXIS_tready				(M_AXIS_tready			)									,
/**********************  interface with add_frame_head ******************************/	
	.PamMap2AddHead_ready		(PamMap2AddHead_ready	)									,
	.PamMap2AddHead_valid		(PamMap2AddHead_valid   )									,
	.PamMap2AddHead_data		(PamMap2AddHead_data	)				
);


add_head_frame#(
	.AD_CVER_WIDTH(AD_CVER_WIDTH),  // ad/da width
	.ADD_HEAD_MEM_ADDR_WIDTH(ADDR_MEM_WIDTH),
	.PAM_ORDER(PAM_ORDER)
)uut_add_head_frame(
	/***************************** ctrl signal  ******************************************/
	.clk						(clk					)									,
	.rst_n						(arst_n					)									,
	/************************* interface with  pam_map  *********************************/
	.PamMap2AddHead_data		(PamMap2AddHead_data	)									,
	.PamMap2AddHead_valid		(PamMap2AddHead_valid	)									,
	.PamMap2AddHead_ready		(PamMap2AddHead_ready	)									,
	/************************* interface with ad/da     *********************************/
	.sent_data					(sent_data				)									
);


endmodule

`endif

