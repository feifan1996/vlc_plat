// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : divider.v
// Author        : 
// Created On    : 2020-12-21 20:55
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __DIVIDER_V__
`define __DIVIDER_V__

`timescale 1ns/1ps

module divider#(
		parameter		WIDTH_DIVIDEND = 5,
						WIDTH_DIVISOR  = 3
)(
	input														clk,
	input														arst_n,

	input														en,
	input	[WIDTH_DIVIDEND-1:0]								dividend,
	input	[WIDTH_DIVISOR-1:0]									divisor,


	output														rdy,
	output		[WIDTH_DIVIDEND-1:0]							result,
	output	    [WIDTH_DIVISOR-1:0]								remainder
);

	localparam	N = WIDTH_DIVIDEND;
	localparam	M = WIDTH_DIVISOR;

	reg [N-2:0]	dividend_t [N-1:0];
	reg [M-1:0] divisor_t [N-1:0];
	reg [N-1:0] result_t [N-1:0];
	reg [M-1:0] remainder_t [N-1:0];
	reg [N-1:0] rdy_t;

	divider_cell#(
		.WIDTH_DIVIDEND(WIDTH_DIVIDEND),
		.WIDTH_DIVISOR(WIDTH_DIVISOR)
	)uut_initial(
		.clk			(clk								)					,
		.arst_n			(arst_n								)					,
	
		.en				(en									)					,
		.dividend		({ {M{1'b0}},dividend[N-1] }		)					,
		.divisor		(divisor							)					,
		.result			({N{1'b0}}							)					,
		.dividend_ci	(dividend[N-2:0]					)					,
	
		.dividend_kp	(dividend_t[N-1]					)					,
		.divisor_kp		(divisor_t[N-1]						)					,
		.result_o		(result_t[N-1]						)					,
		.remainder		(remainder_t[N-1]					)					,
		.rdy			(rdy_t[N-1]							)
	);

	genvar i;
	generate 
		for(i=1; i <= N-1; i=i+1) begin:div_stepx
			divider_cell#(
			.WIDTH_DIVIDEND(N),
			.WIDTH_DIVISOR(M)
			)uut_step(
				.clk			(clk							)					,
				.arst_n			(arst_n							)					,
			
				.en				(rdy_t[N-i]						)					,
				.dividend		({remainder_t[N-i],dividend_t[N-i][N-i-1]})			,
				.divisor		(divisor_t[N-i]						)					,
				.result			(result_t[N-i]					)					,
				.dividend_ci	(dividend_t[N-i]				)					,
			
				.dividend_kp	(dividend_t[N-i-1]				)					,
				.divisor_kp		(divisor_t[N-i-1]				)					,
				.result_o		(result_t[N-i-1]				)					,
				.remainder		(remainder_t[N-i-1]				)					,
				.rdy			(rdy_t[N-i-1]					)
			);
		end
	endgenerate

	assign rdy = rdy_t[0];
	assign result =result_t [0];
	assign remainder = remainder_t[0];

endmodule

`endif

