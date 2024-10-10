`timescale 1ns / 1ps

module txd #(
    parameter CLK_FREQUENCE = 50_000_000,
    parameter BPS           = 9600,        //9600,19200,38400……
    parameter PARITY_BIT    = "NONE",      //校验位，奇校验，偶校验，无校验
    parameter FRAME_WD      = 8            //位宽5~8
) (
    input  logic                  clk,         //时钟信号
    input  logic                  rst_n,       //复位信号
    input  logic                  frame_en,    //发送使能
    input  logic [FRAME_WD-1 : 0] data_frame,  //发送的数据
    output logic                  tx_done,     //发送完成
    output logic                  uart_tx      //连接发送端
);

    logic bps_clk;

    txd_clk #(
        .CLK_FRE  (CLK_FREQUENCE),
        .BAUD_RATE(BPS)
    ) txd_clk_inst (
        .clk     (clk),
        .rst_n   (rst_n),
        .tx_done (tx_done),
        .tx_start(frame_en),
        .bps_clk (bps_clk)
    );

    typedef enum logic [2:0] {
        IDLE,
        READY,
        START_BIT,
        SHIFT_PRO,
        PARITY,
        STOP,
        DONE
    } STATE_TX;

    STATE_TX current_state, next_state;  //暂态，次态

    logic [        FRAME_WD-1 : 0] reg_data;  // 数据位宽
    logic [log2(FRAME_WD-1)-1 : 0] data_cnt;  //发送计数
    logic                          parity_bit;  //校验位

    logic [                 1 : 0] verify_mode;
    generate
        if (PARITY == "ODD") assign verify_mode = 2'b01;
        else if (PARITY == "EVEN") assign verify_mode = 2'b10;
        else assign verify_mode = 2'b00;
    endgenerate



    //发送数据时的计数逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) data_cnt <= 'b0;
        else if (current_state == SHIFT_PRO & bps_clk == 1'b1)
            if (data_cnt == FRAME_WD - 1) data_cnt <= 'd0;
            else data_cnt <= data_cnt + 1'b1;
        else data_cnt <= data_cnt;
    end
    //状态切换逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;  //异步复位
        else current_state <= next_state;  //切换状态
    end
    //次态逻辑
    always_comb begin
        case (current_state)
            IDLE:      next_state = frame_en ? READY : IDLE;  //按照设定波特率执行
            READY:     next_state = bps_clk ? START_BIT : READY;  //波特率脉冲到来，切换状态
            START_BIT: next_state = bps_clk ? SHIFT_PRO : START_BIT;
            SHIFT_PRO: next_state = (data_cnt == FRAME_WD - 1 & bps_clk == 1'b1) ? PARITY : SHIFT_PRO;
            PARITY:    next_state = bps_clk ? STOP : PARITY;  //校验位结束
            STOP:      next_state = bps_clk ? DONE : STOP;  //终止位发送结束
            DONE:      next_state = IDLE;  //回到空闲状态
            default:   next_state = IDLE;
        endcase
    end
    //状态输出逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_data   <= 'd0;
            uart_tx    <= 1'b1;  //保持拉高证明空闲
            tx_done    <= 1'b0;
            parity_bit <= 1'b0;
        end else begin
            case (next_state)  //时钟上升沿之后更新状态
                IDLE: begin
                    reg_data <= 'b0;
                    tx_done  <= 1'b0;
                    uart_tx  <= 1'b1;  //拉高,空闲状态
                end
                READY: begin
                    reg_data <= 'b0;
                    tx_done  <= 1'b0;
                    uart_tx  <= 1'b1;  //拉高,空闲状态
                end
                START_BIT: begin

                    reg_data   <= data_frame;  //准备数据
                    parity_bit <= ^data_frame;  //准备校验位，1的个数为奇数返回1
                    uart_tx    <= 1'b0;  //拉低进入起始位
                    tx_done = 1'b0;
                end
                SHIFT_PRO: begin
                    if (bps_clk) begin
                        reg_data <= {1'b0, reg_data[FRAME_WD-1 : 1]};  //高位填零，数据移至低位发送
                        uart_tx  <= reg_data[0];
                    end else begin
                        //bpsclk没到来的时候保持不变
                        reg_data <= reg_data;
                        uart_tx  <= uart_tx;
                    end
                    tx_done <= 1'b0;
                end
                PARITY: begin
                    reg_data <= reg_data;
                    tx_done  <= 1'b0;
                    case (verify_mode)
                        2'b00:   uart_tx <= 1'b1;  //若无校验多发一位STOP_BIT
                        2'b01:   uart_tx <= ~parity_bit;
                        2'b10:   uart_tx <= parity_bit;
                        default: uart_tx <= 1'b1;
                    endcase
                end
                STOP: begin
                    uart_tx <= 1'b1;
                end
                DONE: begin
                    tx_done <= 1'b1;  //拉高停止
                end
                default: begin
                    reg_data   <= 'b0;
                    uart_tx    <= 1'b1;  //默认拉高
                    tx_done    <= 1'b0;
                    parity_bit <= 1'b0;
                end
            endcase
        end
    end

    //定义对数函数
    function integer log2(input integer v);
        begin
            log2 = 0;
            while (v >> log2) begin
                log2 = log2 + 1;  //不断右移动直至为0
            end
        end
    endfunction

endmodule
