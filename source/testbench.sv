/*
 * testbench.sv
 * Author: William Bao
 * Last Revision: 03/06/19
 *
 * This testbench instantiates the convolution layer as a design under test 
 * and also an external memory for the convolution layer to fetch
 * data from.
 *
 */


`timescale 1 ns / 1 ps
`include "conv_top.svh"

module test();
  
    logic                            clk;
    logic                            rst_n;

    // instruction input
    logic                     [31:0] inst;
    
    // memory bus
    logic                     [19:0] r_addr;
    logic                    [255:0] r_data;

    // data output
    logic                      [7:0] out_data;
    logic                            out_rdy;
    
    // indicates a convolution is done
    logic                            conv_done;
    
    int                              file_in;
    int                              file_out;
    logic                      [7:0] data_expected;
    
    // debug counters
    longint                          pixel_count;
    longint                          clock_count;
    longint                          wrong_count;
  
    conv_top DUT(
        .clk(clk),
        .rst_n(rst_n),
        .in_inst(inst),
        .r_addr(r_addr),
        .r_data(r_data),
        .out_data(out_data),
        .out_rdy(out_rdy),
        .conv_done(conv_done)
    );
    
    hb_mem data_mem(
        .clk(clk),
        .r_addr(r_addr),
        .r_data(r_data)
    );
  
  always
  begin
    #1 clk = ~clk;
  end
  
    initial begin
    
        // Open data file and store into memory
        $readmemh("../model/hex/data.hex", data_mem.memory);
        
        // Initialize clock and perform a reset
        clk = 0; rst_n = 0; inst = '0;
        repeat (10) @(posedge clk);
        rst_n = 1;
        
        // Open instruction file and feed instructions
        file_in = $fopen("../model/hex/inst.hex", "r");
        if (file_in == 0) $error("No Instruction File Found");
        while($fscanf(file_in,"%h",inst) == 1) begin
            $display("Instruction : %h", inst);
            @(posedge clk);
        end
        $fclose(file_in);
        inst = '0;
        
        pixel_count = 0;
        clock_count = 0;
        wrong_count = 0;
        
        // Run until convolution is done
        file_in = $fopen("../model/hex/result_expected.hex", "r");
        if (file_in == 0) $error("No Expected Result File Found");
        file_out = $fopen("../model/hex/result.hex", "w");
        while (conv_done == 0)
            begin
            @(posedge clk);
            clock_count = clock_count + 1;
            if (out_rdy == 1)
            begin
                pixel_count = pixel_count + 1;
                $fwrite(file_out,"%h\n",out_data);
                $fscanf(file_in,"%h",data_expected);
                $display("Pixel#: %d, Result : %d %h, Expected: %d %h", pixel_count, out_data, out_data, data_expected, data_expected);
                if (out_data != data_expected)
                begin 
                    wrong_count = wrong_count + 1;
                    $stop; // comment this line out if you do not want the testbench to stop at every wrong pixel
                end
            end
        end
        $fclose(file_in);
        $fclose(file_out);
        // Show throughput
        $display("Pixels : %d", pixel_count);
        $display("Clocks : %d", clock_count);
        $display("Wrong  : %d", wrong_count);
        $stop;
    
    
    end
  
endmodule