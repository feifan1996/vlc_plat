module Channel_Sim#(
	parameter	WIDTH_AD_COV = 12,
	parameter	MIN = -10,
	parameter	MAX = 10;
)(
	input									clk,
	input	[WIDTH_AD_COV-1:0] 				da_data,
	output	[WIDTH_AD_COV-1:0]				ad_data,
);
	
	reg [WIDTH_AD_COV-1:0] ad_data_r;
	
	always@(posedge clk) 
			ad_data_r <= da_data >> 1 + MIN + {$random}%(MAX-MIN+1);
	


endmodule