/*
 * pe.sv
 * Author: William Bao
 * Last Revision: 02/13/19
 *
 * Processing Element is a MAC that can store a weight
 *
 */
`include "conv_top.svh"

module pe (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// control logic
	input logic                       shift_en,
	input logic                       store_en,
	
	// input data
	input  logic unsigned       [7:0] in_x,
	
	// output data
	output logic unsigned       [7:0] out_x,
    
    // input accumulation 
    input  logic signed        [19:0] in_y,
    
    // output accumulation 
    output logic signed        [19:0] out_y
);

	// registers
    logic signed             [7:0] reg_w;  
    logic unsigned           [7:0] reg_x;
    logic signed            [19:0] reg_y; 

	// combinational logic
	logic signed             [8:0] signed_x;
	logic signed            [15:0] product;
   
    assign out_x     = reg_x;
	
	assign signed_x  = {1'b0, reg_x};
	assign product   = signed_x * reg_w;
    assign out_y     = product + reg_y;

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
            reg_x       <= 0;
            reg_w       <= 0;
            reg_y       <= 0;
		end
		else	
		begin
			if (shift_en)
			begin
                reg_x     <= in_x;
                reg_y     <= in_y; 
			end
			if (store_en)
			begin
				reg_w     <= reg_x;
			end
		end
	end
endmodule