`timescale 1ns / 1ps
`include "defines.sv"
module syncfifo_tb;
    logic                clk = 1'b0;
    logic                rst_n = 1'b1;
    logic                wr_en = 1'b0;
    logic                rd_en = 1'b0;
    logic [`WIDTH-1 : 0] data_in = 'd0;
    logic [`WIDTH-1 : 0] data_out;
    logic                full = 1'b0;
    logic                empty = 1'b0;
    logic                full_th;
    logic                empty_th;

    syncfifo syncfifo_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (data_in),
        .data_out(data_out),
        .full    (full),
        .empty   (empty),
        .full_th (full_th),
        .empty_th(empty_th)
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
        wr_en <= 1'b1;
        rd_en <= 1'b1;
        data_in <= data;
        
    endtask  //automatic

    initial begin
        rst();
        //先写三个再读三个测试测试调试读写
        for (int i = 0; i < 512; i++) begin  //写数据进去
            wr_data(i);
        end
        wr_en = 1'b0;
        // for (int i = 0; i < 10; i++) begin  //写数据进去
        //     rd_data();
        // end
        // rd_en = 1'b0;
        #1000;
        for (int i = 0; i < 512; i++) begin  //写数据进去
            rd_data();
        end
        // wr_en = 1'b0;
        rd_en = 1'b0;
        #100;
    end
endmodule
