`include "defines.sv"
module sender (
    input  logic                ready,
    input  logic                clk,
    input  logic                rst,
    // input  logic [`WIDTH-1 : 0] data_in,
    input  logic                en,
    output logic [`WIDTH-1 : 0] data_out,
    output logic                valid
);
    // logic [`WIDTH-1 : 0] random_data;
    // logic                send_over;  // 发送完成的信号
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        WAIT_READY = 2'b01,
        WAIT_VALID = 2'b10,
        SEND_DATA = 2'b11
    } send_state;
    send_state current_state, next_state;
    // 状态转移逻辑
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    // 次态和输出逻辑
    always_comb begin
        case (current_state)
            IDLE: begin
                valid = 0;
                if (en) begin
                    next_state = WAIT_READY;
                end else begin
                    next_state = IDLE;
                end
            end
            WAIT_READY: begin
                valid = 1;
                // data_out   = $random();  // 挂着信号
                if (ready) begin
                    next_state = SEND_DATA;
                end else begin
                    next_state = WAIT_READY;
                end
            end
            WAIT_VALID: begin
                valid = 0;
                if (ready) begin
                    next_state = SEND_DATA;
                end else begin
                    next_state = WAIT_VALID;
                end
            end
            SEND_DATA: begin
                valid      = 0;
                next_state = IDLE;
            end
            default: begin
                valid      = 0;
                next_state = IDLE;
            end
        endcase
    end

    assign data_out = valid ? $random() : 'd0;
endmodule
