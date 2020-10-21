# UART

A UART includes a transmitter and a receiver. The transmitter is essentially a special
shift register that loads data in parallel and then shifts it out bit by bit at a specific rate.
The receiver, on the other hand, shifts in data bit by bit and then reassembles the data. The
serial line is 1 when it is idle. 

The transmission starts with a start bit, which is 0, followed by data bits and an optional parity bit, 
and ends with stop bits, which are 1 . The number of data bits can be 6, 7, or 8. 
The optional parity bit is used for error detection. For odd parity, it is set to 0 when the data bits have an odd number of 1's. 
For even parity, it is set to 0 when the data bits have an even number of 1's. 
The number of stop bits can be 1, 1.5 or 2. 

# Note that the LSB of the data word is transmitted first.


Transmission with 8 data bits, no parity, and 1 stop bit is shown in Figure.

		___Idle
	   /
	  /	       __Start Bit											 ___Stop Bit
	 /        /														/
____/_____   /   ____  ____  ____  ____  ____  ____  ____  ____  __/_____
		 |  /   / d0 \/ d1 \/ d2 \/ d3 \/ d4 \/ d5 \/ d6 \/ d7 \/ /	 :	
		 |______\____/\____/\____/\____/\____/\____/\____/\____/     :
