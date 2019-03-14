/*
 * scratchpad.sv
 * Author: William Bao
 * Last Revision: 03/03/19
 *
 * This is a scratchpad for the layer. It is a fully associative cache that can
 * handle 16 requests and also prefetch memory lines
 *
 */
`include "conv_top.svh"

module scratchpad (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // connection to memory module
    output logic        [19:0] out_req,
    input  logic       [255:0] in_data,

    // input control signals
    input  logic               in_load_en, //master enable for all loads
    input  logic        [19:0] in_req        [16],
    input  logic         [4:0] in_sel        [16],
    input  logic               in_valid_req  [16],
    input  logic         [3:0] in_filter_size,

    // output data and control
    output logic         [7:0] out_data      [16],
    output logic               out_valid_rdy
);

    logic   [31:0][7:0] data_sliced;
    
    // request management
    logic        [19:0] req       [16];
    logic         [4:0] sel       [16];
    logic   [31:0][7:0] req_data  [16];
    logic        [15:0] req_rdy;
    logic        [15:0] valid_rdy;
    logic               hold_req;

    // memory management
    logic         [3:0] kick_ptr;
    logic   [31:0][7:0] scratch   [16];
    logic        [19:0] tag       [16];
    logic               keep      [16];
    logic               valid     [16];
    
    // state machine
    logic         [1:0] state;
    logic         [1:0] next_state;
    logic         [7:0] delay_counter;
    localparam IDLE  = 2'b00;
    localparam WAIT  = 2'b01;
    localparam SAVE  = 2'b10;

    assign out_valid_rdy = (valid_rdy == '1) ? 1 : 0;
    
    genvar n;
    
    generate
        for(n=0; n<32; n++)
        begin:slice
            assign data_sliced[n] = in_data[((n+1)*8-1):(n*8)];
        end
    endgenerate
    
    always_comb
    begin
        for(int i=0; i<16; i++)
        begin
            if(in_valid_req[i])
            begin
                sel[i] = in_sel[i];
                req[i] = in_req[i];
                out_data[i] = req_data[i][(sel[i])];
            end
            else
            begin
                sel[i] = 4'b0000;
                // prefetch next line
                // caution: this section will generate inferred WAITes
                for (int j=0; j<i; j++)
                begin
                    if (in_filter_size == j)
                    begin
                        req[i] = req[i-(j+1)] + 1;
                    end
                end
                out_data[i] = 8'b00000000;
            end
        end
    end
    
    // determine which scratchpad entries must be kept
    always_comb
    begin
        for(int i=0; i<16; i++)
        begin
            keep[i] = 0;
            for(int j=0; j<16; j++)
            begin
                if ((tag[i] == req[j]) && (valid[i] == 1))
                begin
                    keep[i] = 1;
                end
            end
        end
    end
    
    //generate kick pointer
    always_comb
    begin
        kick_ptr = '0;
        for(int i=15; i>=0; i--)
        begin
            if(keep[i] == 0)
            begin
                kick_ptr = i;
            end
        end
    end
    
    //generate request ready and fetch ready data from a request
    always_comb
    begin
        for(int i=0; i<16; i++)
        begin
            req_data[i] = 256'bx;
            req_rdy[i] = 0;
            for(int j=0; j<16; j++)
            begin
                if ((tag[j] == req[i]) && (valid[j] == 1))
                begin
                    req_data[i] = scratch[j];
                    req_rdy[i] = 1;
                end 
            end
        end
    end
    
    //generate valid request ready 
    always_comb
    begin
        for(int i=0; i<16; i++)
        begin
            if (!((in_valid_req[i] == 1) && (req_rdy[i] == 0)))
            begin
                valid_rdy[i] = 1;
            end
            else
            begin
                valid_rdy[i] = 0;
            end
        end
    end
    
    //output a latched request to memory
    always_latch
    begin
        if (hold_req)
        begin
            out_req = out_req;
        end
        else
        begin
            for(int i=15; i>=0; i--)
            begin
                if (req_rdy[i] == 0)
                begin
                    out_req = req[i];
                end
            end
        end
    end
    
    //state machine combinational logic
    always_comb
    begin
        if (state == IDLE)
        begin
            hold_req = 0; 
            if ((req_rdy != '1) && (in_load_en == 1))
            begin
                next_state = WAIT;
            end
            else
            begin
                next_state = IDLE;
            end
        end
        else if (state == WAIT)
        begin
            hold_req = 1; 
            if (delay_counter >= `MEM_DELAY)
            begin
                next_state = SAVE;
            end
            else
            begin
                next_state = WAIT;
            end
        end
        else //state == SAVE
        begin
            hold_req = 1; 
            next_state = IDLE;
        end
    end

    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            valid         <= '{default:0};
            state         <= IDLE;
            delay_counter <= 0;
        end
        else
        begin
            state <= next_state;
            if (state == WAIT)
            begin
                delay_counter      <= delay_counter + 1;
            end
            if (state == SAVE)
            begin
                delay_counter      <= 0;
                scratch[kick_ptr]  <= data_sliced;
                tag[kick_ptr]      <= out_req;
                valid[kick_ptr]    <= 1;
            end
		end
	end

endmodule