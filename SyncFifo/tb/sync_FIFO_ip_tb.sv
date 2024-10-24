`timescale 1ns / 1ps
`include "defines.sv"
module sync_FIFO_ip_tb;
    logic                clk = 1'b0;
    logic                rst_n = 1'b1;
    logic                wr_en = 1'b0;
    logic                rd_en = 1'b0;
    logic [`WIDTH-1 : 0] data_in = 'd0;
    logic [`WIDTH-1 : 0] data_out;
    logic                full;
    logic                empty;
    logic                prog_empty;
    logic                prog_full;

    sync_fifo your_instance_name (
        .clk       (clk),        // input wire clk
        .srst      (~rst_n),      // input wire srst
        .din       (data_in),    // input wire [31 : 0] din
        .wr_en     (wr_en),      // input wire wr_en
        .rd_en     (rd_en),      // input wire rd_en
        .dout      (data_out),   // output wire [31 : 0] dout
        .full      (full),       // output wire full
        .empty     (empty),      // output wire empty
        .prog_full (prog_full),  // output wire prog_full
        .prog_empty(prog_empty)  // output wire prog_empty
    );

    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    task automatic rst();
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1;
        #30;
    endtask  //automatic

    task automatic wr_data(input logic [`WIDTH-1 : 0] data);
        @(posedge clk);
        wr_en   <= 1'b1;  //拉高
        data_in <= data;
    endtask  //automatic

    task automatic rd_data();
        @(posedge clk);
        rd_en <= 1'b1;

    endtask  //automatic

    task automatic wr_rd(input logic [`WIDTH-1 : 0] data);
        @(posedge clk);
        wr_en   <= 1'b1;
        rd_en   <= 1'b1;
        data_in <= data;

    endtask  //automatic

    initial begin
        rst();
        //先写三个再读三个测试测试调试读写
        for (int i = 0; i < 513; i++) begin  //写数据进去
            wr_data(i);
        end
        wr_en = 1'b0;
        // for (int i = 0; i < 10; i++) begin  //写数据进去
        //     rd_data();
        // end
        // rd_en = 1'b0;
        #1000;
        for (int i = 0; i < 20; i++) begin  //写数据进去
            rd_data();
        end
        rd_en = 1'b0;
        #1000;
        for (int i = 0; i < 100; i++) begin  //写数据进去
            rd_data();
        end
        // wr_en = 1'b0;
        rd_en = 1'b0;
        #100;
    end
endmodule
