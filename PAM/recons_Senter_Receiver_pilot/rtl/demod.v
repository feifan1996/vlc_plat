// +FHDR------------------------------------------------------------
//                 Copyright (c) 2020 .
//                       ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Filename      : demod.v
// Author        : 
// Created On    : 2020-12-23 16:56
// Last Modified : 
// -----------------------------------------------------------------
// Description:
//
//
// -FHDR------------------------------------------------------------

`ifndef __DEMOD_V__
`define __DEMOD_V__

`timescale 1ns/1ps

module demod(
	parameter	AD_CVER_WIDTH	=	12,
				DATA_LEN		=	1024,
				AXI_DATA_WIDTH	=	32,
				PAM_ORDER		=	4
)(
/*******************************  ctrl signal   ******************************************/
	input												clk,
	input												arst_n,
/*******************************  interface with syn module   ******************************************/
	input												equa_valid,
	input		[AD_CVER_WIDTH-1:0]						equa_data,
/*******************************  interface with axi stream fifo   *************************************/
	input												m_axi_tready,
	output												m_axi_tvalid,
	output		[(AXI_DATA_WIDTH>>3)-1:0]				m_axi_tkeep,
	output		[AXI_DATA_WIDTH-1:0]					m_axi_tdata,
	output												m_axi_tlast
);

	localparam  LENGTH_THRESHOLD = (1 << PAM_ORDER) - 1;

	wire signed [AD_CVER_WIDTH-1:0] threshold_mem[0:LENGTH_THRESHOLD-1];
	
	assign m_axi_tkeep = {WIDTH_AXI_KEEP{1'b1}};
	reg [PAM_ORDER-1:0] pam_data_0, pam_data_1, pam_data_2, pam_data_3, pam_data_4, pam_data_5, pam_data_6, pam_data_7;
	
	assign m_axi_tdata = { pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7 };
	reg m_axi_tvalid_r;
	assign m_axi_tvalid = m_axi_tvalid_r;
	reg m_axi_tlast_r;
	assign m_axi_tlast = m_axi_tlast_r;
	
	//assign value to thred_ram
	assign threshold_mem[0] = (13'b1_1000_0000_0000+13'b1_1001_0001_0001) >> 1;
	assign threshold_mem[1] = (13'b1_1001_0001_0001+13'b1_1010_0010_0010) >> 1;
	assign threshold_mem[2] = (13'b1_1010_0010_0010+13'b1_1011_0011_0011) >> 1;
	assign threshold_mem[3] = (13'b1_1011_0011_0011+13'b1_1100_0100_0100) >> 1;
	assign threshold_mem[4] = (13'b1_1100_0100_0100+13'b1_1101_0101_0101) >> 1;
	assign threshold_mem[5] = (13'b1_1101_0101_0101+13'b1_1110_0110_0110) >> 1;
	assign threshold_mem[6] = (13'b1_1110_0110_0110+13'b1_1111_0111_0111) >> 1;
	assign threshold_mem[7] = (13'b1_1111_0111_0111+13'b0_0000_1000_1000) >> 1;
	assign threshold_mem[8] = (13'b0_0000_1000_1000+13'b0_0001_1001_1001) >> 1;
	assign threshold_mem[9] = (13'b0_0001_1001_1001+13'b0_0010_1010_1010) >> 1;
	assign threshold_mem[10] = (13'b0_0010_1010_1010+13'b0_0011_1011_1011) >> 1;
	assign threshold_mem[11] = (13'b0_0011_1011_1011+13'b0_0100_1100_1100) >> 1;
	assign threshold_mem[12] = (13'b0_0100_1100_1100+13'b0_0101_1101_1101) >> 1;
	assign threshold_mem[13] = (13'b0_0101_1101_1101+13'b0_0110_1110_1110) >> 1;
	assign threshold_mem[14] = (13'b0_0110_1110_1110+13'b0_0111_1111_1111) >> 1;



	wire signed [AD_CVER_WIDTH-1:0] syn_demod_data_signed;
	assign syn_demod_data_signed = equa_data;
	/****************************** con *****************************/
	assign cmp_result_0 = ( syn_demod_data_signed <=  threshold_mem[0] ) ? 1'b1 : 1'b0;
	assign cmp_result_1 = ( syn_demod_data_signed > threshold_mem[0] && syn_demod_data_signed <= threshold_mem[1] ) ? 1'b1 : 1'b0;
	assign cmp_result_2 = ( syn_demod_data_signed > threshold_mem[1] && syn_demod_data_signed <= threshold_mem[2] ) ? 1'b1 : 1'b0;
	assign cmp_result_3 = ( syn_demod_data_signed > threshold_mem[2] && syn_demod_data_signed <= threshold_mem[3] ) ? 1'b1 : 1'b0;
	assign cmp_result_4 = ( syn_demod_data_signed > threshold_mem[3] && syn_demod_data_signed <= threshold_mem[4] ) ? 1'b1 : 1'b0;
	assign cmp_result_5 = ( syn_demod_data_signed > threshold_mem[4] && syn_demod_data_signed <= threshold_mem[5] ) ? 1'b1 : 1'b0;
	assign cmp_result_6 = ( syn_demod_data_signed > threshold_mem[5] && syn_demod_data_signed <= threshold_mem[6] ) ? 1'b1 : 1'b0;
	assign cmp_result_7 = ( syn_demod_data_signed > threshold_mem[6] && syn_demod_data_signed <= threshold_mem[7] ) ? 1'b1 : 1'b0;
	assign cmp_result_8 = ( syn_demod_data_signed > threshold_mem[7] && syn_demod_data_signed <= threshold_mem[8] ) ? 1'b1 : 1'b0;
	assign cmp_result_9 = ( syn_demod_data_signed > threshold_mem[8] && syn_demod_data_signed <= threshold_mem[9] ) ? 1'b1 : 1'b0;
	assign cmp_result_10 = ( syn_demod_data_signed > threshold_mem[9] &&  syn_demod_data_signed <= threshold_mem[10] ) ? 1'b1 : 1'b0;
	assign cmp_result_11 = ( syn_demod_data_signed > threshold_mem[10] && syn_demod_data_signed <= threshold_mem[11] ) ? 1'b1 : 1'b0;
	assign cmp_result_12 = ( syn_demod_data_signed > threshold_mem[11] && syn_demod_data_signed <= threshold_mem[12] ) ? 1'b1 : 1'b0;
	assign cmp_result_13 = ( syn_demod_data_signed > threshold_mem[12] && syn_demod_data_signed <= threshold_mem[13] ) ? 1'b1 : 1'b0;
	assign cmp_result_14 = ( syn_demod_data_signed > threshold_mem[13] && syn_demod_data_signed <= threshold_mem[14] ) ? 1'b1 : 1'b0;
	assign cmp_result_15 = ( syn_demod_data_signed > threshold_mem[14] ) ? 1'b1 : 1'b0;

				
	wire [LENGTH_THRESHOLD:0] cmp_result = {cmp_result_15,cmp_result_14,cmp_result_13,cmp_result_12,cmp_result_11,cmp_result_10,cmp_result_9,cmp_result_8,cmp_result_7,cmp_result_6,cmp_result_5,cmp_result_4,cmp_result_3,cmp_result_2,cmp_result_1,cmp_result_0};



	reg [AD_CVER_WIDTH-1:0] cnt_rec_pam,cnt_rec_data;

	always@(posedge clk or negedge arst_n) begin
		if(~arst_n)
			cnt_rec_pam <= 'b0;
		else begin
			if(1'b1 == equa_valid) begin
				if(7 == cnt_rec_pam)
					cnt_rec_pam <= 'b0
				else
					cnt_rec_pam <= cnt_rec_pam + 1'b1;
			end
			else
				cnt_rec_pam <= 'b0;
		end
	end
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n)
			cnt_rec_data <= 'b0;
		else begin
			if(1'b1 == equa_valid)
				cnt_rec_data <= cnt_rec_data + 1'b1;
			else
				cnt_rec_data <= 'b0;
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			{pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7} <= 'b0;
		else begin
			if(1'b1 == equa_valid) begin
				case(cnt_rec_pam)
					3'd0:pam_data_0 <= pam_demodu(cmp_result);
					3'd1:pam_data_1 <= pam_demodu(cmp_result);
					3'd2:pam_data_2 <= pam_demodu(cmp_result);
					3'd3:pam_data_3 <= pam_demodu(cmp_result);
					3'd4:pam_data_4 <= pam_demodu(cmp_result);
					3'd5:pam_data_5 <= pam_demodu(cmp_result);
					3'd6:pam_data_6 <= pam_demodu(cmp_result);
					3'd7:pam_data_7 <= pam_demodu(cmp_result);
				endcase
			end
			else
				{pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7} <= 'b0;
		end
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			m_axi_tvalid_r <= 'b0;
		else begin
			if(7 == cnt_rec_pam)
				m_axi_tvalid_r <= 1'b1;
			else
				m_axi_tvalid_r <= 1'b0;
		end
	end



	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			m_axi_tlast_r <= 'b0;
		else begin
			if( (LENGTH_DATA - 1) == cnt_rec_data)
				m_axi_tlast_r <= 1'b1;
			else
				m_axi_tlast_r <= 1'b0;
		end
	end



	function [PAM_ORDER-1:0] pam_demodu; // need optimization
		input [LENGTH_THRESHOLD:0] cmp_r;
		begin
			case(1)				
				cmp_r[0]:pam_demodu = 4'd0;
				cmp_r[1]:pam_demodu = 4'd1;
				cmp_r[2]:pam_demodu = 4'd2;
				cmp_r[3]:pam_demodu = 4'd3;
				cmp_r[4]:pam_demodu = 4'd4;
				cmp_r[5]:pam_demodu = 4'd5;
				cmp_r[6]:pam_demodu = 4'd6;
				cmp_r[7]:pam_demodu = 4'd7;
				cmp_r[8]:pam_demodu = 4'd8;
				cmp_r[9]:pam_demodu = 4'd9;
				cmp_r[10]:pam_demodu = 4'd10;
				cmp_r[11]:pam_demodu = 4'd11;
				cmp_r[12]:pam_demodu = 4'd12;
				cmp_r[13]:pam_demodu = 4'd13;
				cmp_r[14]:pam_demodu = 4'd14;
				cmp_r[15]:pam_demodu = 4'd15;
			endcase
		end
	endfunction


endmodule

`endif

