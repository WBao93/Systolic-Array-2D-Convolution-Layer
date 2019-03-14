/*
 * pixel_decoder.sv
 * Author: William Bao
 * Last Revision: 03/06/19
 *
 * This module decodes a requested pixel into an address and byte select 
 *
 */
`include "conv_top.svh"

module pixel_decoder (

    // Input requested pixel
    input logic            [11:0] in_row,    // row of requested pixel
    input logic            [11:0] in_column, // column of requested pixel
    input logic            [11:0] in_width,  // width of picture/filter
    input logic            [19:0] in_offset, // starting address offset

    // Output address request and byte select
    output logic           [19:0] out_req,   // decoded request address
    output logic            [4:0] out_sel    // decoded select byte of data
);

    logic        [23:0] pixel;

    assign pixel   = (in_row*(in_width+1)) + in_column;

    assign out_req = pixel[23:5] + in_offset[19:0];
    
    // Since high byte represents left-most pixel, selection needs
    // to be inverted
    assign out_sel = 31 - pixel[4:0]; 

endmodule