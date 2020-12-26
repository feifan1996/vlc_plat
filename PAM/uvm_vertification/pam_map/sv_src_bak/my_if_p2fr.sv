`ifndef MY_IF_PAM2FRAME__SV
`define MY_IF_PAM2FRAME__SV

interface my_if_p2fr#(int AD_CVER_WIDTH = 12)
(
	input	clk, input arst_n
);

   logic [2*AD_CVER_WIDTH-1:0]	p2a_data;
   logic p2a_valid, p2a_ready;

endinterface

`endif
