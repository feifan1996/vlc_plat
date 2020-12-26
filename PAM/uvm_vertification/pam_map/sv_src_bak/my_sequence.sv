`ifndef MY_SEQUENCE__SV
`define MY_SEQUENCE__SV

class my_sequence#(int AXI_DATA_WIDTH = 32) extends uvm_sequence #(my_transaction#(AXI_DATA_WIDTH));
   
   my_transaction#(AXI_DATA_WIDTH) m_trans;

   function new(string name= "my_sequence");
      super.new(name);
   endfunction

   virtual task body();
      if(starting_phase != null) 
         starting_phase.raise_objection(this);
      repeat (10) begin
         `uvm_do(m_trans)
      end
      #1000;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask

   `uvm_object_param_utils(my_sequence#(AXI_DATA_WIDTH))
endclass
`endif
