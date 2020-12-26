module demodulation#(
	parameter 		AD_CVER_WIDTH = 12,  // ad/da width, data width pre_stage
	parameter		LENGTH_DATA	=	1024,// num of data signal every frame
	parameter		LENGTH_PILOT = 4,
	parameter		PAM_ORDER = 4,
	parameter		WIDTH_AXI_DATA = 32, // axi stream data
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

	localparam	WIDTH_ADDR_REC_DATA = $clog2(LENGTH_DATA);
	localparam  LENGTH_THRESHOLD = (1 << PAM_ORDER) - 1;

	wire signed [AD_CVER_WIDTH-1:0] threshold_mem[0:LENGTH_THRESHOLD-1];
	reg [WIDTH_ADDR_REC_DATA-1:0] cnt_rec_data;
	
	assign	syn_demod_ready = 1'b1;
	
				//wait valid signal
	localparam	IDLE = 3'b000,
				//receive pilot and decide the threshold
				S0	 = 3'b001,
				//wait equalization
				S1   = 3'b010,
				//demodulation
				S2	 = 3'b100;
				
	reg	[2:0] cur_state, nxt_state;
	wire flag_IDLE_over, flag_S0_over, flag_S1_over, flag_S2_over;
	
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
						nxt_state = S2;
					else
						nxt_state = S1;
				end
				S2:begin
					if(flag_S2_over)
						nxt_state = IDLE;
					else
						nxt_state = S2;
				end
			endcase
		end
	end
	
//IDLE
	assign flag_IDLE_over = (1'b1 == syn_demod_valid) ? 1'b1 : 1'b0;
	
//S0	
	reg [AD_CVER_WIDTH-1:0] rec_data_r, rec_data_rr;
	reg [PAM_ORDER-1:0] cnt_pilot;
	wire [PAM_ORDER-1:0]	cnt_pilot_w;
	
	always@(posedge clk)
		{rec_data_rr,rec_data_r} <= {rec_data_r,syn_demod_data};

	
	reg syn_demod_valid_r;
	reg [AD_CVER_WIDTH+1:0] rec_value;
	

	always@(posedge clk)
		syn_demod_valid_r <= syn_demod_valid;
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			cnt_pilot <= 'b0;
			rec_value <= 'b0;
		end
		else begin
			if( (1'b1 == syn_demod_valid_r) && (S0 == cur_state) ) begin
				cnt_pilot <= cnt_pilot_w;
				rec_value <= rec_value + rec_data_r;
			end
			else begin
				cnt_pilot <= 'b0;
				rec_value <= 'b0;
			end
		end
	end
	
	reg en_div;
	wire [2*AD_CVER_WIDTH-1:0] dividend = 24'h1_00000;
	reg [AD_CVER_WIDTH-1:0]	h_est;
	wire rdy_o;
	wire [2*AD_CVER_WIDTH-1:0] result_o;
	reg rdy_r;
	reg [2*AD_CVER_WIDTH-1:0]	result_r;
	wire [AD_CVER_WIDTH-1:0] recip_h_est; 


	always@(posedge clk) begin
		result_r <= result_o;
		rdy_r	 <= rdy_o;
	end

	assign cnt_pilot_w = cnt_pilot + 1'b1;
	
	assign flag_S0_over = ( LENGTH_PILOT == cnt_pilot_w ) ? 1'b1 : 1'b0;	

	reg [LENGTH_DATA-1:0] cnt_data_r;
	wire [LENGTH_DATA-1:0] cnt_data;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			h_est <= 'b0;
			en_div <= 'b0;
		end
		else begin
			if(LENGTH_PILOT == cnt_pilot) begin
				h_est <= (rec_value) >> 4;
				en_div <= 1'b1;
			end
			else if(LENGTH_DATA == cnt_data_r) begin
				en_div <= 'b0;
				h_est <= 'b0;
			end
		end
	end

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_data_r <= 'b0;
		else begin
			if(LENGTH_PILOT == cnt_pilot && 0 == cnt_data_r)
				cnt_data_r <= 1'b1;
			else if(LENGTH_DATA == cnt_data_r)
				cnt_data_r <= 'b0;
			else if(0 != cnt_data_r)
				cnt_data_r <= cnt_data_r + 1'b1;

		end
	end
//S1
	assign flag_S1_over = (1'b1 == rdy_o) ? 1'b1 : 1'b0;
//S2
	reg [2*AD_CVER_WIDTH-1:0] sym_shift_reg;
	always@(posedge clk)
		sym_shift_reg <= {sym_shift_reg[2*AD_CVER_WIDTH-2:0],rec_data_rr[AD_CVER_WIDTH-1]};

	/***************************** cmp define  ****************************************/
	wire signed [AD_CVER_WIDTH-1:0] syn_demod_data_signed;

	assign syn_demod_data_signed = ( 1'b1 == sym_shift_reg[2*AD_CVER_WIDTH-1] ) ? com_opp_number(result_o[15:4]) : result_o[15:4];

	/****************************** con **************************************/
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

	reg [LENGTH_THRESHOLD:0] cmp_result_r;
	reg [PAM_ORDER-2:0] cnt_rec_pam_r;
	wire [PAM_ORDER-2:0] cnt_rec_pam;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_rec_pam_r <= 'b0;
		else begin
			if(S2 == cur_state)
				cnt_rec_pam_r <= cnt_rec_pam;
			else
				cnt_rec_pam_r <= 'b0;
		end
	end
	assign cnt_rec_pam = cnt_rec_pam_r + 1'b1;

	always@(posedge clk)
		cmp_result_r <= cmp_result;

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			{pam_data_0,pam_data_1,pam_data_2,pam_data_3,pam_data_4,pam_data_5,pam_data_6,pam_data_7} <= 'b0;
		else begin
			if(S2 == cur_state) begin
				case(cnt_rec_pam_r)
					3'd0:pam_data_0 <= pam_demodu(cmp_result_r);
					3'd1:pam_data_1 <= pam_demodu(cmp_result_r);
					3'd2:pam_data_2 <= pam_demodu(cmp_result_r);
					3'd3:pam_data_3 <= pam_demodu(cmp_result_r);
					3'd4:pam_data_4 <= pam_demodu(cmp_result_r);
					3'd5:pam_data_5 <= pam_demodu(cmp_result_r);
					3'd6:pam_data_6 <= pam_demodu(cmp_result_r);
					3'd7:pam_data_7 <= pam_demodu(cmp_result_r);
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
			if(7 == cnt_rec_pam_r)
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

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_rec_data <= 'b0;
		else begin
			if(S2 == cur_state)
				cnt_rec_data <= cnt_rec_data + 1'b1;
			else
				cnt_rec_data <= 'b0;
		end
	end
	
	assign flag_S2_over = ( (LENGTH_DATA-1)== cnt_rec_data) ? 1'b1 : 1'b0;

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
	.arst_n(rst_n),

	.en(en_div),
	.dividend( {abs(rec_data_rr),12'h000} ),
	.divisor(h_est),


	.rdy(rdy_o),
	.result(result_o)

);



endmodule
