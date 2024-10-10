module uart #(
    parameter CLK_FRE = 50_000_000,  // 时钟频率
    parameter BPS     = 9600,        // 波特率
    parameter PARITY  = "NONE",      // 奇偶校验
    parameter WIDTH   = 8            // 数据宽度
) (
                            input  logic clk,      // 时钟信号
                            input  logic rst_n,    // 复位信号
    (*MARK_DEBUG = "TRUE"*) input  logic uart_rx,  // UART接收信号
    (*MARK_DEBUG = "TRUE"*) output logic uart_tx   // UART发送信号
);

    // 内部信号定义
    (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] rx_data;  // 接收的数据
    // (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] fifo_data;  // 从FIFO读取的数据
    (*MARK_DEBUG = "TRUE"*) logic             rx_done;  // 接收完成标志
    (*MARK_DEBUG = "TRUE"*) logic             tx_start;  // 发送使能信号
    (*MARK_DEBUG = "TRUE"*) logic             tx_done;
    logic             data_error;

    (*MARK_DEBUG = "TRUE"*) logic             fifo_wr_en;  // FIFO写入使能
    (*MARK_DEBUG = "TRUE"*) logic             fifo_rd_en;  // FIFO读取使能
    (*MARK_DEBUG = "TRUE"*) logic             fifo_empty;  // FIFO空标志
    (*MARK_DEBUG = "TRUE"*) logic             fifo_full;  // FIFO满标志
    (*MARK_DEBUG = "TRUE"*) logic [WIDTH-1:0] fifo_out;  // FIFO输出数据
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
        .data_error(data_error)  // 忽略数据错误
    );


    txd #(
        .CLK_FREQUENCE(CLK_FRE),
        .BPS          (BPS),
        .PARITY_BIT   (PARITY),
        .FRAME_WD     (WIDTH)
    ) txd_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .frame_en  (tx_start),  // 启动发送
        .data_frame(fifo_out),  // 从FIFO读取的数据发送
        .tx_done   (tx_done),   // 忽略发送完成信号
        .uart_tx   (uart_tx)    // 发送数据到串口
    );

    //***************************FIFO控制逻辑**************************
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
