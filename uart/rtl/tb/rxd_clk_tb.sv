`timescale 1ns / 1ps

module rxd_clk_tb;

    parameter CLK_FREQUENCE = 50_000_000;
    parameter BPS = 9600;

    logic clk = 1'b0;
    logic rst_n = 1'b1;
    logic rx_start = 1'b0;
    logic rx_done = 1'b0;
    logic sample_clk = 1'b0;

    //时钟生成
    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;  //50M时钟
    end

    //生成测试向量
    initial begin
        rx_done = 1'b0;
        rx_start = 1'b0;
        rst_n = 1'b0;
        #15 rst_n = 1'b1;
        //复位

        //启动接收
        #30 rx_start = 1'b1;
        #20 rx_start = 1'b0;

        //接收完成
        #100 rx_done = 1'b1;
        #20 rx_done = 1'b0;




    end
    



    rxd_clk #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BPS(BPS)
    ) rxd_clk_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx_start  (rx_start),
        .rx_done   (rx_done),
        .sample_clk(sample_clk)
    );

endmodule
