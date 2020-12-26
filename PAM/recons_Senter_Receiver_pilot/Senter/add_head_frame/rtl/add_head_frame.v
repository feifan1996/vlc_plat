module add_head_frame#(
	parameter 		AD_CVER_WIDTH = 12,  // ad/da width
	parameter		ADD_HEAD_MEM_ADDR_WIDTH	=	10,
	parameter		PAM_ORDER = 4
)(
	input												clk,
	input												rst_n,
	input		[2*AD_CVER_WIDTH-1:0]					PamMap2AddHead_data,
	input												PamMap2AddHead_valid,
	output												PamMap2AddHead_ready,
	output		[AD_CVER_WIDTH-1:0]						sent_data
);

	localparam	ADDR_MEM_WIDTH = ADD_HEAD_MEM_ADDR_WIDTH;
	localparam	MEM_DEPTH = 1 << ADDR_MEM_WIDTH;
	
	reg [AD_CVER_WIDTH-1:0] data_mem [0:MEM_DEPTH-1];
	
	reg PamMap2AddHead_ready_r;

	assign PamMap2AddHead_ready = PamMap2AddHead_ready_r;
	
	wire rec_valid = PamMap2AddHead_valid && PamMap2AddHead_ready;
	
	wire sent_valid;
	
	reg [ADDR_MEM_WIDTH-1:0] rec_addr, sent_addr_r;
	wire [ADDR_MEM_WIDTH-1:0] sent_addr;
	reg [ADDR_MEM_WIDTH:0] cnt_stored_data, cnt_stored_data_r;//count for stored data
	
	reg [AD_CVER_WIDTH-1:0]	 sent_data_r;
	assign sent_data = sent_data_r;
	
	//rec: one pat for ready signal
	localparam IDLE = 2'b00,
	//rec: receive signal from pam map
			   S0   = 2'b01,
	//rec: wait mem exist space		   
			   S1	= 2'b10;
	
/********************************  receive signal from pam map  ***************************************/	
	
	reg [1:0] rec_cur_state, rec_nxt_state;
	wire rec_flag_IDLE_over, rec_flag_S0_over, rec_flag_S1_over;
	
	
	
//FSM
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) 
			rec_cur_state <= IDLE;
		else	
			rec_cur_state <= rec_nxt_state;
	end

	always@(*) begin
		if(~rst_n)
			rec_nxt_state = IDLE;
		else begin
			case(rec_cur_state)
				IDLE:begin
					if(rec_flag_IDLE_over)
						rec_nxt_state = S0;
					else
						rec_nxt_state = IDLE;
				end
				S0:begin
					if(rec_flag_S0_over)
						rec_nxt_state = S1;
					else
						rec_nxt_state = S0;
				end
				S1:begin
					if(rec_flag_S1_over)
						rec_nxt_state = IDLE;
					else
						rec_nxt_state = S1;
				end
				default:rec_nxt_state = IDLE;
			endcase
		end
	end
	
	//IDLE
	assign rec_flag_IDLE_over = 1'b1;
	
	//S0
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			PamMap2AddHead_ready_r <= 1'b0;
		else begin
			if( (IDLE == rec_cur_state) && (S0 == rec_nxt_state) )
				PamMap2AddHead_ready_r <= 1'b1;
			else if( (S0 == rec_cur_state) && (S1 == rec_nxt_state) )
				PamMap2AddHead_ready_r <= 1'b0;
			else
				PamMap2AddHead_ready_r <= PamMap2AddHead_ready_r;
		end
	end

	integer i;
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			rec_addr <= 'b0;
			for(i=0;i<MEM_DEPTH;i=i+1)
				data_mem[i] <= 'b0;
		end
		else begin
			if(rec_valid) begin
				rec_addr <= rec_addr + 2;
				data_mem[rec_addr] <= PamMap2AddHead_data[2*AD_CVER_WIDTH-1:AD_CVER_WIDTH];
				data_mem[rec_addr+1] <= PamMap2AddHead_data[AD_CVER_WIDTH-1:0];
			end
			else
				rec_addr <= rec_addr;
		end
	end

	always@(*) begin
		case({rec_valid,sent_valid})
			2'b11:cnt_stored_data <= cnt_stored_data_r + 1;
			2'b10:cnt_stored_data <= cnt_stored_data_r + 2;
			2'b01:cnt_stored_data <= cnt_stored_data_r - 1;
			default:cnt_stored_data <= cnt_stored_data_r;
		endcase
	end
	
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			cnt_stored_data_r <= 'b0;
		else
			cnt_stored_data_r <= cnt_stored_data;			
	end

	assign rec_flag_S0_over = ( MEM_DEPTH == cnt_stored_data) ? 1'b1 : 1'b0;
	
	//S1
	assign rec_flag_S1_over = ( cnt_stored_data <= MEM_DEPTH-2  ) ? 1'b1 : 1'b0;
	
/********************************  sent signal to ad/da  ***************************************/
				//SENT: wait mem full
	localparam	SENT_IDLE = 3'b000,
				//SENT: send syncronization series
				SENT_S0   = 3'b001,
				//SENT: send pilot signal
				SENT_S1   = 3'b010,
				//SENT: send data 
				SENT_S2   = 3'b100;
	
	reg [2:0] sent_cur_state, sent_nxt_state;
	wire sent_flag_IDLE_over, sent_flag_S0_over, sent_flag_S1_over, sent_flag_S2_over;
	
	reg [9:0]  syn_signal_addr_r, ctrl_signal_addr_r;
	wire [9:0] syn_signal_addr, ctrl_signal_addr;
	reg [30:0] m_seq;

	

//FSM
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			sent_cur_state <= SENT_IDLE;
		else
			sent_cur_state <= sent_nxt_state;
	end
	
	always@(*) begin
		if(~rst_n)
			sent_nxt_state = IDLE;
		else begin
			case(sent_cur_state)
				SENT_IDLE:begin
					if(sent_flag_IDLE_over)
						sent_nxt_state = SENT_S0;
					else
						sent_nxt_state = SENT_IDLE;
				end
				SENT_S0:begin
					if(sent_flag_S0_over)
						sent_nxt_state = SENT_S1;
					else
						sent_nxt_state = SENT_S0;
				end
				SENT_S1:begin
					if(sent_flag_S1_over)
						sent_nxt_state = SENT_S2;
					else
						sent_nxt_state = SENT_S1;
				end
				SENT_S2:begin
					if(sent_flag_S2_over)
						sent_nxt_state = SENT_IDLE;
					else
						sent_nxt_state = SENT_S2;
				end
				default: sent_nxt_state = SENT_IDLE;
			endcase
		end
	end

	assign sent_flag_IDLE_over = ( MEM_DEPTH == cnt_stored_data) ? 1'b1 : 1'b0;

//S0
	//m_seq: 000_0101_0011_0111
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n) begin
			m_seq <= 31'b010_1000_1001_1100_0001_1001_0110_1111;
			syn_signal_addr_r <= 'b0;
		end
		else begin
			if( S0 == sent_cur_state ) begin
				syn_signal_addr_r <= syn_signal_addr;
				m_seq <= m_seq << 1;
			end
			else begin
				syn_signal_addr_r <= 'b0;
				m_seq <= 31'b010_1000_1001_1100_0001_1001_0110_1111;
			end
		end
	end

	assign syn_signal_addr = (S0 == sent_cur_state) ? syn_signal_addr_r + 1'b1 : syn_signal_addr_r;
	
	assign sent_flag_S0_over = (31 == syn_signal_addr) ? 1'b1 : 1'b0;
	
//S1
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			ctrl_signal_addr_r <= 'b0;
		else begin
			if( S1 == sent_cur_state )
				ctrl_signal_addr_r <= ctrl_signal_addr;
			else
				ctrl_signal_addr_r <= 'b0; 
		end
	end
	
	assign ctrl_signal_addr = (S1 == sent_cur_state) ? ctrl_signal_addr_r + 1'b1 : ctrl_signal_addr_r;

	assign sent_flag_S1_over = ( 3  == ctrl_signal_addr ) ? 1'b1 : 1'b0;
	
//S2
	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			sent_addr_r <= 'b0;
		else begin
			if(SENT_S2 == sent_cur_state)
				sent_addr_r <= sent_addr;
			else
				sent_addr_r <= 'b0;
		end
	end
	assign sent_addr = (SENT_S2 == sent_cur_state) ? sent_addr_r + 1'b1 : sent_addr_r;
	
	assign sent_flag_S2_over = ( (MEM_DEPTH-1) == sent_addr_r ) ? 1'b1 : 1'b0;

// send data

	always@(posedge clk or negedge rst_n) begin
		if(~rst_n)
			sent_data_r <= 'b0;
		else begin
			case(sent_cur_state)
				SENT_IDLE:	sent_data_r <= 12'b0000_1000_0000;
				SENT_S0:		sent_data_r <= Syn_prd(m_seq[30]);
				SENT_S1:     sent_data_r <= ctrl_signal_prd(ctrl_signal_addr_r);
				SENT_S2: 	sent_data_r <= data_mem[sent_addr_r];
				default: sent_data_r <= 12'b0000_1000_0000;
			endcase
		end
	end
	
	assign sent_valid = (SENT_S2 == sent_cur_state) ? 1'b1 : 1'b0;

	function [11:0] ctrl_signal_prd;
		input [ADDR_MEM_WIDTH-1:0] addr;
		begin
			case(addr)
				// pam pilot
				0:  ctrl_signal_prd =  12'b0010_0000_0000;
				1:  ctrl_signal_prd =  12'b0010_0000_0000;
				2:  ctrl_signal_prd =  12'b1010_0000_0000;
			endcase
		end
	endfunction
	
	
	
	function [11:0] Syn_prd;
		input m_seq_data;
		begin
			case(m_seq_data)
				1'b0:Syn_prd = 12'hFFF;
				1'b1:Syn_prd = 12'h7FF;
			endcase
		end
	endfunction
	
	
endmodule
