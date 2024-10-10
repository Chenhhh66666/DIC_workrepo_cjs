`timescale 1ns / 1ps

module rxd_clk #(
    parameter CLK_FREQUENCE = 50_000_000,  //默认时钟
    parameter BPS           = 9600         //波特率
) (
    input  logic clk,
    input  logic rst_n,      //全局异步复位
    input  logic rx_start,   //开始接收
    input  logic rx_done,    //接收完成
    output logic sample_clk  //采样时钟
);
    localparam SMP_CLK_CNT = (CLK_FREQUENCE / (BPS*9))  - 1;  //1bit采样九次
    localparam CNT_WIDTH = $clog2(SMP_CLK_CNT);  //计数位宽

    logic [CNT_WIDTH-1 : 0] clk_count;

    typedef enum logic [1:0] {
        IDLE,
        RECEIVE
    } state;

    state current_state, next_state;  //暂态和次态
    //状态转移逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end
    //次态逻辑
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE:    next_state = rx_start ? RECEIVE : IDLE;
            RECEIVE: next_state = rx_done ? IDLE : RECEIVE;
            default: next_state = IDLE;
        endcase
    end
    //输出逻辑

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_count <= '0;
        else begin
            case (current_state)
                IDLE:    clk_count <= '0;
                RECEIVE: clk_count <= clk_count == SMP_CLK_CNT ? '0 : clk_count + 1'b1;
                default: clk_count <= '0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk <= 1'b0;  //复位
        else if (clk_count == SMP_CLK_CNT) sample_clk <= 1'b1;  //计满采样
        else sample_clk <= 1'b0;
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
