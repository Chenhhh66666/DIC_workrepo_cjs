`timescale 1ns / 1ps

module txd_clk_tb;

reg         clk;        // 输入时钟
reg         rst_n;      // 异步复位信号
reg         tx_done;    // 发送完成信号
reg         tx_start;   // 发送开始信号
wire        bps_clk;    // 产生的波特率时钟

// 时钟生成
initial begin
    clk = 1;
    forever #10 clk = ~clk; // 50MHz 时钟
end

// 复位信号生成
initial begin
    rst_n = 1'b0;
    #15 rst_n = 1'b1; // 复位持续15ns
end

// 测试信号生成
initial begin
    tx_done = 1'b0;
    tx_start = 1'b0;

    // 启动发送
    #30 tx_start = 1'b1; // 发送开始信号
    #20 tx_start = 1'b0; // 停止发送开始信号

    // 模拟发送完成
    #100 tx_done = 1'b1; // 发送完成信号
    #20 tx_done = 1'b0;  // 重置发送完成信号

    // 结束仿真
    #200 $finish;
end

// 实例化 txd_clk 模块
txd_clk #(
    .CLK_FRE   (50_000_000), // 默认 50M 时钟频率
    .BAUD_RATE (9600)         // 默认 9600 波特率
) txd_clk_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    .tx_done  (tx_done),
    .tx_start (tx_start),
    .bps_clk  (bps_clk)
);

// VCD 文件生成
initial begin
    $dumpfile("txd_clk_tb.vcd");
    $dumpvars();
end

endmodule
