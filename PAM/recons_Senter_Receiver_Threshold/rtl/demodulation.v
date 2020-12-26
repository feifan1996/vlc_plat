module demodulation#(
	parameter 		AD_CVER_WIDTH = 12,  // ad/da width, data width pre_stage
	parameter		LENGTH_DATA	=	1024,// num of data signal every frame
	parameter		PAM_ORDER = 4,
	parameter		WIDTH_AXI_DATA = 32, // axi stream data 数据宽度
	localparam		WIDTH_AXI_KEEP = WIDTH_AXI_DATA >> 3
)(
/*******************************  ctrl signal   ******************************************/
	input												clk,
	input												rst_n,
/*******************************  interface with syn module   ******************************************/
	input												syn_demod_valid,
	input		[AD_CVER_WIDTH-1:0]						syn_demod_data,
	output												syn_demod_ready,
/*******************************  interface with axi stream fifo   *************************************/
	input												m_axi_tready,
	output												m_axi_tvalid,
	output		[WIDTH_AXI_KEEP-1:0]					m_axi_tkeep,
	output		[WIDTH_AXI_DATA-1:0]					m_axi_tdata,
	output												m_axi_tlast
);

	localparam	LEGTHN_PILOT = 1 << PAM_ORDER;
	localparam	WIDTH_ADDR_REC_DATA = $clog2(LENGTH_DATA);
	
	reg signed [AD_CVER_WIDTH-1:0] pilot_mem[0:LEGTHN_PILOT-2];
	reg [WIDTH_ADDR_REC_DATA-1:0] cnt_rec_data;
	
	assign	syn_demod_ready = 1'b1;
	
				//wait valid signal
	localparam	IDLE = 2'b00,
				//receive pilot and decide the threshold
				S0	 = 2'b01,
				//demodulation
				S1   = 2'b10;
				
	reg	[1:0] cur_state, nxt_state;
	wire flag_IDLE_over, flag_S0_over, flag_S1_over;
	
	assign m_axi_tkeep = {WIDTH_AXI_KEEP{1'b1}};
	reg [PAM_ORDER-1:0] pam_data_0, pam_data_1, pam_data_2, pam_data_3, pam_data_4, pam_data_5, pam_data_6, pam_data_7;
	
	assign m_axi_tdata = { pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7 };
	reg m_axi_tvalid_r;
	assign m_axi_tvalid = m_axi_tvalid_r;
	reg m_axi_tlast_r;
	assign m_axi_tlast = m_axi_tlast_r;
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cur_state <= IDLE;
		else
			cur_state <= nxt_state;
	end
	
	always@(*) begin
		if(~rst_n)
			nxt_state = IDLE;
		else begin
			case(cur_state)
				IDLE:begin
					if(flag_IDLE_over)
						nxt_state = S0;
					else
						nxt_state = IDLE;
				end
				S0:begin
					if(flag_S0_over)
						nxt_state = S1;
					else
						nxt_state = S0;
				end
				S1:begin
					if(flag_S1_over)
						nxt_state = IDLE;
					else
						nxt_state = S1;
				end
			endcase
		end
	end
	
//IDLE
	assign flag_IDLE_over = (1'b1 == syn_demod_valid) ? 1'b1 : 1'b0;
	
//S0	
	reg [AD_CVER_WIDTH-1:0] rec_pilot_r, rec_pilot_rr;
	wire [AD_CVER_WIDTH-1:0] div_pilot;
	reg div_enable;
	reg [PAM_ORDER-1:0] addr_pilot;
	wire [PAM_ORDER-1:0]	addr_pilot_w;
	
	always@(posedge clk)
		rec_pilot_r <= syn_demod_data;

	assign div_pilot = { {rec_pilot_r[AD_CVER_WIDTH-1],rec_pilot_r} + {syn_demod_data[AD_CVER_WIDTH-1],syn_demod_data} } >> 1;
	
	reg syn_demod_valid_r;
	always@(posedge clk)
		syn_demod_valid_r <= syn_demod_valid;
	integer i;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			addr_pilot <= 'b0;
			for(i=0;i<LEGTHN_PILOT;i=i+1)
				pilot_mem[i] <= 'b0;
		end
		else begin
			if( (1'b1 == syn_demod_valid_r) && (S0 == cur_state) ) begin
				addr_pilot <= addr_pilot_w;
				pilot_mem[addr_pilot] <= div_pilot;
			end
			else
				addr_pilot <= 'b0;
		end
	end
	
	assign addr_pilot_w = addr_pilot + 1'b1;
	
	assign flag_S0_over = ( (LEGTHN_PILOT-1) == addr_pilot ) ? 1'b1 : 1'b0;
	
//S1
	reg [2:0] cnt_rec_pam, cnt_rec_pam_r;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_rec_pam <= 'b0;
 		else begin
			if(S1 == nxt_state)
				cnt_rec_pam <= cnt_rec_pam + 1'b1;
			else
				cnt_rec_pam <= 'b0;
		end
	end
	/***************************** cmp define  ****************************************/
	wire signed [AD_CVER_WIDTH-1:0] syn_demod_data_signed;

	assign syn_demod_data_signed = syn_demod_data;

	assign cmp_result_0 = ( syn_demod_data_signed <=  pilot_mem[0] ) ? 1'b1 : 1'b0;
	assign cmp_result_1 = ( syn_demod_data_signed > pilot_mem[0] && syn_demod_data_signed <= pilot_mem[1] ) ? 1'b1 : 1'b0;
	assign cmp_result_2 = ( syn_demod_data_signed > pilot_mem[1] && syn_demod_data_signed <= pilot_mem[2] ) ? 1'b1 : 1'b0;
	assign cmp_result_3 = ( syn_demod_data_signed > pilot_mem[2] && syn_demod_data_signed <= pilot_mem[3] ) ? 1'b1 : 1'b0;
	assign cmp_result_4 = ( syn_demod_data_signed > pilot_mem[3] && syn_demod_data_signed <= pilot_mem[4] ) ? 1'b1 : 1'b0;
	assign cmp_result_5 = ( syn_demod_data_signed > pilot_mem[4] && syn_demod_data_signed <= pilot_mem[5] ) ? 1'b1 : 1'b0;
	assign cmp_result_6 = ( syn_demod_data_signed > pilot_mem[5] && syn_demod_data_signed <= pilot_mem[6] ) ? 1'b1 : 1'b0;
	assign cmp_result_7 = ( syn_demod_data_signed > pilot_mem[6] && syn_demod_data_signed <= pilot_mem[7] ) ? 1'b1 : 1'b0;
	assign cmp_result_8 = ( syn_demod_data_signed > pilot_mem[7] && syn_demod_data_signed <= pilot_mem[8] ) ? 1'b1 : 1'b0;
	assign cmp_result_9 = ( syn_demod_data_signed > pilot_mem[8] && syn_demod_data_signed <= pilot_mem[9] ) ? 1'b1 : 1'b0;
	assign cmp_result_10 = ( syn_demod_data_signed > pilot_mem[9] &&  syn_demod_data_signed <= pilot_mem[10] ) ? 1'b1 : 1'b0;
	assign cmp_result_11 = ( syn_demod_data_signed > pilot_mem[10] && syn_demod_data_signed <= pilot_mem[11] ) ? 1'b1 : 1'b0;
	assign cmp_result_12 = ( syn_demod_data_signed > pilot_mem[11] && syn_demod_data_signed <= pilot_mem[12] ) ? 1'b1 : 1'b0;
	assign cmp_result_13 = ( syn_demod_data_signed > pilot_mem[12] && syn_demod_data_signed <= pilot_mem[13] ) ? 1'b1 : 1'b0;
	assign cmp_result_14 = ( syn_demod_data_signed > pilot_mem[13] && syn_demod_data_signed <= pilot_mem[14] ) ? 1'b1 : 1'b0;
	assign cmp_result_15 = ( syn_demod_data_signed > pilot_mem[14] ) ? 1'b1 : 1'b0;

				
	wire [LEGTHN_PILOT-1:0] cmp_result = {cmp_result_15,cmp_result_14,cmp_result_13,cmp_result_12,cmp_result_11,cmp_result_10,cmp_result_9,cmp_result_8,cmp_result_7,cmp_result_6,cmp_result_5,cmp_result_4,cmp_result_3,cmp_result_2,cmp_result_1,cmp_result_0};

	reg [LEGTHN_PILOT-1:0] cmp_result_r;
	always@(posedge clk)
		cmp_result_r <= cmp_result;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			{pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7} <= 'b0;
		else begin
			if(S1 == nxt_state) begin
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
			if( (WIDTH_AXI_DATA - 2) == cnt_rec_data)
				m_axi_tlast_r <= 1'b1;
			else
				m_axi_tlast_r <= 1'b0;
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_rec_data <= 'b0;
		else begin
			if(S1 == cur_state)
				cnt_rec_data <= cnt_rec_data + 1'b1;
			else
				cnt_rec_data <= 'b0;
		end
	end
	
	assign flag_S1_over = ( (LENGTH_DATA-1) == cnt_rec_data ) ? 1'b1 : 1'b0;
	
	reg [PAM_ORDER-1:0] test_data;

	function [PAM_ORDER-1:0] pam_demodu; // need optimization
		input [LEGTHN_PILOT-1:0] cmp_r;
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
