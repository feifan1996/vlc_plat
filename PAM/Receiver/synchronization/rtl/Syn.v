module Syn#(
	parameter		AD_CVER_WIDTH = 12, // the width of received data
	parameter		PAM_ORDER = 4, // the order of PAM
	parameter		WIDTH_RESULT = 6,// the width of cov result
	parameter		LENGTH_DATA = 1024,//the lentgh of data
//	parameter		LENGTH_PILOT = 16,// the lentgh of pilot
	parameter		LENTGRH_M_SEQ = 15,// lentgh of m sequence
	parameter		THRESHOLD = 10,
	parameter		MEM_ADDR_WIDTH = 7, // width of addr of mem
	parameter 		AD_CVER_WIDTH = 12  // ad/da width
)
(
/**********************  ctrl signal ******************************/
	input																		clk,
	input																		arst_n,
/**********************  interface with AD ******************************/	
	input			[AD_CVER_WIDTH-1:0]											ad_rec_data
/**********************  interface with demodulation ******************************/	
	input																		syn_demodu_ready,
	output																		syn_demodu_valid,
	output			[AD_CVER_WIDTH-1:0]											syn_demodu_data
);

	
	localparam		LENGTH_SIGNAL = LENGTH_DATA + ( 1 << PAM_ORDER );
	localparam		LENGTH_CNT_SIGNAL = $clog2(LENGTH_DATA);
	
	wire [WIDTH_RESULT-1:0] result_cov;
	wire [LENTGRH_M_SEQ-1:0] m_seq_local = 12'b000_0101_0011_0111;//local seq for syn
	reg	 [LENGTH_CNT_SIGNAL:0]  cnt_signal;
	reg syn_demodu_valid_r;
 
	//one pat for ready signal
	localparam		IDLE = 2'b00,
	//syn based on m sequence 
					S0   = 2'b01,
	//send data signal to demodulation
					S1   = 2'b10;
	
 /**********************   two pat for ad_signal *****************************************/ 
	reg [AD_CVER_WIDTH-1,0] ad_rec_data_r,ad_rec_data_rr;
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) 
			{ad_rec_data_rr, ad_rec_data_r} <= 'b0;
		else
			{ad_rec_data_rr, ad_rec_data_r} <= {ad_rec_data_r, ad_rec_data};
	end

	assign syn_demodu_data = ad_rec_data_rr;
	assign syn_demodu_valid = syn_demodu_valid_r;
	
/***************************   synchronization   ****************************************/
	wire rec_flag_IDLE_over, rec_flag_S0_over, rec_flag_S1_over;
	reg  [1:0] rec_cur_state, rec_nxt_state;
	
// FSM
	always@(posedge clk or negedge arst_n) begin
		if(!arst_n)
			rec_cur_state <= IDLE;
		else
			rec_cur_state <= rec_nxt_state;
	end

	always@(*) begin
		if(!arst_n)
			rec_nxt_state = IDLE;
		else begin
			case(rec_cur_state)
				IDLE:begin
					if(1'b1 == rec_flag_IDLE_over)
						rec_nxt_state = S0;
					else
						rec_nxt_state = IDLE;
				end
				S0:begin
					if(1'b1 == rec_flag_S0_over)
						rec_nxt_state = S1;
					else
						rec_nxt_state = S0;
				end
				S1:begin
					if(1'b1 == rec_flag_S1_over)
						rec_nxt_state = IDLE;
					else
						rec_nxt_state = S1;//should not be nxt_state = nxt_state
				end
			endcase
		end
	end

//IDLE
	assign rec_flag_IDLE_over = 1'b1;
	
//S0
	reg [LENTGRH_M_SEQ-1:0] rec_seq;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) 
			rec_seq <= 'b0;
		else begin
			if(S0 == rec_cur_state)
				rec_seq <= {rec_seq[LENTGRH_M_SEQ-1:1],ad_rec_data_rr[AD_CVER_WIDTH-1]};	
		end
	end
	
	assign result_cov = cal_correlation(rec_seq, m_seq_local);// need optimiazaiotn
	/********************   synchronization in  next FSM  ******************************/
				//wait first cov result > 10
	localparam	COV_IDLE = 3'b000,
				//the second
				COV_S0	 = 3'b001,
				//the third
				COV_S1   = 3'b010,
				//the fourth
				COV_S2   = 3'b100;
	
	wire cov_flag_IDLE_over, cov_flag_S0_over, cov_flag_S1_over;
	reg [2:0] cov_cur_state, cov_nxt_state;
	reg [3:0] cnt_pat;
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cov_cur_state <= COV_IDLE;
		else begin
			if(S0 == rec_cur_state)
				cov_cur_state <= cov_nxt_state;
			else
				cov_cur_state <= COV_IDLE;
		end
	end
	
	always@(*) begin
		if(~rst_n)
			cov_nxt_state = COV_IDLE;
		else begin
			case(cov_cur_state)
				COV_IDLE:begin
					if(cov_flag_IDLE_over)
						cov_nxt_state = COV_S0;
					else
						cov_nxt_state = COV_IDLE;
				end
				COV_S0:begin
					if(cov_flag_S0_over)
						cov_nxt_state = COV_S1;
					else
						cov_nxt_state = COV_S0;
				end
				COV_S1:begin
					if(cov_flag_S1_over)
						cov_nxt_state = COV_S2;
					else
						cov_nxt_state = COV_S1;
				end
				COV_S2:begin
					if(cov_flag_S2_over)
						cov_nxt_state = COV_IDLE;
					else
						cov_nxt_state = COV_S2;
				end
			endcase
		end
	end
	
	//COV_IDLE
	assign cov_flag_IDLE_over = ( (1'b0 == result_cov[WIDTH_RESULT-1]) && (resiult_cov > THRESHOLD) ) ? 1'b1 : 1'b0;
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_pat <= 'b0;
		else begin
			if(  COV_IDLE != cov_cur_state)
				cnt_pat <= cnt_pat + 1'b1;
			else
				cnt_pat <= 'b0;
		end
	end
	
	//COV_S0
	assign cov_flag_S0_over = ( (15 == cnt_pat) && (1'b0 == result_cov[WIDTH_RESULT-1]) && (resiult_cov > THRESHOLD) ) ? 1'b1 : 1'b0; //receive the second m_seq
	//COV_S1
	assign cov_flag_S1_over = ( (15 == cnt_pat) && (1'b0 == result_cov[WIDTH_RESULT-1]) && (resiult_cov > THRESHOLD) ) ? 1'b1 : 1'b0;//receive the third m_seq
	//COV_S2
	assign cov_flag_S2_over = ( (15 == cnt_pat) && (1'b0 == result_cov[WIDTH_RESULT-1]) && (resiult_cov > THRESHOLD) ) ? 1'b1 : 1'b0;//receive the fourth m_seq
	
	assign rec_flag_S0_over = cov_flag_S2_over;
	
//S1
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			cnt_signal <= 'b0;
			syn_demodu_valid_r <= 1'b0;
		end
		else begin
			if( S1 == rec_cur_state) begin
				cnt_signal <= cnt_signal + 1'b1;
				syn_demodu_valid_r <= 1'b1;
			end
		end
	end
	
	assign rec_flag_S1_over = ( (LENGTH_SIGNAL - 1) == cnt_signal ) ? 1'b1 : 1'b0;

function [WIDTH_RESULT-1:0] cal_correlation;// need optimization
	input [LENTGRH_M_SEQ-1:0] m_seq;
	input [LENTGRH_M_SEQ-1:0] rec_syn;	
	integer i;
	begin
		cal_correlation = 'b0;
		for(i = 0; i < LENTGRH_M_SEQ-1;i=i+1)
			cal_correlation = cal_correlation + (m_seq[i] == rec_syn[i] ) ? 6'b00_0001:6'b11_1111;
	end
endfunction:cal_correlation





endmodule
