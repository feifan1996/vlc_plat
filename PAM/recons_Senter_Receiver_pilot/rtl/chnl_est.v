// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : chnl_est.v
// Author        : 
// Created On    : 2020-12-23 15:00
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __CHNL_EST_V__
`define __CHNL_EST_V__

`timescale 1ns/1ps

module chnl_est_equa#(
	parameter	AD_CVER_WIDTH = 12,
				LEN_PILOT	  = 4,
				LEN_DATA	  = 1024
)(
	input								clk,
	input								arst_n,
	/******************** interface with syn  **********************/
	input								syn_valid,
	input	[AD_CVER_WIDTH-1:0]			syn_data_in,
	/***************** interface with equalization  ****************/
	output								demod_en,
	output	[AD_CVER_WIDTH-1:0]			equa_data
);
	
	localparam	LEN_SHIFT = 2 + $clog2(LEN_PILOT);

	/******************* output reg define ************************/
	reg [AD_CVER_WIDTH-1:0] equa_data_r;
	reg demod_en_r;
	assign demod_en = demod_en_r;
	assign equa_data = equa_data_r;

	/******************* pos valid detect *********************/
	reg syn_valid_r;
	always@(posedge clk)
		syn_valid_r <= syn_valid;
	
	wire flag_pos_valid;
	assign flag_pos_valid = ({syn_valid,syn_valid_r} == 2'b10) ? 1'b1:1'b0;

	/******************* acc the pilot signal  **************************/
	reg [AD_CVER_WIDTH+1:0] acc_value_r;
	reg [AD_CVER_WIDTH-1:0] cnt_pilot_r;
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) begin
			acc_value_r <= 'b0;
			cnt_pilot_r <= 'b0;			
		end
		else begin
			if(1'b1 == flag_pos_valid) begin
				//initial value when pos edge
				acc_value_r <= syn_data_in;
				cnt_pilot_r <=  cnt_pilot_r + 1'b1;
			end
			else if(LEN_PILOT == cnt_pilot_r) begin
				//stop acc when add all pilot
				acc_value_r <= acc_value_r;
				cnt_pilot_r  <= 'b0;
			end
			else begin
				//acc receive pilot
				acc_value_r <=	acc_value_r + syn_data_in;
				cnt_pilot_r	<=	cnt_pilot_r + 1'b1;
			end
		end
	end
	
	/***************** channel estimation  **************************/
	reg [AD_CVER_WIDTH-1:0]	h_est;
	always@(posedge clk) begin
		if(LEN_PILOT == cnt_pilot_r)//channel estimation when acc all pilot
			h_est <= (acc_value_r >> LEN_SHIFT);
	end

	/********************* driver en *******************************/
	reg div_en;
	reg [AD_CVER_WIDTH-1:0] cnt_data_r;
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) begin
			div_en <= 'b0;
			cnt_data_r <= 'b0;
		end 
		else begin
			if(LEN_PILOT == cnt_pilot_r && 0 == cnt_data_r) begin
				//drive div_en when acc all pilot and cnt_data_r not zero
				div_en <= 1'b1;
				cnt_data_r <= cnt_data_r + 1'b1;
			end
			else if(LEN_DATA == cnt_data_r) begin
				//set zero to div_en and cnt_data_r, wait nxt frame
				div_en <= 1'b0;
				cnt_data_r <= 'b0;
			end
			else if(0 != cnt_data_r) begin
				//always drive div_en
				div_en <=1'b1;
				cnt_data_r <= cnt_data_r + 1'b1;
			end
		end
	end

	/********************* two pat for data ****************************/
	reg [AD_CVER_WIDTH-1:0] rec_data_r, rec_data_rr;
	always@(posedge clk)
		{rec_data_rr, rec_data_r} <= {rec_data_r, syn_data_in};

	/******************** reserve sign symbol ********************/
	reg [2*AD_CVER_WIDTH-1:0] sign_r;
	always@(posedge clk)
		sign_r <= {sign_r[2*AD_CVER_WIDTH-2:0], rec_data_rr[AD_CVER_WIDTH-1]};

	/******************** proc output result *********************/
	wire [AD_CVER_WIDTH-1:0] data_equ;
	wire rdy_o;

	assign data_equ = (1'b1 == sign_r[2*AD_CVER_WIDTH-1]) ? com_opp_number(result_o[15:4]) : result_o[15:4];

	always@(posedge clk)
		equa_data_r <= data_equ;

	always@(posedge clk)
		demod_en_r <= rdy_o;

	function [AD_CVER_WIDTH-1:0] abs;
		input [AD_CVER_WIDTH-1:0] data;
		assign abs = (1'b1 == data[AD_CVER_WIDTH-1]) ? (~data+1'b1) : data;
	endfunction

	function [AD_CVER_WIDTH-1:0] com_opp_number;
		input [AD_CVER_WIDTH-1:0] data;
		assign com_opp_number = ~data + 1'b1;
	endfunction


	divider#(
			.WIDTH_DIVIDEND((AD_CVER_WIDTH<<1)),
			.WIDTH_DIVISOR (AD_CVER_WIDTH)
	)uut_div(
		.clk(clk),
		.arst_n(arst_n),
	
		.en(div_en),
		.dividend( {abs(rec_data_rr),12'h000} ),
		.divisor(h_est),
	
	
		.rdy(rdy_o),
		.result(result_o)
	);



endmodule

`endif

