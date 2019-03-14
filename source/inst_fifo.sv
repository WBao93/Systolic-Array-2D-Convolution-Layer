/*
 * inst_fifo.sv
 * Author: William Bao
 * Last Revision: 03/06/19
 *
 * This is the instruction FIFO. 
 * It is 8-deep (default), synchronous write, and asynchronous read
 *
 */
`include "conv_top.svh"

module inst_fifo #(
    parameter ADDR_WIDTH = 3 //default depth is 8 (2^3)
)(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Write side 
    input  logic [31:0] in_inst,  // FIFO input

    // Read side
    input  logic        r_en,     // read enable input
    output logic        r_accept, // indicate a read has been accepted
    output logic [31:0] out_inst  // FIFO output
);

    logic              [3:0] in_op;
    logic                    fifo_full;
    logic                    fifo_empty;
    logic             [31:0] fifo [1 << ADDR_WIDTH];
    logic   [ADDR_WIDTH-1:0] w_ptr;
    logic   [ADDR_WIDTH-1:0] r_ptr;
    logic                    w_accept;
    logic   [ADDR_WIDTH-1:0] counter;
    
    assign in_op = in_inst[31:28];
    
    // FIFO full and empty conditions
    assign fifo_full  = (counter == ((1 << ADDR_WIDTH) - 1));
    assign fifo_empty = (counter == 0);

    // Only accept instruction if FIFO isn't full and OP code
    // matches that of a supported instruction.
    assign w_accept = (fifo_full == 0 && 
            ((in_op == `OP_LF) ||
            (in_op == `OP_LS) ||
            (in_op == `OP_LI) ||
            (in_op == `OP_DC)));
            
    // Only accept a read request if the FIFO isn't empty 
    assign r_accept = (fifo_empty == 0 && r_en == 1);
    
    // Output a requested read asynchronously
    assign out_inst = fifo[r_ptr];
    
    // Update read and write pointer accordingly
    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            w_ptr   <= 0;
            r_ptr   <= 0;
            counter <= 0;
        end
        else
        begin
            if ((w_accept == 1) && (r_accept == 1))
            begin
                fifo[w_ptr] <= in_inst;
                w_ptr       <= w_ptr + 1;
                r_ptr       <= r_ptr + 1;
            end
            else if ((w_accept == 1) && (r_accept == 0))
            begin
                fifo[w_ptr] <= in_inst;
                w_ptr       <= w_ptr + 1;
                counter     <= counter + 1;
            end
            else if ((w_accept == 0) && (r_accept == 1))
            begin
                r_ptr       <= r_ptr + 1;
                counter     <= counter - 1;
            end
		end
	end

endmodule