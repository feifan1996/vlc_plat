// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : receiver.v
// Author        : 
// Created On    : 2020-12-19 08:55
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __RECEIVER_V__
`define __RECEIVER_V__

`timescale 1ns/1ps

module receiver#(
	parameter		AD_CVER_WIDTH = 12, // the width of receiv
					PAM_ORDER = 4, // the order of PAM       
					WIDTH_RESULT = 6,// the width of cov resul
					LENGTH_DATA = 1024,//the lentgh of data
					LENTGRH_M_SEQ = 31,// lentgh of m sequence
					THRESHOLD = 25,
					MEM_ADDR_WIDTH = 7, // width of addr of mem
					WIDTH_AXI_DATA = 32 // axi stream data
)(
	/**********************  ctrl signal ******************************/
	input													clk,
	input													arst_n,
	/******************** interface with ad **************************/
	input			[AD_CVER_WIDTH-1:0]						ad_rec_data,
	/*****************  interface with axi_fifo  *******************/
	input												m_axi_tready,
	output												m_axi_tvalid,
	output		[(WIDTH_AXI_DATA >> 3)-1:0]				m_axi_tkeep,
	output		[WIDTH_AXI_DATA-1:0]					m_axi_tdata,
	output												m_axi_tlast
);

	wire [AD_CVER_WIDTH-1:0] syn_demod_data;
	wire syn_demod_valid, syn_demod_ready;


syn#(
	.AD_CVER_WIDTH(AD_CVER_WIDTH), // the width of received data
	.PAM_ORDER(PAM_ORDER), // the order of PAM
	.WIDTH_RESULT(WIDTH_RESULT),// the width of cov result
	.LENGTH_DATA(LENGTH_DATA),//the lentgh of data
	.LENTGRH_M_SEQ(LENTGRH_M_SEQ),// lentgh of m sequence
	.THRESHOLD(THRESHOLD),
	.MEM_ADDR_WIDTH(MEM_ADDR_WIDTH) // width of addr of mem
)uut_syn(
/**********************  ctrl signal ******************************/
	.clk				(clk				)					,
	.arst_n				(arst_n				)					,
/**********************  interface with AD ******************************/	
	.ad_rec_data		(ad_rec_data		)					,
/**********************  interface with demodulation ******************************/	
	.syn_demodu_ready	(syn_demod_ready	)					,
	.syn_demodu_valid	(syn_demod_valid	)					,
	.syn_demodu_data	(syn_demod_data	)
);



demodulation#(
	.AD_CVER_WIDTH(AD_CVER_WIDTH),  // ad/da width, data width pre_stage
	.LENGTH_DATA(LENGTH_DATA),// num of data signal every frame
	.PAM_ORDER(PAM_ORDER),
	.WIDTH_AXI_DATA(WIDTH_AXI_DATA) // axi stream data
)uut_demodulation(
/*******************************  ctrl signal   ******************************************/
	.clk				(clk					)			,
	.rst_n				(arst_n					)			,
/*******************************  interface with syn module   ******************************************/
	.syn_demod_valid	(syn_demod_valid		)			,
	.syn_demod_data		(syn_demod_data			)			,
	.syn_demod_ready	(syn_demod_ready		)			,
/*******************************  interface with axi stream fifo   *************************************/
	.m_axi_tready		(m_axi_tready			)			,
	.m_axi_tvalid		(m_axi_tvalid			)			,
	.m_axi_tkeep		(m_axi_tkeep			)			,
	.m_axi_tdata		(m_axi_tdata			)			,
	.m_axi_tlast		(m_axi_tlast			)
);




endmodule

`endif

