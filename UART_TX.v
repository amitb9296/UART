`timescale 1ns / 1ps

module UART_TX#(parameter	DBIT 	= 8,	// Data
							SB_TICK	= 16	// ticks for stop bits
				)
				(
					input	 	clk,reset,
					input		tx_start, s_tick,
					input [7:0]	din,
					output reg 	tx_done_tick,
					output   	tx
				);

// STATE Declaration
	localparam	[1:0]	IDLE	=	2'b00,
						START 	=	2'b01,
						DATA 	=	2'b10,
						STOP 	= 	2'b11;

// Signal Declaration
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    reg 	  tx_reg, tx_next;

// FSM State & Data Register
    always@(posedge clk, posedge reset)
        if(reset)
            begin
                state_reg   <=  IDLE;
                s_reg       <=  0;
                n_reg       <=  0;
                b_reg       <=  0;
                tx_reg 		<= 	1'b1;     
            end
        else
            begin
                state_reg   <=  state_next;
                s_reg       <=  s_next;
                n_reg       <=  n_next;
                b_reg       <=  b_next;
                tx_reg 		<= 	tx_next; 
            end

// Next State Logic & Functional Unit
	always @(*)
		begin 
			state_next		=	state_reg;
			tx_done_tick	= 	1'b0;
			s_next 			= 	s_reg;
			n_next 			= 	n_reg;
			b_next 			= 	b_reg;
			tx_next			= 	tx_reg;

			case (state_reg)
				// IDLE STATE
				IDLE	:	begin
								tx_next					= 	1'b1;

								if(tx_start)
									begin
										state_next		=	START;
										s_next 			= 	0;
										b_next 			= 	din;
									end
							end

				// START STATE
				START 	: 	begin
								tx_next 				= 	1'b0;

								if(s_tick)
									if(s_reg == 15)
										begin 
											state_next	=	DATA;
											s_next 		=	0;
											n_next 		= 	0; 
										end
									else
										s_next 			= 	s_reg + 1;
							end

				// DATA STATE
				DATA 	:	begin
								tx_next 				= 	1'b0;

								if(s_tick)
									if(s_reg == 15)
										begin
											s_next 		= 	0;
											b_next 		= 	b_reg >> 1;

											if(n_reg == (DBIT -1))
											 state_next = 	STOP;
											else
											 n_next 	= n_reg + 1;	
										end
									else
										s_next 			= s_reg + 1;
							end

				// STOP STATE
				STOP 	: 	begin
								tx_next 				= 	1'b1;
								if(s_tick)
									if(s_reg == (SB_TICK -1))
										begin 
										   state_next 	= 	IDLE;
										   tx_done_tick = 	1'b1;
             							end
             						else
             							s_next 			= s_reg + 1;
							end
			endcase
		end

// Output
	assign tx 	= tx_reg;

endmodule
