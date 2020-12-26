// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : divider_cell.v
// Author        : 
// Created On    : 2020-12-21 20:36
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __DIVIDER_CELL_V__
`define __DIVIDER_CELL_V__

`timescale 1ns/1ps

module divider_cell#(
		parameter		WIDTH_DIVIDEND = 5,
						WIDTH_DIVISOR  = 3
)(
	input														clk,
	input														arst_n,

	input														en,
	input			[WIDTH_DIVISOR:0]							dividend,//current dividend
	input			[WIDTH_DIVISOR-1:0]							divisor,//divisor constant
	input			[WIDTH_DIVIDEND-1:0]						result,// pre result
	input			[WIDTH_DIVIDEND-2:0]						dividend_ci,// remain dividend

	output reg		[WIDTH_DIVIDEND-2:0]						dividend_kp,// keep dividend
	output reg      [WIDTH_DIVISOR-1:0]							divisor_kp,// keep divisor
	output reg		[WIDTH_DIVIDEND-1:0]						result_o,// output result
	output reg      [WIDTH_DIVISOR-1:0]							remainder,// output remainder
	output reg													rdy// output rdy

);

	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) begin
			rdy <= 'b0;
			dividend_kp <= 'b0;
			divisor_kp  <= 'b0;
			result_o	<= 'b0;
			remainder	<= 'b0;
		end
		else begin
			if(1'b1 == en) begin
				rdy <= 1'b1;
				dividend_kp <= dividend_ci;
				divisor_kp	<= divisor;
				if( dividend >= {1'b0,divisor} ) begin
					result_o  <= (result << 1) + 1'b1;
					remainder <= dividend - {1'b0,divisor}; 
				end
				else begin
					result_o  <= (result << 1);
					remainder <= dividend;
				end
			end
			else begin
				rdy <= 'b0;
				dividend_kp <= 'b0;
				divisor_kp  <= 'b0;
				result_o	<= 'b0;
				remainder	<= 'b0;
			end
		end
	end


endmodule

`endif

