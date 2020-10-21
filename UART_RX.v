/*
==========================================================================
                                UART Receiver
==========================================================================

    The UART Receiver three major states, START, DATA, and STOP, which 
    represents the processing of the start bit, data bits, and stop bit.

*/

module UART_RX #(
                    parameter   DBIT    = 8,    // Data bits
                                SB_TICK = 16    // ticks for stop bits
                 )
                 (
                    input   wire        clk,reset,
                    input   wire        rx, s_tick,
                    output  reg         rx_done_tick,
                    output  wire [7:0]  dout                 
                 );
                 
 // State Declaration
    
   localparam   [1:0]   IDLE    =   2'b00,
                        START   =   2'b01,
                        DATA    =   2'b10,
                        STOP    =   2'b11; 

// Signal Declaration
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;
    reg [2:0] n_reg, n_next;
    reg [7:0] b_reg, b_next;
    

// FSM State & Data Register
    always@(posedge clk, posedge reset)
        if(reset)
            begin
                state_reg   <=  IDLE;
                s_reg       <=  0;
                n_reg       <=  0;
                b_reg       <=  0;      
            end
        else
            begin
                state_reg   <=  state_next;
                s_reg       <=  s_next;
                n_reg       <=  n_next;
                b_reg       <=  b_next; 
            end

// Next State Logic
    always@(*)
        begin
            state_next  	=   state_reg;
            rx_done_tick	=	1'b0;
            s_next 			= 	s_reg;
            n_next 			= 	n_reg;
            b_next			= 	b_reg;

            case (state_reg)
            	IDLE	:	if(~rx)
            					begin
									state_next			=	START;
									s_next 				= 	0;            							
            					end

            	START 	:	if(s_tick)
            					if(s_reg == 7)
            						begin
            							state_next		=	DATA;
            							s_next 			=	0;
            							n_next			= 	0;
            						end
            					else
            						s_next 				= 	s_reg + 1;

            	DATA 	:	if(s_tick)
            					if(s_reg == 15)
            						begin
            							s_next 			=	0;
            							b_next			= 	{rx,b_reg[7:1]};
            							if(n_reg == (DBIT -1))
            								state_next 	=	STOP;
            							else
            								n_next 		=	n_reg + 1;
            						end
            					else
            						s_next 				= 	s_reg + 1;

            	STOP 	:	if(s_tick)
            					if(s_reg == (SB_TICK - 1))
            						begin
            							state_next 		= 	IDLE;
            							rx_done_tick 	= 	1'b1;
            						end
            					else
            						s_next 				= 	s_reg + 1;
            endcase
        end

// Output
	assign dout = b_reg;
      
endmodule
                 
                                