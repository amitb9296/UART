  /*
	A FIFO buffer usually contains two status signals, 
	full and empty, to indicate that the FIFO is full 
	(i.e., cannot be written) and empty 
	(i.e., cannot be read), respectively. One of the two 
	conditions occurs when the read pointer is equal to 
	the write pointer.
 */
 
 module FIFO_BUFFER #
 	(
 		parameter B = 9, 	// Number of bits in a word
 				  W = 4		// Number of address bits
 	)
 	(
	 	input 			clk,    // Clock
	 	input 			reset,  // Asynchronous reset
	 	input 			rd, wr,
	 	input  [B-1:0] 	w_data,
	 	output 			empty, full,
	 	output [B-1:0] 	r_data
	 );
 
// Signal Declaration
	reg [B-1:0] array_reg [2**W-1:0];		// Register Array
	reg [W-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
	reg [W-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
	reg 		full_reg, full_next; 
	reg 		empty_reg, empty_next;

// Body Register file write operation
	always@(posedge clk)
		if(wr_en)
			array_reg[w_ptr_reg]	<= 	w_data;

// Register file read operation
	assign r_data	= 	array_reg[r_ptr_reg];

// Write enabled only when FIFO is not full	
	assign wr_en 	= 	wr & ~full_reg;


// FIFO Control logic
// Register for read and write pointers
	always@(posedge clk, posedge reset)
		if(reset)
			begin
				w_ptr_reg	<=	0;
				r_ptr_reg	<= 	0;
				full_reg	<= 	1'b0;
				empty_reg	<=	1'b1;				
			end
		else
			begin
				w_ptr_reg	<= 	w_ptr_next;
				r_ptr_reg	<=	r_ptr_next;
				full_reg	<=	full_next;
				empty_reg	<=	empty_next;
			end

// Next State Logic for read and write pointers
	always@(*)
		begin
			// Successive Pointer Values
			w_ptr_succ	=	w_ptr_reg + 1;
			r_ptr_succ	= 	r_ptr_reg + 1;

			// Default: Keep old values
			w_ptr_next	=	w_ptr_reg;
			r_ptr_next	=	r_ptr_reg;
			full_next 	= 	full_reg;
			empty_next 	= 	empty_reg;

			case ({wr,rd})
			//  2'b00: No Operation
				2'b01	:	// Read
							if(~empty_reg)	// Not Empty
								begin
									r_ptr_next	=	r_ptr_succ;
									full_next	= 	1'b0;

									if(r_ptr_succ == w_ptr_reg)
										empty_next = 1'b1;
								end
				2'b10 	:	// Write
							if(~full_reg)	// Not Full
								begin
									w_ptr_next	    = 	w_ptr_succ;
									empty_next	    = 	1'b0;
									if(w_ptr_succ == r_ptr_reg)
										full_next 	= 	1'b1;
								end	
				2'b11	:	// Write and Read
							begin
								w_ptr_next	= 	w_ptr_succ;
								r_ptr_next	=	r_ptr_succ;
							end
			endcase
		end

// Output
	assign full 	=	full_reg;
	assign empty 	= 	empty_reg;

endmodule
