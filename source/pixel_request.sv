/*
 * pixel_request.sv
 * Author: William Bao
 * Last Revision: 03/06/19
 *
 * This module is the pixel request unit. Given a pixel, it will
 * generate up to 16 parallel address requests.
 *
 */
`include "conv_top.svh"

module pixel_request (

    // input current pixel
    input logic            [11:0] in_row,         // row of current pixel
    input logic            [11:0] in_column,      // column of current pixel
    input logic            [11:0] in_width,       // width of picture/filter
    input logic            [19:0] in_offset,      // starting address offset
    input logic             [3:0] in_filter_size, // filter size
    input logic                   in_zero,        // zero override (outputs zeros for all rows)

    output logic           [19:0] out_req       [16], // decoded request address
    output logic            [4:0] out_sel       [16], // decoded select byte of data
    output logic                  out_valid_req [16]  // decoded select byte of data
);

    logic [11:0] row [16];

    always_comb
    begin
        row[0] = in_row;
        for(int i=0; i<15; i++)
        begin
            row[i+1] = row[i] + 1;
        end
    end
    
    always_comb
    begin
        for(int i=0; i<16; i++)
        begin
            out_valid_req[i] = ((i <= in_filter_size) && (in_zero == 0)) ? 1 : 0;
        end
    end

    genvar n;
    
    generate
        for(n=0; n<16; n++)
        begin:pixdec
            pixel_decoder pixel_decoder(
                .in_row(row[n]),
                .in_column(in_column),
                .in_width(in_width),
                .in_offset(in_offset),
                .out_req(out_req[n]),
                .out_sel(out_sel[n])
            );
        end
    endgenerate

endmodule