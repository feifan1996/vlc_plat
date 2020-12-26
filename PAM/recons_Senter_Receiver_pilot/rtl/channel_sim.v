// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : channel_sim.v
// Author        : 
// Created On    : 2020-12-23 08:31
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __CHANNEL_SIM_V__
`define __CHANNEL_SIM_V__

`timescale 1ns/1ps

module channel_sim#(
	parameter	AD_CVER_WIDTH = 12
)(
	input [AD_CVER_WIDTH-1:0]	data_in,
	output	[AD_CVER_WIDTH-1:0]	data_out
);

	assign data_out = {data_in[AD_CVER_WIDTH-1],data_in[AD_CVER_WIDTH-1:1]};

endmodule

`endif

