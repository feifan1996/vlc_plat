module syn#(
	parameter		AD_CVER_WIDTH = 12, // the width of received data
	parameter		PAM_ORDER = 4, // the order of PAM
	parameter		WIDTH_RESULT = 6,// the width of cov result
	parameter		LENGTH_DATA = 1024,//the lentgh of data
	parameter		LENGTH_M_SEQ = 31,// lentgh of m sequence
	parameter		THRESHOLD = 25,
	parameter		SYN_MEM_ADDR_WIDTH = 7 // width of addr of mem
)
(
/**********************  ctrl signal ******************************/
	input																clk,
	input																arst_n,
/**********************  interface with AD ******************************/	
	input			[AD_CVER_WIDTH-1:0]									ad_rec_data,
/**********************  interface with demodulation ******************************/	
	input																syn_demodu_ready,
	output																syn_demodu_valid,
	output			[AD_CVER_WIDTH-1:0]									syn_demodu_data
);

	
	localparam		LENGTH_SIGNAL = LENGTH_DATA + ( 1 << PAM_ORDER );
	localparam		LENGTH_CNT_SIGNAL = $clog2(LENGTH_DATA);
	
	wire [WIDTH_RESULT-1:0] result_cov;
	reg [WIDTH_RESULT-1:0] num_xor_rec_loc;
	wire [LENGTH_M_SEQ-1:0] m_seq_local = 31'b010_1000_1001_1100_0001_1001_0110_1111;//local seq for syn
	reg	 [LENGTH_CNT_SIGNAL:0]  cnt_signal;
	reg syn_demodu_valid_r;
 
	//one pat for ready signal
	localparam		IDLE = 2'b00,
	//syn based on m sequence 
					S0   = 2'b01,
	//send data signal to demodulation
					S1   = 2'b10;
	
 /**********************   two pat for ad_signal *****************************************/ 
	reg [AD_CVER_WIDTH-1:0] ad_rec_data_r,ad_rec_data_rr;
	
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) 
			{ad_rec_data_rr, ad_rec_data_r} <= 'b0;
		else
			{ad_rec_data_rr, ad_rec_data_r} <= {ad_rec_data_r, ad_rec_data};
	end

	reg [AD_CVER_WIDTH-1:0] mem_rec_data_r,mem_rec_data_rr;
	always@(posedge clk)
		{mem_rec_data_rr,mem_rec_data_r} <= {mem_rec_data_r,ad_rec_data_rr};

	assign syn_demodu_data = mem_rec_data_rr;
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
	reg [LENGTH_M_SEQ-1:0] rec_seq;
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) 
			rec_seq <= 'b0;
		else begin
			if(S0 == rec_cur_state)
				rec_seq <= {rec_seq[LENGTH_M_SEQ-2:0],~ad_rec_data_rr[AD_CVER_WIDTH-1]};	
		end
	end


	wire [LENGTH_M_SEQ-1:0] xor_local_rec = rec_seq ^~ m_seq_local;

	always@(*) begin //need optimization
		num_xor_rec_loc = { {WIDTH_RESULT{1'b0}} + xor_local_rec[0] + xor_local_rec[1]+ xor_local_rec[2]+ xor_local_rec[3]+ xor_local_rec[4]+ xor_local_rec[5]+ xor_local_rec[6]+ xor_local_rec[7]+ xor_local_rec[8]+ xor_local_rec[9]+ xor_local_rec[10]+ xor_local_rec[11]+ xor_local_rec[12]+ xor_local_rec[13]+ xor_local_rec[14]+ xor_local_rec[15] + xor_local_rec[16]+ xor_local_rec[17]+ xor_local_rec[18]+ xor_local_rec[19]+ xor_local_rec[20]+ xor_local_rec[21]+ xor_local_rec[22]+ xor_local_rec[23]+ xor_local_rec[24]+ xor_local_rec[25]+ xor_local_rec[26]+ xor_local_rec[27]+ xor_local_rec[28]+ xor_local_rec[29]+ xor_local_rec[30]};
	end
	assign result_cov = (num_xor_rec_loc > (LENGTH_M_SEQ >> 1)) ? num_xor_rec_loc : {WIDTH_RESULT{1'b1}};//need optimization
	
	
	/********************   synchronization in  next FSM  ******************************/
	//COV_IDLE
	assign rec_flag_S0_over = ( (1'b0 == result_cov[WIDTH_RESULT-1]) && (result_cov > THRESHOLD) ) ? 1'b1 : 1'b0;

	
//S1
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) begin
			cnt_signal <= 'b0;
			syn_demodu_valid_r <= 1'b0;
		end
		else begin
			if( S1 == rec_cur_state) begin
				cnt_signal <= cnt_signal + 1'b1;
				syn_demodu_valid_r <= 1'b1;
			end
			else begin
				cnt_signal <= 'b0;
				syn_demodu_valid_r <= 1'b0;
			end
		end
	end
	
	assign rec_flag_S1_over = ( (LENGTH_SIGNAL - 1) == cnt_signal ) ? 1'b1 : 1'b0;





endmodule
