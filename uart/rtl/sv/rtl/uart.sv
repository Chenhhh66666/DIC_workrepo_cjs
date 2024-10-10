module uart #(
    parameter CLK_FRE = 50_000_000,  // ʱ��Ƶ��
    parameter BPS     = 9600,        // ������
    parameter PARITY  = "NONE",      // ��żУ��
    parameter WIDTH   = 8            // ���ݿ��
) (
                            input  logic clk,      // ʱ���ź�
                            input  logic rst_n,    // ��λ�ź�
    (*MARK_DEBUG = "TRUE"*) input  logic uart_rx,  // UART�����ź�
    (*MARK_DEBUG = "TRUE"*) output logic uart_tx   // UART�����ź�
);

    // �ڲ��źŶ���
    (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] rx_data;  // ���յ�����
    // (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] fifo_data;  // ��FIFO��ȡ������
    (*MARK_DEBUG = "TRUE"*) logic             rx_done;  // ������ɱ�־
    (*MARK_DEBUG = "TRUE"*) logic             tx_start;  // ����ʹ���ź�
    (*MARK_DEBUG = "TRUE"*) logic             tx_done;
    logic             data_error;

    (*MARK_DEBUG = "TRUE"*) logic             fifo_wr_en;  // FIFOд��ʹ��
    (*MARK_DEBUG = "TRUE"*) logic             fifo_rd_en;  // FIFO��ȡʹ��
    (*MARK_DEBUG = "TRUE"*) logic             fifo_empty;  // FIFO�ձ�־
    (*MARK_DEBUG = "TRUE"*) logic             fifo_full;  // FIFO����־
    (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] fifo_out;  // FIFO�������
    logic             wr_ack;

    rxd #(
        .CLK_FREQUENCE(CLK_FRE),
        .BPS          (BPS),
        .PARITY       (PARITY),
        .WIDTH        (WIDTH)
    ) rxd_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .uart_rx   (uart_rx),
        .rx_done   (rx_done),
        .rx_data   (rx_data),
        .data_error(data_error)  // �������ݴ���
    );


    txd #(
        .CLK_FREQUENCE(CLK_FRE),
        .BPS          (BPS),
        .PARITY_BIT   (PARITY),
        .FRAME_WD     (WIDTH)
    ) txd_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .frame_en  (tx_start),  // ��������
        .data_frame(fifo_out),  // ��FIFO��ȡ�����ݷ���
        .tx_done   (tx_done),   // ���Է�������ź�
        .uart_tx   (uart_tx)    // �������ݵ�����
    );

    //***************************FIFO�����߼�**************************
    assign fifo_wr_en = !fifo_full & rx_done;
    assign fifo_rd_en = wr_ack & !fifo_empty;
    assign tx_start   = fifo_rd_en;

    // fifo_generator_0 your_instance_name (
    //     .clk   (clk),         // input wire clk
    //     .srst  (!rst_n),      // input wire srst
    //     .din   (rx_data),     // input wire [7 : 0] din
    //     .wr_en (fifo_wr_en),  // input wire wr_en
    //     .rd_en (fifo_rd_en),  // input wire rd_en
    //     .dout  (fifo_out),    // output wire [7 : 0] dout
    //     .full  (fifo_full),   // output wire full
    //     .wr_ack(wr_ack),      // output wire wr_ack
    //     .empty (fifo_empty)   // output wire empty
    //     //   .valid(valid)    // output wire valid
    // );
    fifo_generator_0 your_instance_name (
        .clk   (clk),         // input wire clk
        .srst  (!rst_n),      // input wire srst
        .din   (rx_data),     // input wire [7 : 0] din
        .wr_en (fifo_wr_en),  // input wire wr_en
        .rd_en (fifo_rd_en),  // input wire rd_en
        .dout  (fifo_out),    // output wire [7 : 0] dout
        .full  (fifo_full),   // output wire full
        .wr_ack(wr_ack),      // output wire wr_ack
        .empty (fifo_empty)   // output wire empty
        // .valid (valid)        // output wire valid
    );
endmodule
