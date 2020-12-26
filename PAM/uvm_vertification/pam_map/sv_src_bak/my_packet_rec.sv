`ifndef MY_PACKET_REC__SV
`define MY_PACKET_REC__SV

class my_packet_rec#(int AD_CVER_WIDTH = 12) extends uvm_object;

	bit [2*AD_CVER_WIDTH-1:0]	data;

   `uvm_object_param_utils_begin(my_packet_rec#(AD_CVER_WIDTH))
      `uvm_field_int(data, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_packet_rec");
      super.new();
   endfunction

endclass
`endif
