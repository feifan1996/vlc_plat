`ifndef MY_IF_FIFO2PAM__SV
`define MY_IF_FIFO2PAM__SV

interface my_if_f2p#(int AXI_DATA_WIDTH = 32)
(input clk, input arst_n);

   logic [AXI_DATA_WIDTH-1:0] M_AXIS_tdata;
   logic [(AXI_DATA_WIDTH>>3)-1:0] M_AXIS_tkeep;
   logic M_AXIS_tvalid, M_AXIS_tready;

endinterface

`endif
