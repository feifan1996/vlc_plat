`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction#(int AXI_DATA_WIDTH = 32) extends uvm_sequence_item;

	localparam	AXI_KEEP_WIDTH = AXI_DATA_WIDTH >> 3;

	rand bit[AXI_DATA_WIDTH-1:0] data[]; //rand axi_data
	rand bit[AXI_KEEP_WIDTH-1:0] keep[]; //rand keep value
	rand byte num_interval_valid;// the low interval of two valid signal
	rand byte num_interval_ready;// the low interval of two ready signal
	int sum_one;

	bit [AXI_KEEP_WIDTH-1:0] keep_value[AXI_KEEP_WIDTH];
	bit [AXI_KEEP_WIDTH-1:0] all_one;

	constraint axi_cons{
		data.size >= 1;
		data.size <= 100;
		data.size == keep.size;
		foreach(keep[i])
				keep[i] == {AXI_KEEP_WIDTH{1'b1}};
		num_interval_valid dist {0:/50,[1:10]:/50};
		num_interval_ready dist {0:/50,[1:10]:/50};
/*		foreach(keep[i])
			foreach(keep[j])
				sum_one += keep[i][j];
		0 == sum_one % 2;
*/
		0 == cons_calc_sum_1_array(keep) % 2;
	}


   `uvm_object_param_utils_begin(my_transaction#(AXI_DATA_WIDTH))
      `uvm_field_array_int(data, UVM_ALL_ON)
      `uvm_field_array_int(keep, UVM_ALL_ON)//test
      `uvm_field_int(num_interval_valid, UVM_ALL_ON)
      `uvm_field_int(num_interval_ready, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
	  all_one = {AXI_KEEP_WIDTH{1'b1}};
	  for(int i=0;i<AXI_KEEP_WIDTH;i=i+1)
		keep_value[i] = all_one << i;
	  sum_one = 0;
   endfunction

	function int calc_sum_1_array();
		return sum_one;
	endfunction

	function int cons_calc_sum_1_array(bit [AXI_KEEP_WIDTH-1:0] keep []);
		cons_calc_sum_1_array = 0;
		for(int i=0; i < keep.size; i++)
			for(int j=0; j < AXI_KEEP_WIDTH; j++)
				cons_calc_sum_1_array += keep[i][j];
	endfunction
	
	function void pos_randomize();
		sum_one = cons_calc_sum_1_array(keep); 
	endfunction

/*
	function int cal_sum_1_vector(bit [AXI_KEEP_WIDTH-1:0] keep);
		cal_sum_1_vector = 0;
		for(int i=0; i < AXI_KEEP_WIDTH; i++)
			cal_sum_1_vector += keep[i];
	endfunction
*/
endclass
`endif
