/*
 * hb_mem.sv
 * Author: William Bao
 * Last Revision: 02/24/19
 *
 * This is a simple synchronous write, asynchronous read memory module
 * "hb" stands for high_bandwidth. Default data width is 256-bit.
 * For the purpose of simulation, write is disabled since the
 * convolution layer never writes to memory. In a real system, this
 * memory would likely service writes from other blocks.
 *
 */
`include "conv_top.svh"

module hb_mem #(
    parameter ADDR_WIDTH = 20,
    parameter DATA_WIDTH = 256
)(
	input clk,    // Clock
    //input rst_n,  // Asynchronous reset active low

	// control logic
	//input logic                      we,
	
	// write input
	//input logic     [ADDR_WIDTH-1:0] w_addr,
	//input logic     [DATA_WIDTH-1:0] w_data,

	// read input
	input logic     [ADDR_WIDTH-1:0] r_addr,
	output logic    [DATA_WIDTH-1:0] r_data
);

    logic           [DATA_WIDTH-1:0] memory [1 << ADDR_WIDTH]; 

    assign r_data = memory[r_addr];

	/*always_ff @(posedge clk)
	begin
		if(we)
		begin
			memory[w_addr] <= w_data;
		end
	end*/ 
    
endmodule