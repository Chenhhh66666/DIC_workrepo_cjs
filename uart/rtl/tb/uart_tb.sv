`timescale 1ns / 1ps

module uart_tb;

    // 定义时钟频率和波特率等参数
    parameter CLK_FRE = 50_000_000;  // 50 MHz 时钟频率
    parameter BPS = 9600;  // 9600 波特率
    parameter WIDTH = 8;  // 数据宽度
    parameter PARITY = "NONE";  //是否需要校验位
    parameter BITDELAY = 1000_000_000 / BPS;  //

    // 信号声明
    reg        clk = 1'b0;  // 时钟信号
    reg        rst_n = 1'b1;  // 复位信号
    reg        uart_rx = 1'b1;  // UART接收信号
    wire       uart_tx;  // UART发送信号
    reg  [7:0] test_data = 8'ha5;  // 测试数据
    reg  [7:0] received_data = 'd0;  // 接收到的数据

    // 实例化 `uart_loopback` 模块
    uart #(
        .CLK_FRE(CLK_FRE),
        .BPS(BPS),
        .WIDTH(WIDTH),
        .PARITY(PARITY)
    ) uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // 时钟生成
    always #10 clk = ~clk;  // 50MHz, 周期 20ns

    // 初始化
    initial begin
        // 初始信号设置\
        rst_n = 1;
        #10000;
        rst_n = 0;
        #100;
        rst_n = 1;  // 释放复位
        #5000;
        send_uart_data(test_data);  // 模拟UART接收信号
        #10000;  // 等待数据发送与接收
        if (received_data == test_data) begin
            $display("Test Passed: Sent %h, Received %h", test_data, received_data);
        end else begin
            $display("Test Failed: Sent %h, but Received %h", test_data, received_data);
        end
        #(10 * BITDELAY);
        send_uart_data(8'b10101010);  // 模拟UART接收信号
        #10000;  // 等待数据发送与接收
        if (received_data == 8'b10101010) begin
            $display("Test Passed: Sent %h, Received %h", test_data, received_data);
        end else begin
            $display("Test Failed: Sent %h, but Received %h", test_data, received_data);
        end

        #(10 * BITDELAY);

        //$finish;
    end

    // 模拟UART发送过程
    task send_uart_data(input [7:0] data);
        uart_rx = 1'b0;
        #BITDELAY;  // 9600波特率, 对应一个位时间
        for (int i = 0; i < 8; i = i + 1) begin
            uart_rx = data[i];
            #BITDELAY;  // 每个数据位保持一个位时间
        end
        uart_rx = 1'b1;
        #BITDELAY;
    endtask

    // 捕获接收数据
    always_ff @(posedge uut.rx_done) begin
        received_data <= uut.rx_data;  // 从模块的输出获取接收到的数据
    end

endmodule
