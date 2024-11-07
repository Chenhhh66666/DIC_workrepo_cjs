//valid ready信号到handshake信号的桥接
`include "defines.sv"
module bridge (
    input logic clk,
    input logic rst,
    input logic en,

    input  logic                valid,
    output logic                ready,
    input  logic [`WIDTH-1 : 0] data_in,

    input  logic                ack,
    output logic                req,
    output logic [`WIDTH-1 : 0] data_out
);

    logic                wr_en;  //写使能
    logic                rd_en;  //读使能
    logic                full;  //满
    logic                empty;  //空
    logic [`WIDTH-1 : 0] fifo_data_in;
    logic [`WIDTH-1 : 0] fifo_data_out;

    syncfifo syncfifo_inst (
        .clk     (clk),
        .rst_n   (rst),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (fifo_data_in),
        .data_out(fifo_data_out),
        .full    (full),
        .empty   (empty)
        // .prog_full (prog_full),
        // .prog_empty(prog_empty)
    );

    //****************接收sender信号部分****************
    logic data_recv;  //收信号
    assign ready        = !full;
    assign data_recv    = ready & valid;
    assign wr_en        = data_recv;
    assign fifo_data_in = data_recv ? data_in : 'd0;  // 数据推到fifo，防止持续写入
    // typedef enum logic {
    //     RECV_IDLE = 1'b0,
    //     RECV_RECV = 1'b1
    // } state_recv;
    // state_recv c_recv_state, n_recv_state;
    // // 次态定义
    // always_comb begin : get_next_state
    //     case (c_recv_state)
    //         RECV_IDLE: n_recv_state = valid ? RECV_RECV : RECV_IDLE;
    //         RECV_RECV: n_recv_state = RECV_IDLE;
    //         default:   n_recv_state = RECV_IDLE;
    //     endcase
    // end
    // // 状态转移
    // always_ff @(posedge clk or negedge rst) begin : change_state
    //     if (!rst) c_recv_state <= RECV_IDLE;
    //     else c_recv_state <= n_recv_state;
    // end

    //***************发送receiver信号部分***************

    logic start_data;  //1则挂载数据在线上
    assign rd_en    = !empty & ack & req;
    assign data_out = req ? fifo_data_out : 'd0;

    typedef enum logic [1:0] {
        IDLE = 2'b00,  //req=0,ack=0
        // REQON = 2'b01,  //req=1,ack=0
        REQDOWN = 2'b10,  //req=1,ack=1
        STOP = 2'b11  //req=0,ack=0
    } state_send;
    state_send c_send_state, n_send_state;
    // 状态切换
    always_ff @(posedge clk or negedge rst) begin : send_data
        if (!rst) begin
            c_send_state <= IDLE;
        end else begin
            c_send_state <= n_send_state;
        end
    end
    // 次态定义
    // always_comb begin
    //     case (c_send_state)
    //         IDLE:    n_send_state = ack ? ACKON : IDLE;
    //         ACKON:   n_send_state = ACKDOWN;
    //         ACKDOWN: n_send_state = STOP;
    //         STOP:    n_send_state = IDLE;
    //         default: n_send_state = ACKDOWN;
    //     endcase
    // end
    // 输出
    always_comb begin
        case (c_send_state)
            IDLE: begin
                n_send_state = ack ? REQDOWN : IDLE;
                req          = empty ? 1'b0 : 1'b1;
                start_data   = 1'b1;
            end
            // REQON: begin
            //     n_send_state = ACKDOWN;
            //     req          = 1'b0;
            //     start_data   = 1'b0;
            // end
            REQDOWN: begin
                n_send_state = STOP;
                req          = 1'b0;
                start_data   = 1'b0;
            end
            STOP: begin
                n_send_state = IDLE;
                req          = 1'b0;
                start_data   = 1'b0;
            end
            default: begin
                n_send_state = REQDOWN;
                req          = 1'b0;
                start_data   = 1'b0;
            end
        endcase
    end
endmodule
