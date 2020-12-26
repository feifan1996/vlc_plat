`ifndef MY_PACKET_REC__SV
`define MY_PACKET_REC__SV

class my_packet_rec extends uvm_object;
	
	localparam	AD_CVER_WIDTH = 12;

	bit [2*AD_CVER_WIDTH-1:0]	data;

   `uvm_object_utils_begin(my_packet_rec)
      `uvm_field_int(data, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_packet_rec");
      super.new();
   endfunction

endclass
`endif
