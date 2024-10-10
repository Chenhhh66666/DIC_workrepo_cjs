`timescale 1ns / 1ps

module rxd_tb;
    parameter CLK_FREQUENCE = 50_000_000;
    parameter BPS = 9600;
    parameter PARITY = "NONE";
    parameter WIDTH = 8;
    parameter DATA_DELAY = 1_000_000_000/BPS;

    logic               clk = 'd0;
    logic               rst_n = 'd1;
    logic               uart_rx = 'd1;
    logic               rx_done = 'd0;
    logic [WIDTH-1 : 0] rx_data = 'd0;
    logic               data_error = 'd0;

    task send_data([WIDTH-1 : 0] data);
        begin
            uart_rx = 1'b0;
            #DATA_DELAY;
            for(int i = 0; i<WIDTH; i++) begin
                uart_rx = data[i];
                #DATA_DELAY;
            end
            uart_rx = 1'b1;
            #DATA_DELAY;
        end
    endtask

    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;  //50M时钟
    end

    //测试向量
    initial begin
        rst_n = 1'b0;
        # 30;
        rst_n = 1'b1;
        #20 
        uart_rx =1'b1;
        #DATA_DELAY;
        send_data(8'b10010110);

    end

    rxd #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BPS(BPS),
        .PARITY(PARITY),
        .WIDTH(WIDTH)
    ) rxd_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .uart_rx   (uart_rx),
        .rx_done   (rx_done),
        .rx_data   (rx_data),
        .data_error(data_error)
    );

endmodule
