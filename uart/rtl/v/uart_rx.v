module uart_rx #(
    parameter CLK_FRE     = 50,   //时钟频率
    parameter DATA_WIDTH  = 8,    //有效数据位宽
    parameter PARITY_ON   = 0,    //是否有校验位，1有0无
    parameter PARITY_TYPE = 0,    //校验类型，1奇0偶
    parameter BAUD_RATE   = 9600  //波特率，缺省则9600
) (
    input      i_clk_sys,    //系统时钟
    input      i_rst_n,      //全局异步复位
    input      i_uart_rx,    //uart输入
    output reg o_uart_data,  //uart接受数据
    output reg o_id_parity,  //校验位，高电平检验正确
    output reg o_rx_done     //接受数据完成标志
);

    reg sync_uart_rx;
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        begin
            if (!i_rst_n) sync_uart_rx <= 1'b0;
            else sync_uart_rx <= i_uart_rx;  //低电平有效
        end
    end

    reg  [4:0] r_flag_rcv_start;
    wire       w_rcv_start;
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        if (!i_rst_n) begin
            r_flag_rcv_start <= 5'b11111;  //异步复位把收到的起始位拉高，则没开始收信息
        end else begin
            r_flag_rcv_start <= {r_flag_rcv_start[3:0], sync_uart_rx};
        end
    end


    //定义状态机
    reg [2:0] r_current_state;  //当前状态
    reg [2:0] r_next_state;  //次态

    localparam STATE_IDLE = 3'b000;  //空闲状态
    localparam STATE_START = 3'b001;  //起始位状态
    localparam STATE_DATA = 3'b011;  //读数据状态
    localparam STATE_PARITY = 3'b100;  //校验状态
    localparam STATE_END = 3'b101;  //终止位状态

    localparam CYCLE = CLK_FRE * 1_000_000 / BAUD_RATE;  //波特计数周期,发送一个bit需要的周期数

    reg        baud_valid;  //波特计数有效位，1的时候可以计数，0的时候无效计数
    reg [15:0] baud_cnt;  //波特率计数器
    reg        baud_pulse;  //波特率采样脉冲

    reg [ 3:0] r_rcv_cnt;  //接收数据位计数

    //波特率计数器
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        if (!i_rst_n) baud_cnt <= 16'h0000;
        else if (!baud_valid) baud_cnt <= 16'h0000;
        else if (baud_cnt == CYCLE - 1) baud_cnt <= 16'h0000;
        else baud_cnt <= baud_cnt + 1;
    end

    //波特采样脉冲
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        if (!i_rst_n) baud_pulse <= 1'b0;
        else if (baud_cnt == CYCLE / 2 - 1) baud_pulse <= 1'b1;  //每个bit的中间采样一次
        else baud_pulse <= 1'b0;
    end

    //三段式状态机

    //状态机变化定义
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        if (!i_rst_n) r_current_state <= STATE_IDLE;
        else if (!baud_valid) r_current_state <= STATE_IDLE;
        else if (baud_valid && baud_cnt == 16'h0000) r_current_state <= r_next_state;
    end

    //状态机次态定义
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        case (r_current_state)
            STATE_IDLE:   r_next_state <= STATE_START;
            STATE_START:  r_next_state <= STATE_DATA;
            STATE_DATA: begin
                if (r_rcv_cnt == DATA_WIDTH) begin
                    if (PARITY_ON == 0) r_next_state <= STATE_END;  //不校验就直接进入停止位
                    else r_next_state <= STATE_PARITY;  //进入校验位
                end else begin
                    r_next_state <= STATE_DATA;  //没有接收完接着接收
                end
            end
            STATE_PARITY: r_next_state <= STATE_END;
            STATE_END:    r_next_state <= STATE_IDLE;
            default:      ;
        endcase
    end

    reg [DATA_WIDTH - 1 : 0] r_data_rcv;
    reg                      r_parity_check;

    //状态机输出逻辑
    always @(posedge i_clk_sys or negedge i_rst_n) begin
        if (!i_rst_n) begin  //异步复位全部初始化
            baud_valid     <= 1'b0;
            r_data_rcv     <= 'd0;  //不确定位宽但是全部置零
            r_rcv_cnt      <= 4'd0;
            r_parity_check <= 1'b0;
            o_uart_data    <= 'd0;
            o_id_parity    <= 1'b0;
            o_rx_done      <= 1'b0;
        end else
            case (r_current_state)  //根据不同状态决定输出
                STATE_IDLE: begin
                    //闲置状态下对寄存器进行复位
                    r_rcv_cnt      <= 4'b0;
                    r_data_rcv     <= 'd0;
                    r_parity_check <= 1'b0;
                    o_rx_done      <= 1'b0;
                    //连续检测到低电平时认为uart传来数据，拉高baud_valid,低电平可能意味着起始位接收到
                    if (r_flag_rcv_start == 5'b00000) baud_valid <= 1'b1;
                end
                STATE_START: begin
                    if (baud_pulse && sync_uart_rx) baud_valid <= 1'b0;
                end
                STATE_DATA: begin
                    if (baud_pulse) begin  //数据采样
                        r_data_rcv     <= {sync_uart_rx, r_data_rcv[DATA_WIDTH-1 : 1]};  //数据移位存储
                        r_rcv_cnt      <= r_rcv_cnt + 1'b1;  //数据为计数
                        r_parity_check <= r_parity_check + sync_uart_rx;  //数据位做加法验证1的奇偶
                    end
                end
                STATE_PARITY: begin
                    if (baud_pulse) begin  //采样到校验位
                        //校验检测，正确则o_id_parity拉高，可输出给led检测
                        if (r_parity_check ^ sync_uart_rx == PARITY_TYPE) o_id_parity <= 1'b1;
                        else o_id_parity <= 1'b0;
                    end else o_id_parity <= o_id_parity;
                end
                STATE_END: begin
                    if (baud_pulse) begin
                        begin
                            //没有校验位或者校验位正确时输出数据，否则直接丢弃
                            if (PARITY_ON == 0 || o_id_parity) begin
                                o_uart_data <= r_data_rcv;
                                o_rx_done   <= 1'b1;
                            end
                        end
                    end else begin
                        o_rx_done <= 1'b0;
                    end
                    if (baud_cnt == 16'h0000) baud_valid <= 1'b0;
                end
                default: ;
            endcase
    end

    //三段式状态机
endmodule
