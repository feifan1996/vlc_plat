`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
   
	localparam	AXI_DATA_WIDTH = 32;
	localparam	AD_CVER_WIDTH = 12;
	localparam	AXI_KEEP_WIDTH = AXI_DATA_WIDTH >> 3;

	uvm_blocking_get_port #(my_packet_sent)  port;
	uvm_analysis_port #(my_packet_rec)  ap;

	int wrt_ptr, rd_ptr;
	bit [3:0] mem [1+2*AXI_KEEP_WIDTH];


	function bit [AD_CVER_WIDTH-1:0] pam_map(bit [3:0] data);
		case(data)
			4'd15:  pam_map = 12'b0111_1111_1111;
			4'd14:  pam_map = 12'b0110_1110_1110;
			4'd13:  pam_map = 12'b0101_1101_1101;
			4'd12:  pam_map = 12'b0100_1100_1100;
			4'd11:  pam_map = 12'b0011_1011_1011;
			4'd10:  pam_map = 12'b0010_1010_1010;
			4'd9 :  pam_map = 12'b0001_1001_1001;
			4'd8 :  pam_map = 12'b0000_1000_1000;
			4'd7 :  pam_map = 12'b1111_0111_0111;
			4'd6 :  pam_map = 12'b1110_0110_0110;
			4'd5 :  pam_map = 12'b1101_0101_0101;
			4'd4 :  pam_map = 12'b1100_0100_0100;
			4'd3 :  pam_map = 12'b1011_0011_0011;
			4'd2 :  pam_map = 12'b1010_0010_0010;
			4'd1 :  pam_map = 12'b1001_0001_0001;
			4'd0 :  pam_map = 12'b1000_0000_0000;
		endcase
	endfunction


	extern function new(string name, uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern virtual  task main_phase(uvm_phase phase);
	extern task pam_map_ref_model(my_packet_sent pkt_sent);
//	extern function bit [AD_CVER_WIDTH-1:0] pam_map(bit [3:0] data);

	`uvm_component_utils(my_model)
endclass 

function my_model::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction 

function void my_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	port = new("port", this);
	ap = new("ap", this);
	this.wrt_ptr = 0;
	this.rd_ptr = 0;
	for(int i=0; i < AXI_KEEP_WIDTH; i++)
		mem[i] = 'b0;
endfunction

task my_model::main_phase(uvm_phase phase);
	my_packet_sent pkt_sent;
	super.main_phase(phase);
	while(1) begin
		port.get(pkt_sent);
		//pkt_sent.print();
		`uvm_info("my_model", "get one transaction", UVM_LOW)
		pam_map_ref_model(pkt_sent);	
	end
endtask


task my_model::pam_map_ref_model(my_packet_sent pkt_sent);
	
	my_packet_rec pkt_rec;
	int num_valid_data,num_valid_data_mem;

//	pkt_sent.print();
	//calc the num valid byte
	num_valid_data = 0;
	for(int i=0; i<AXI_KEEP_WIDTH; i++)
		num_valid_data += pkt_sent.keep[i];

//	$display("num_valid_data = %d", num_valid_data);
	//write data to mem, and renew wrt_ptr
	for(int i=0; i<2*num_valid_data; i++) begin
		mem[wrt_ptr] = pkt_sent.data[AXI_DATA_WIDTH-1-i*4 -: 4];
	//	$display("mem[%d] = %h", wrt_ptr, mem[wrt_ptr]);
		wrt_ptr = (wrt_ptr+1)%(1+2*AXI_KEEP_WIDTH);
	end

	//calc valid data in mem and renew rd_ptr
	num_valid_data_mem = ( wrt_ptr >= rd_ptr ) ? (wrt_ptr-rd_ptr) : (wrt_ptr+(1+2*AXI_KEEP_WIDTH-rd_ptr));
	for(int i=0,pos_0 = 0, pos_1 = 0; i<(num_valid_data_mem/2); i++) begin
		pkt_rec = new("pkt_rec");
		pos_0 = (rd_ptr%(1+2*AXI_KEEP_WIDTH));
		pos_1 = ((rd_ptr+1)%(1+2*AXI_KEEP_WIDTH)); 
	//	$display("mem[%d] = %h", pos_0, mem[pos_0]);
	//	$display("mem[%d] = %h", pos_1, mem[pos_1]);
		pkt_rec.data = {pam_map(mem[pos_0]), pam_map(mem[pos_1])};	
		//pkt_rec.print();
		rd_ptr = (rd_ptr+2)%(1+2*AXI_KEEP_WIDTH);
		ap.write(pkt_rec);
	end

endtask;

/*
function bit [AD_CVER_WIDTH-1:0] my_model::pam_map(bit [3:0] data);
	case(data)
		4'd15:  pam_map = 12'b0111_1111_1111;
		4'd14:  pam_map = 12'b0110_1110_1110;
		4'd13:  pam_map = 12'b0101_1101_1101;
		4'd12:  pam_map = 12'b0100_1100_1100;
		4'd11:  pam_map = 12'b0011_1011_1011;
		4'd10:  pam_map = 12'b0010_1010_1010;
		4'd9 :  pam_map = 12'b0001_1001_1001;
		4'd8 :  pam_map = 12'b0000_1000_1000;
		4'd7 :  pam_map = 12'b1111_0111_0111;
		4'd6 :  pam_map = 12'b1110_0110_0110;
		4'd5 :  pam_map = 12'b1101_0101_0101;
		4'd4 :  pam_map = 12'b1100_0100_0100;
		4'd3 :  pam_map = 12'b1011_0011_0011;
		4'd2 :  pam_map = 12'b1010_0010_0010;
		4'd1 :  pam_map = 12'b1001_0001_0001;
		4'd0 :  pam_map = 12'b1000_0000_0000;
	endcase
endfunction
*/

`endif
