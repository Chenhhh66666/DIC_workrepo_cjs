`timescale 1ns / 1ps

module uart_tb;

    // ����ʱ��Ƶ�ʺͲ����ʵȲ���
    parameter CLK_FRE = 50_000_000;  // 50 MHz ʱ��Ƶ��
    parameter BPS = 9600;  // 9600 ������
    parameter WIDTH = 8;  // ���ݿ��
    parameter PARITY = "NONE";  //�Ƿ���ҪУ��λ
    parameter BITDELAY = 1000_000_000 / BPS;  //

    // �ź�����
    reg        clk = 1'b0;  // ʱ���ź�
    reg        rst_n = 1'b1;  // ��λ�ź�
    reg        uart_rx = 1'b1;  // UART�����ź�
    wire       uart_tx;  // UART�����ź�
    reg  [7:0] test_data = 8'ha5;  // ��������
    reg  [7:0] received_data = 'd0;  // ���յ�������

    // ʵ���� `uart_loopback` ģ��
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

    // ʱ������
    always #10 clk = ~clk;  // 50MHz, ���� 20ns

    // ��ʼ��
    initial begin
        // ��ʼ�ź�����\
        rst_n = 1;
        #10000;
        rst_n = 0;
        #100;
        rst_n = 1;  // �ͷŸ�λ
        #5000;
        send_uart_data(test_data);  // ģ��UART�����ź�
        #10000;  // �ȴ����ݷ��������
        if (received_data == test_data) begin
            $display("Test Passed: Sent %h, Received %h", test_data, received_data);
        end else begin
            $display("Test Failed: Sent %h, but Received %h", test_data, received_data);
        end
        #(10 * BITDELAY);
        send_uart_data(8'b10101010);  // ģ��UART�����ź�
        #10000;  // �ȴ����ݷ��������
        if (received_data == 8'b10101010) begin
            $display("Test Passed: Sent %h, Received %h", test_data, received_data);
        end else begin
            $display("Test Failed: Sent %h, but Received %h", test_data, received_data);
        end

        #(10 * BITDELAY);

        //$finish;
    end

    // ģ��UART���͹���
    task send_uart_data(input [7:0] data);
        uart_rx = 1'b0;
        #BITDELAY;  // 9600������, ��Ӧһ��λʱ��
        for (int i = 0; i < 8; i = i + 1) begin
            uart_rx = data[i];
            #BITDELAY;  // ÿ������λ����һ��λʱ��
        end
        uart_rx = 1'b1;
        #BITDELAY;
    endtask

    // �����������
    always_ff @(posedge uut.rx_done) begin
        received_data <= uut.rx_data;  // ��ģ��������ȡ���յ�������
    end

endmodule
