/*
 * conv_top.sv
 * Author: William Bao
 * Last Revision: 03/13/19
 *
 * This is the top level design of the convolution layer.
 * It instantiates all of the modules of the convolution
 * layer and connects them. The only logic that exists 
 * here is used to determine if there is a new pixel
 * to provide at the layer output.
 *
 */
`include "conv_top.svh"

module conv_top (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// control logic
	input logic                     [31:0] in_inst,
    
    // memory bus
    output logic                    [19:0] r_addr,
    input logic                    [255:0] r_data,

    // data output
    output logic                     [7:0] out_data,
    output logic                           out_rdy,
    
    output logic                           conv_done
);

    // control to instruction fifo_empty
    logic    [31:0] fifo_inst;
    logic           fifo_r_accept;
    logic           fifo_r_en;

    // control output to pixel requester
    logic    [11:0] row;
    logic    [11:0] column;
    logic    [11:0] width;
    logic    [19:0] offset;
    logic     [3:0] filter_size;
    logic           zero;
    
    // control to scratchpad
    logic           load_en;
  //logic     [3:0] filter_size;
    logic           scratch_rdy;
    
    // control output to systolic array
    logic           shift_en;
    logic           store_en;
    
    // from pixel_request to scratchpad
    logic    [19:0] req_addr       [16];
    logic     [4:0] sel_addr       [16];
    logic           valid_req_addr [16];
    
    // from scratchpad to systolic array
    logic     [7:0] req_data       [16];
    
    logic           last_pixel_out;
    logic           last_pixel_in;
    logic           valid_pixel_in;
    logic           valid_pixel_out;
    logic           new_pixel;
    logic           prev_pixel;

    controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .fifo_r_en(fifo_r_en),
        .fifo_r_accept(fifo_r_accept),
        .fifo_inst(fifo_inst),
        .row(row),
        .column(column),
        .width(width),
        .offset(offset),
        .filter_size(filter_size),
        .zero(zero),
        .load_en(load_en),
        .scratch_rdy(scratch_rdy),
        .shift_en(shift_en),
        .store_en(store_en),
        .valid_pixel(valid_pixel_in),
        .out_last(last_pixel_in),
        .in_last(last_pixel_out),
        .conv_done(conv_done)
    );
    
    inst_fifo inst_fifo(
        .clk(clk),
        .rst_n(rst_n),
        .in_inst(in_inst),
        .r_en(fifo_r_en),
        .r_accept(fifo_r_accept),
        .out_inst(fifo_inst)
    );
    
    pixel_request pixel_request(
        .in_row(row),// from controller
        .in_column(column), // from controller
        .in_width(width), // from controller
        .in_offset(offset), //from controller
        .in_filter_size(filter_size), //from controller
        .in_zero(zero), // from controller
        .out_req(req_addr),
        .out_sel(sel_addr),
        .out_valid_req(valid_req_addr)
    );
    
    scratchpad scratchpad(
        .clk(clk),
        .rst_n(rst_n),
        .out_req(r_addr),
        .in_data(r_data),
        .in_load_en(load_en),//from controller
        .in_req(req_addr),
        .in_sel(sel_addr),
        .in_valid_req(valid_req_addr),
        .in_filter_size(filter_size), //from controller
        .out_data(req_data),
        .out_valid_rdy(scratch_rdy) //to controller
    );
    
    sys_array sys_array(
        .clk(clk),
        .rst_n(rst_n),
        .shift_en(shift_en), //from controller
        .store_en(store_en), //from controller
        .in_x_buff(req_data),
        .in_valid_pixel(valid_pixel_in),
        .in_last(last_pixel_in),
        .out_accum(out_data),
        .out_valid_pixel(valid_pixel_out),
        .out_last(last_pixel_out),
        .out_new(new_pixel)
    );
    
    assign out_rdy = (valid_pixel_out & (prev_pixel^new_pixel)) ? 1 : 0;
    
    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            prev_pixel          <= '0;
        end
        else
        begin
            prev_pixel          <= new_pixel;
		end
	end
    
endmodule