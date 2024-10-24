`timescale 1ns/1ps

module txd_tb;

logic 			clk			;
logic 			rst_n		;
logic 			frame_en	;
logic [5:0]		data_frame	;
logic 			tx_done		;
logic 			uart_tx		;

initial begin
	clk = 1;
	forever #10 clk = ~clk;
  end

initial begin
	rst_n = 1'b0;
	#22 rst_n = 1'b1;
  end

initial begin
	frame_en = 1'b0;
	#30 frame_en = 1'b1;
	#20 frame_en = 1'b0;
	@(posedge tx_done)
	#50frame_en = 1'b1;
	#20 frame_en = 1'b0;
	@(posedge tx_done) 
	#20 $finish;
end

initial begin
	data_frame = 8'b00101011;
	@(posedge tx_done)
	data_frame <= 8'b00110101;
end

	// initial begin
	// 	$dumpfile("uart_frame_tx_tb.vcd");
	// 	$dumpvars();
	// end

txd
#(
	.CLK_FREQUENCE	( 50_000_000 )	,
	.BPS			( 5_000_000 )	,
	.PARITY_BIT		( "NONE" )	,	//"NONE","EVEN","ODD"
	.FRAME_WD		( 6 )	
)
txd_inst
(
	.clk			( clk		 	 )	,
	.rst_n			( rst_n		 	 )	,
	.frame_en		( frame_en	 	 )	,
	.data_frame 	( data_frame	 )	,
	.tx_done		( tx_done		 )	,
	.uart_tx    	( uart_tx		 )	 
);

endmodule

