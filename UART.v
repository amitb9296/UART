`timescale 1ns / 1ps

/*
	Default Setting : 
						19200 baud, 
						8 data bits, 
						1 stop bit, 
						2*2 FIFO 

*/
module UART#(parameter 	DBIT		=	8,	// Data bits
						SB_TICK 	= 	16,	// ticks for stop bits
											// 16/24/32 for 1/1.5/2 bits
						DVSR 		= 	163,// Baud rate divisor
											// DVSR = 50M/(16*baud rate)
						DVSR_BIT	= 	8,	// bits of DVSR
						FIFO_W		= 	2	// Addr bits of FIFO
											// words in FIFO = 2^FIFO_W
			)
			(
				input 			clk,reset,
				input 			rd_uart,wr_uart,rx,
				input  [7:0] 	w_data,
				output 			tx_full,rx_empty,tx,
				output [7:0]	r_data
			);

// Signal Declaration

	wire tick,rx_done_tick,tx_done_tick;
	wire tx_empty,tx_fifo_not_empty;
	wire [7:0] tx_fifo_out,rx_data_out;

// Body

	Baud_Rate_Gen#(.N(DVSR_BIT),.M(DVSR)) Buad_Gen_Unit
	              (.clk(clk),.reset(reset),
	               .max_tick(tick),.q());

	UART_RX #(.DBIT(DBIT),.SB_TICK(SB_TICK)) UART_Receiver
	         (	.clk(clk),.reset(reset),
				.rx(rx), .s_tick(s_tick),
				.rx_done_tick(rx_done_tick),
				.dout(rx_data_out));

	FIFO_BUFFER #
 			(.B(DBIT),.W(FIFO_W)) FIFO_RX_UNIT
 			(.clk(clk),.reset(reset),.rd(rd_uart), .wr(rx_done_tick),
	 		 .w_data(rx_data_out),.empty(rx_empty), .full(),
	 		 .r_data(r_data));			 

	FIFO_BUFFER #
 			(.B(DBIT),.W(FIFO_W)) FIFO_TX_UNIT
 			(.clk(clk),.reset(reset),.rd(tx_done_tick), .wr(wr_uart),
	 		 .w_data(wr_data),.empty(tx_empty), .full(tx_full),
	 		 .r_data(tx_fifo_out));			 

	UART_TX#(.DBIT(DBIT),.SB_TICK(SB_TICK)) UART_Transmitter
			(.clk(clk),.reset(reset),
			 .tx_start(tx_fifo_not_empty), .s_tick(tick),
			 .din(tx_fifo_out),
			 .tx_done_tick(tx_done_tick),
			 .tx(tx));

endmodule
