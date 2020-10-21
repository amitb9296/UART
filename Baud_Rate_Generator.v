/*
=======================================================================
                        Buad Rate Generator
=======================================================================

    The Baud rate generator generates a sampling signal whose frequency 
    is exactly 16 times the UART's designated baud rate.
    
    The commonly used baud  rates are 2400, 4800, 9600, 19,200 bauds.
    
    For the 19200 baud rate, the sampling rate has to be 307,200 
    (i.e., 19200 * 16) ticks per second. Let's consider system clock 
    rate is 50 MHz, the baud rate generator needs a MOD-163
    (i.e.,(50000000)/307200 = 162.7604) counter, in which a one-clock
    cycle tick is aserrted once every 163 clock cycles.

*/

module Baud_Rate_Gen#(parameter N = 9,  // Number oof bits in counter
                                M = 163 // MOD - M 
                      )
                      
                     (  input  wire         clk,reset,
                        output wire         max_tick,
                        output wire [N-1:0] q
                     );

// Signal Declaration
    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;
    

// Body Register    
    always@(posedge clk, posedge reset)
        if(reset)
            r_reg   <= 0;
        else
            r_reg   <= r_next;
    
    
 // Next State Logic
    
    assign r_next   = (r_reg == (M-1)) ? 0 : r_reg + 1;
    
    
 // Output Logic
    
    assign q        = r_reg;
    assign max_tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;    

endmodule
