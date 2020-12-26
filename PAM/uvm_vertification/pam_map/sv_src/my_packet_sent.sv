`ifndef MY_PACKET_SENT__SV
`define MY_PACKET_SENT__SV

class my_packet_sent extends uvm_object;
	
	localparam	AXI_DATA_WIDTH = 32;
	localparam	AXI_KEEP_WIDTH = AXI_DATA_WIDTH >> 3;

	bit [AXI_DATA_WIDTH-1:0]	data;
	bit [AXI_KEEP_WIDTH-1:0]	keep;

   `uvm_object_utils_begin(my_packet_sent)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(keep, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_packet_sent");
      super.new();
   endfunction

endclass
`endif
