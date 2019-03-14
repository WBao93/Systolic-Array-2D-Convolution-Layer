/*
 * filter_buffer.sv
 * Author: William Bao
 * Last Revision: 02/26/19
 *
 * This is the instruction FIFO. 
 * It is 8-deep (default), synchronous write, and asynchronous read
 *
 */
`include "conv_top.svh"

module inst_decoder (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Write side
    input  logic        [31:0] in_inst,
    input  logic               r_accept,
    
    output logic        [19:0] filter_offset,
    output logic         [3:0] filter_size,
    output logic         [3:0] filter_num,
    
    output logic        [19:0] img_offset,
    output logic        [11:0] img_height,
    output logic        [11:0] img_width,

    output logic         [3:0] inst_flag,
    input  logic               conv_done
);

    always_ff @(posedge clk or negedge rst_n)
    begin
        if(~rst_n)
        begin
            filter_offset <= '0;
            filter_size   <= '0;
            filter_num    <= '0;
            img_offset    <= '0;
            img_height    <= '0;
            img_width     <= '0;
            inst_flag     <= '0;
        end
        else
        begin
            if (r_accept)
            begin
                if (in_inst[31:28] == `OP_LF)
                begin
                    filter_size   <= in_inst[27:24];
                    filter_num    <= in_inst[23:20];
                    filter_offset <= in_inst[19:0];
                    inst_flag[0]  <= 1'b1;
                end
                else if (in_inst[31:28] == `OP_LS)
                begin
                    img_height    <= in_inst[23:12];
                    img_width     <= in_inst[11:0];
                    inst_flag[1]  <= 1'b1;
                end
                else if (in_inst[31:28] == `OP_LI)
                begin
                    img_offset    <= in_inst[19:0];
                    inst_flag[2]  <= 1'b1;
                end
                else if (in_inst[31:28] == `OP_DC)
                begin
                    inst_flag[3]  <= 1'b1;
                end
            end
            else if (conv_done)
            begin
                inst_flag[3]  <= 1'b0;
            end
		end
	end

endmodule