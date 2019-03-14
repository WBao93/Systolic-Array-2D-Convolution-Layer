/*
 * controller.sv
 * Author: William Bao
 * Last Revision: 03/06/19
 *
 * This module houses the main control logic of the accelerator.
 *
 */
`include "conv_top.svh"

module controller (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Instruction read control
    output logic               fifo_r_en,
    input  logic               fifo_r_accept,
    input  logic        [31:0] fifo_inst,
    
    // pixel selection
    output logic        [11:0] row,
    output logic        [11:0] column,
    output logic        [11:0] width,
    output logic        [19:0] offset,
    output logic         [3:0] filter_size,
    output logic               zero,
    
    output logic               load_en,
    input  logic               scratch_rdy,
    
    output logic               shift_en,
    output logic               store_en,
    
    output logic               valid_pixel,
    output logic               out_last,
    input  logic               in_last,
    
    output logic               conv_done
);

    logic        [19:0] filter_offset;
  //logic         [3:0] filter_size;
    logic         [3:0] filter_num;
    logic        [19:0] img_offset;
    logic        [11:0] img_height;
    logic        [11:0] img_width;
    logic         [3:0] inst_flag;
    
    logic        [11:0] max_pixel_row;
    logic        [11:0] max_pixel_column;
    logic               valid_dim;
    
    assign max_pixel_row = img_height - filter_size;
    assign max_pixel_column = img_width - filter_size;
    assign valid_dim = ((img_height >= filter_size) && (img_width >= filter_size)) ? 1 : 0;

    inst_decoder inst_decoder(
        .clk(clk),
        .rst_n(rst_n),
        .in_inst(fifo_inst),
        .r_accept(fifo_r_accept),
        .filter_offset(filter_offset),
        .filter_size(filter_size),
        .filter_num(filter_num),
        .img_offset(img_offset),
        .img_height(img_height),
        .img_width(img_width),
        .inst_flag(inst_flag),
        .conv_done(conv_done)
    );
    
    // TO DO
    
    //state machine
    logic         [4:0] filter_count;
    logic         [4:0] next_filter_count;
    logic        [11:0] next_row;
    logic        [11:0] next_column;
    
    logic         [2:0] state;
    logic         [2:0] next_state;
    localparam IDLE           = 3'b000;
    localparam FILTER_LOAD    = 3'b001;
    localparam FILTER_ZERO    = 3'b010;
    localparam FILTER_SAVE    = 3'b011;
    localparam IMAGE_LOAD     = 3'b100;
    localparam ITERATION_DONE = 3'b101;
    
    always_comb 
    begin
        if (state == IDLE)
        begin
            if ((inst_flag == 4'b1111) && (valid_dim == 1) 
                && (filter_count <= filter_num))
            begin
                next_state               = FILTER_LOAD;
                fifo_r_en                = 0;
                next_filter_count        = filter_count + 1;
                conv_done                = 0;
            end
            else if (inst_flag == 4'b1111)
            begin
                next_state               = IDLE;
                fifo_r_en                = 1;
                next_filter_count        = 0;
                conv_done                = 1;
            end
            else
            begin
                next_state               = IDLE;
                fifo_r_en                = 1;
                next_filter_count        = 0;
                conv_done                = 0;
            end
            next_row                     = filter_count*(filter_size+1);
            next_column                  = 0;
            width                        = filter_size;
            offset                       = filter_offset;
            zero                         = 1;
            load_en                      = 1;
            shift_en                     = 0;
            store_en                     = 0;
            valid_pixel                  = 0;
            out_last                     = 0;
        end
        else if (state == FILTER_LOAD)
        begin
            if ((scratch_rdy == 1) && (column < 15))
            begin
                next_state               = FILTER_ZERO;
                next_column = column + 1;
            end
            else if ((scratch_rdy == 1) && (column == 15))
            begin
                next_state               = FILTER_SAVE;
                next_column = 0;
            end
            else
            begin
                next_state               = FILTER_LOAD;
                next_column = column;
            end
            fifo_r_en                    = 0;
            next_filter_count            = filter_count;
            next_row                     = row;
            width                        = filter_size;
            offset                       = filter_offset;
            zero                         = (column <= filter_size) ? 0 : 1;
            load_en                      = 1;
            shift_en                     = scratch_rdy;
            store_en                     = 0;
            valid_pixel                  = 0;
            out_last                     = 0;
            conv_done                    = 0;
        end
        else if (state == FILTER_ZERO)
        begin
            next_state                   = FILTER_LOAD;
            fifo_r_en                    = 0;
            next_filter_count            = filter_count;
            next_row                     = row;
            next_column                  = column;
            width                        = filter_size;
            offset                       = filter_offset;
            zero                         = 1;
            load_en                      = 1;
            shift_en                     = 1;
            store_en                     = 0;
            valid_pixel                  = 0;
            out_last                     = 0;
            conv_done                    = 0;
        end
        else if (state == FILTER_SAVE)
        begin
            next_state                   = IMAGE_LOAD;
            fifo_r_en                    = 0;
            next_filter_count            = filter_count;
            next_row                     = 0;
            next_column                  = 0;
            width                        = img_width;
            offset                       = img_offset;
            zero                         = 1;
            load_en                      = 1;
            shift_en                     = 0;
            store_en                     = 1;
            valid_pixel                  = 0;
            out_last                     = 0;
            conv_done                    = 0;
        end
        else if (state == IMAGE_LOAD)
        begin
            if ((scratch_rdy == 1) && (column >= img_width) && (row >= max_pixel_row))
            begin
                next_state               = ITERATION_DONE;
                next_row                 = 0;
                next_column              = 0;
                out_last                 = 1;
            end
            else if ((scratch_rdy == 1) && (column >= img_width))
            begin
                next_state               = IMAGE_LOAD;
                next_row                 = row + 1;
                next_column              = 0;
                out_last                 = 0;
            end
            else if (scratch_rdy == 1)
            begin
                next_state               = IMAGE_LOAD;
                next_row                 = row;
                next_column              = column + 1;
                out_last                 = 0;
            end
            else
            begin
                next_state               = IMAGE_LOAD;
                next_row                 = row;
                next_column              = column;
                out_last                 = 0;
            end
            fifo_r_en                    = 0;
            next_filter_count            = filter_count;
            width                        = img_width;
            offset                       = img_offset;
            zero                         = 0;
            load_en                      = 1;
            shift_en                     = scratch_rdy;
            store_en                     = 0;
            valid_pixel                  = (column <= max_pixel_column) ? 1 : 0;
            conv_done                    = 0;
        end
        else if (state == ITERATION_DONE)
        begin
            if (in_last == 1)
            begin
                next_state               = IDLE;
                
            end
            else
            begin
                next_state               = ITERATION_DONE;
            end
            fifo_r_en                    = 0;
            next_filter_count            = filter_count;
            next_row                     = filter_count*(filter_size+1);
            next_column                  = 0;
            width                        = filter_size;
            offset                       = filter_offset;
            zero                         = 1;
            load_en                      = 1;
            shift_en                     = 1;
            store_en                     = 0;
            valid_pixel                  = 0;
            out_last                     = 0;
            conv_done                    = 0;
        end
        else // default recover state
        begin
            next_state                   = IDLE;
            fifo_r_en                    = 0;
            next_filter_count            = 0;
            next_row                     = 0;
            next_column                  = 0;
            width                        = 0;
            offset                       = 0;
            zero                         = 1;
            load_en                      = 0;
            shift_en                     = 0;
            store_en                     = 0;
            valid_pixel                  = 0;
            out_last                     = 0;
            conv_done                    = 0;
        end
    end
    
    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            state        <= IDLE;
            filter_count <= '0;
            row          <= '0;
            column       <= '0;
        end
        else
        begin
            state               <= next_state;
            filter_count        <= next_filter_count;
            row                 <= next_row;
            column              <= next_column;
		end
	end

endmodule