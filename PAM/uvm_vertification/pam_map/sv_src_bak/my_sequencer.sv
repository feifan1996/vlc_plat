`ifndef MY_SEQUENCER__SV
`define MY_SEQUENCER__SV

class my_sequencer#(int AXI_DATA_WIDTH = 32) extends uvm_sequencer #(my_transaction#(AXI_DATA_WIDTH));
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_param_utils(my_sequencer#(AXI_DATA_WIDTH))
endclass

`endif
