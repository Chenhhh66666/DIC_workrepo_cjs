`timescale 1ns / 1ps

module txd_clk #(
    parameter CLK_FRE   = 50_000_000,  //默认50M时钟频率
    parameter BAUD_RATE = 9600         //默认9600波特率
) (
    input  logic clk,       //输入时钟
    input  logic rst_n,     //异步低电平有效复位
    input  logic tx_done,   //发送完成信号
    input  logic tx_start,  //发送开始信号
    output logic bps_clk    //产生每个bit发送的时钟，控制系统随设置好的波特率运行
);
    localparam BPS_CNT = CLK_FRE / BAUD_RATE - 1;  //每个01信号发送消耗周期数
    localparam BPS_WIDTH = log2(BPS_CNT);  //计数周期数所需位宽

    logic [BPS_WIDTH-1 : 0] count;
    // //定义状态机
    typedef enum logic {
        IDLE = 1'b0,
        SEND_DATA = 1'b1
    } state;

    state current_state, next_state;  //当前状态和下一个状态
    //状态转移逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end
    //次态逻辑
    always_comb begin
        case (current_state)
            IDLE:      next_state = tx_start ? SEND_DATA : IDLE;  //开始发送，跳转下一个状态
            SEND_DATA: next_state = tx_done ? IDLE : SEND_DATA;  //发送完成，回到IDLE 
            default:   next_state = IDLE;
        endcase
    end
    //状态输出逻辑
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= 'b0;  //异步复位
        else if (current_state == IDLE) count <= {BPS_WIDTH{1'b0}};
        else begin
            if (count == BPS_CNT) count <= {BPS_WIDTH{1'b0}};
            else count <= count + 1;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) bps_clk <= 1'b0;
        else if (count == 'd1) bps_clk <= 1'b1;
        else bps_clk <= 1'b0;
    end

    //定义对数函数
    function integer log2(input integer v);
        begin
            log2 = 0;
            while (v >> log2) log2 = log2 + 1;  //不断右移动直至为0
        end
    endfunction

endmodule
