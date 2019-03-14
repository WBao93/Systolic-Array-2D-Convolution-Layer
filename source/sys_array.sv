/*
 * sys_array.sv
 * Author: William Bao
 * Last Revision: 02/26/19
 *
 * sys_array assembles the pe's into a 16x16 systolic array and provides the output
 *
 */
`include "conv_top.svh"

module sys_array (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// control logic
	input logic                       shift_en,
	input logic                       store_en,
	
	// left input
	input logic unsigned             [7:0] in_x_buff [16],
    input logic                            in_valid_pixel,
    input logic                            in_last,

    // accumulation output
    output logic unsigned            [7:0] out_accum,
    output logic                           out_valid_pixel,
    output logic                           out_last,
    output logic                           out_new
);


    logic unsigned        [7:0] in_x  [16][16];
    logic unsigned        [7:0] out_x [16][16];
    logic signed         [19:0] in_y  [16][16];
    logic signed         [19:0] out_y [16][16];
	logic signed         [23:0] accum;
    
    logic                       valid_pixel [31];
    logic                       last        [31];
	
	assign accum =  out_y[0][15] +  out_y[1][15] +  out_y[2][15] +  out_y[3][15]
                 +  out_y[4][15] +  out_y[5][15] +  out_y[6][15] +  out_y[7][15]
                 +  out_y[8][15] +  out_y[9][15] + out_y[10][15] + out_y[11][15]
                 + out_y[12][15] + out_y[13][15] + out_y[14][15] + out_y[15][15];
    
    assign out_valid_pixel = valid_pixel[30];
    assign out_last        = last[30];
                     
    always_comb
    begin
        for(int i=0; i<16; i++)
		begin
			for(int j=0; j<(16-1); j++)
			begin
				in_y[i][j+1] = out_y[i][j]; //directly connect sum outputs to inputs
			end
			in_y[i][0] = 0;
		end
    end
    
    genvar n;
    genvar m;
    
	generate
        for(n=0; n<16; n++)
		begin: valid_pixel_coord
            pe in_mac (
					.clk(clk), 
					.rst_n(rst_n), 
					.shift_en(shift_en), 
					.store_en(store_en), 
					.in_x(in_x_buff[n]),
					.out_x(out_x[n][0]),
					.in_y(in_y[n][0]),
					.out_y(out_y[n][0])
				);
			for(m=1; m<16; m++)
			begin: col_coord
				pe mac (
					.clk(clk), 
					.rst_n(rst_n), 
					.shift_en(shift_en), 
					.store_en(store_en), 
					.in_x(in_x[n][m]),
					.out_x(out_x[n][m]),
					.in_y(in_y[n][m]),
					.out_y(out_y[n][m])
				);
			end
		end
    endgenerate

    

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
            out_new = 0;
			for(int i=0; i<16; i++)
			begin
				for(int j=0; j<(16-1); j++)
					in_x[i][j+1] <= 0;
			end
            for(int i=0; i<31; i++)
			begin
				valid_pixel[i] <= 0;
                last[i]        <= 0;
			end
		end
		else
		begin
			if (shift_en)
			begin
                out_new = ~out_new;
				for(int i=0; i<16; i++)
				begin
					for(int j=0; j<(16-1); j++)
						in_x[i][j+1] <= out_x[i][j];
				end
                valid_pixel[0] <= in_valid_pixel;
                last[0]        <= in_last;
                for(int i=0; i<31; i++)
				begin
					valid_pixel[i+1] <= valid_pixel[i];
                    last[i+1]        <= last[i];
				end
			end
		end
	end
    
    // This section clamps the output of the systolic array and provides rounding as well
    always_comb
	begin
		if(accum[23] == 1)
		begin
			out_accum = 8'b00000000;
		end
		else if ((accum[22:11] != 0) || (accum[10:3] == 8'b11111111))
		begin
            out_accum = 8'b11111111;
        end
        else
        begin
            if (accum[2:0] >= 4)
            begin
                out_accum = accum[10:3] + 1;
            end
            else
            begin
                out_accum = accum[10:3];
            end
        end
	end
endmodule