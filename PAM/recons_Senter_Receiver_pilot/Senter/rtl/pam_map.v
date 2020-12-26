module pam_map#(
	parameter		PAM_MAP_AXI_DATA_WIDTH = 32, // the width of received data
	parameter		PAM_ORDER = 4, // the order of PAM
	parameter		PAM_MAP_MEM_ADDR_WIDTH = 7, // width of addr of mem
	parameter 		AD_CVER_WIDTH = 12  // ad/da width
)
(
/**********************  ctrl signal ******************************/
	input																clk,
	input																arst_n,
/**********************  interface with axi stream fifo ******************************/	
	input			[PAM_MAP_AXI_DATA_WIDTH-1:0]						M_AXIS_tdata,
	input 																M_AXIS_tlast,
	input			[(PAM_MAP_AXI_DATA_WIDTH >> 3)-1:0]				    M_AXIS_tkeep,
	input																M_AXIS_tvalid,
	output			     												M_AXIS_tready,
/**********************  interface with add_frame_head ******************************/	
	input									     						PamMap2AddHead_ready,
	output																PamMap2AddHead_valid,
	output			[2*AD_CVER_WIDTH-1:0]								PamMap2AddHead_data
);

	
	localparam		MEM_ADDR_WIDTH = PAM_MAP_MEM_ADDR_WIDTH;

	localparam      MEM_DEPTH = (1 << MEM_ADDR_WIDTH);
	localparam		ZERO_PADDING = AD_CVER_WIDTH - 8;

	reg [2*PAM_ORDER-1:0] mem[0:MEM_DEPTH-1];
	
	reg [AD_CVER_WIDTH-1:0] pam_data_1, pam_data_0;
	
	assign PamMap2AddHead_data = {pam_data_1, pam_data_0};
	
	reg [MEM_ADDR_WIDTH-1:0] rec_addr, sent_addr;
	
	reg [MEM_ADDR_WIDTH:0] cnt_stored_data;

	//rec: one pat for ready signal
	//sent: wait ready signal
	localparam		IDLE = 2'b00;
	//rec: receive data from outer
	//sent: send data to outer 
	localparam 		S0   = 2'b01;
	//rec: wait mem exist space for received data
	//sent: wait mem exist data for senting
	localparam      S1   = 2'b10;
	

	wire  rec_valid = M_AXIS_tvalid && M_AXIS_tready;// enable receive data
	wire  sent_valid = PamMap2AddHead_ready && PamMap2AddHead_valid;// enable send data

	reg M_AXIS_tready_r;
	assign M_AXIS_tready = M_AXIS_tready_r;
    
  

/**************************************  received data from outer  *****************************************/
	
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
	//ready signal
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n)
			M_AXIS_tready_r <= 1'b0;
		else begin
			if( (IDLE == rec_cur_state)&&(S0 == rec_nxt_state))
				M_AXIS_tready_r <= 1'b1;
			else if( (S0 == rec_cur_state) && (S1 == rec_nxt_state) )
				M_AXIS_tready_r <= 1'b0;
		end
	end
	
	
	//receive signal
	integer i;
	always@(posedge clk or negedge arst_n) begin
		if(!arst_n) begin
			rec_addr <= 'b0;
			for(i = 0; i < MEM_DEPTH; i=i+1)
				mem[i] <= 'b0;
		end
		else begin
			if(rec_cur_state == S0) begin
				if( rec_valid ) begin
					case(M_AXIS_tkeep)
						4'b1111:begin
							rec_addr <= rec_addr + 4;
							mem[rec_addr] <= M_AXIS_tdata[31:24];
							mem[rec_addr+1] <= M_AXIS_tdata[23:16];
							mem[rec_addr+2] <= M_AXIS_tdata[15:8];
							mem[rec_addr+3] <= M_AXIS_tdata[7:0];
						end
						4'b1110:begin
							rec_addr <= rec_addr + 3;
							mem[rec_addr] <= M_AXIS_tdata[31:24];
							mem[rec_addr+1] <= M_AXIS_tdata[23:16];
							mem[rec_addr+2] <= M_AXIS_tdata[15:8];
						end
						4'b1100:begin
							rec_addr <= rec_addr + 2;
							mem[rec_addr] <= M_AXIS_tdata[31:24];
							mem[rec_addr+1] <= M_AXIS_tdata[23:16];
						end
						4'b1000:begin
							rec_addr <= rec_addr + 1;
							mem[rec_addr] <= M_AXIS_tdata[31:24];
						end
						default:rec_addr <= rec_addr;
					endcase
				end
				else
					rec_addr <= rec_addr;
			end
			else
				rec_addr <= rec_addr;
		end
	end
	
	//caculate stored space
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n)
			cnt_stored_data <= 'b0;
		else begin
			case({rec_valid,sent_valid})
				2'b11:begin
					case(M_AXIS_tkeep)
						4'b1111:cnt_stored_data <= cnt_stored_data + 3;
						4'b1110:cnt_stored_data <= cnt_stored_data + 2;
						4'b1100:cnt_stored_data <= cnt_stored_data + 1;
						4'b1000:cnt_stored_data <= cnt_stored_data ;
						default:cnt_stored_data <= cnt_stored_data - 1;
					endcase
				end
				2'b10:begin
					case(M_AXIS_tkeep)
						4'b1111:cnt_stored_data <= cnt_stored_data + 4;
						4'b1110:cnt_stored_data <= cnt_stored_data + 3;
						4'b1100:cnt_stored_data <= cnt_stored_data + 2;
						4'b1000:cnt_stored_data <= cnt_stored_data + 1;
						default:cnt_stored_data <= cnt_stored_data;
					endcase
				end
				2'b01:cnt_stored_data <= cnt_stored_data - 1;
				default: cnt_stored_data <= cnt_stored_data;
			endcase
		end
	end
	
	assign rec_flag_S0_over = (cnt_stored_data >= MEM_DEPTH - (PAM_MAP_AXI_DATA_WIDTH>>2)) ? 1'b1 : 1'b0;
	
//S1
	assign rec_flag_S1_over = (cnt_stored_data < MEM_DEPTH - (PAM_MAP_AXI_DATA_WIDTH>>2)) ? 1'b1 : 1'b0;
	
/************************************* sent signal to add_head_frame ****************************************/	
	wire sent_flag_IDLE_over, sent_flag_S0_over, sent_flag_S1_over;
	reg  [1:0] sent_cur_state, sent_nxt_state;
	
	reg PamMap2AddHead_valid_r;
	assign PamMap2AddHead_valid = PamMap2AddHead_valid_r;

// FSM
	always@(posedge clk or negedge arst_n) begin
		if(!arst_n)
			sent_cur_state <= IDLE;
		else
			sent_cur_state <= sent_nxt_state;
	end

	always@(*) begin
		if(!arst_n)
			sent_nxt_state = IDLE;
		else begin
			case(sent_cur_state)
				IDLE:begin
					if(1'b1 == sent_flag_IDLE_over)
						sent_nxt_state = S0;
					else
						sent_nxt_state = IDLE;
				end
				S0:begin
					if(1'b1 == sent_flag_S0_over)
						sent_nxt_state = S1;
					else
						sent_nxt_state = S0;
				end
				S1:begin
					if(1'b1 == sent_flag_S1_over)
						sent_nxt_state = IDLE;
					else
						sent_nxt_state = S1;//should not be nxt_state = nxt_state
				end
			endcase
		end
	end

//IDLE
	assign sent_flag_IDLE_over = ( (1 == PamMap2AddHead_ready)&&(cnt_stored_data > 0) ) ? 1'b1 : 1'b0;
	
//S0
	//data with valid signal and addr can be calcued lonely by pre valid and ready signal
	//valid data
	wire [MEM_ADDR_WIDTH-1:0] sent_addr_w;
	reg [PAM_ORDER-1:0] detect_data_1,detect_data_0;
	
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n) begin
			PamMap2AddHead_valid_r <= 'b0;
			{pam_data_1, pam_data_0} <= 'b0;
			detect_data_1 <= 'b0;
			detect_data_0 <= 'b0;
		end
		else begin
			if( S0 == sent_cur_state ) begin
				PamMap2AddHead_valid_r <= 1'b1;
				//for simulation
				detect_data_1 <= mem[sent_addr_w][2*PAM_ORDER-1:PAM_ORDER];
				detect_data_0 <= mem[sent_addr_w][PAM_ORDER-1:0];
				// for synthesis
				pam_data_1 <= pam_map_func( mem[sent_addr_w][2*PAM_ORDER-1:PAM_ORDER] );
				pam_data_0 <= pam_map_func( mem[sent_addr_w][PAM_ORDER-1:0] );
	//for simulation
	//			pam_data_1 <= { {ZERO_PADDING{1'b0}}, mem[sent_addr_w][2*PAM_ORDER-1:PAM_ORDER] };
	//			pam_data_0 <= { {ZERO_PADDING{1'b0}}, mem[sent_addr_w][PAM_ORDER-1:0] };
			end
			else begin
				PamMap2AddHead_valid_r <= 1'b0;
				{pam_data_1, pam_data_0} <= 'b0;
			end
		end
	end

	assign sent_addr_w = ( 1'b1==sent_valid ) ? sent_addr+1'b1 : sent_addr;
	always@(posedge clk or negedge arst_n) begin
		if(~arst_n)
			sent_addr <= 'b0;
		else
			sent_addr <= sent_addr_w;
	end


	assign sent_flag_S0_over = ( cnt_stored_data <= 3) ? 1'b1 : 1'b0;
//S1
	assign sent_flag_S1_over = (cnt_stored_data > 3) ? 1'b1 : 1'b0;

function [AD_CVER_WIDTH-1:0] pam_map_func;
	input [PAM_ORDER-1:0] pam_data;
	begin
		case(pam_data)
			4'd15: pam_map_func  = 12'b0111_1111_1111;
			4'd14: pam_map_func  = 12'b0110_1110_1110;
			4'd13: pam_map_func  = 12'b0101_1101_1101;
			4'd12: pam_map_func  = 12'b0100_1100_1100;
			4'd11: pam_map_func  = 12'b0011_1011_1011;
			4'd10: pam_map_func  = 12'b0010_1010_1010;
			4'd9 : pam_map_func  = 12'b0001_1001_1001;
			4'd8 : pam_map_func  = 12'b0000_1000_1000;
			4'd7 : pam_map_func  = 12'b1111_0111_0111;
			4'd6 : pam_map_func  = 12'b1110_0110_0110;
			4'd5 : pam_map_func  = 12'b1101_0101_0101;
			4'd4 : pam_map_func  = 12'b1100_0100_0100;
			4'd3 : pam_map_func  = 12'b1011_0011_0011;
			4'd2 : pam_map_func  = 12'b1010_0010_0010;
			4'd1 : pam_map_func  = 12'b1001_0001_0001;
			4'd0 : pam_map_func  = 12'b1000_0000_0000;
		endcase
	end
endfunction

endmodule
