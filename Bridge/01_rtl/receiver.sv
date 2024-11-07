/*  4拍握手协议  */

`include "defines.sv"
module receiver (
    input  logic                clk,
    input  logic                rst,
    input  logic                en,
    input  logic [`WIDTH-1 : 0] data_in,
    input  logic                req,
    output logic                ack,
    output logic [`WIDTH-1 : 0] receive_data
);

    logic rece_data;
    assign rece_data    = ack & req;  //接收数据
    assign receive_data = rece_data ? data_in : 'd0;

    typedef enum logic {
        IDLE = 2'b00,  //req=0,ack=0
        ACKON = 2'b01  //req=1,ack=0
        // ACKDOWN = 2'b10,  //req=1,ack=1
        // ACKDOWN = 2'b11  //req=0,ack=0
    } state;
    state c_state, n_state;  //暂态，次态
    // 状态切换
    always_ff @(posedge clk) begin : state_Chaneg
        if (!rst) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end
    // 次态定义
    always_comb begin
        case (c_state)
            IDLE:    n_state = en ? (req ? ACKON : IDLE) : IDLE;
            ACKON:   n_state = req ? ACKON : IDLE;
            // ACKDOWN: n_state = IDLE;
            // ACKDOWN: n_state = IDLE;
            default: n_state = IDLE;
        endcase
    end
    // 输出
    always_comb begin
        case (c_state)
            IDLE:    ack = 1'b0;
            ACKON:   ack = 1'b1;
            // ACKDOWN: ack = 1'b0;
            // ACKDOWN: ack = 1'b0;
            default: ack = 1'b0;
        endcase
    end

endmodule
