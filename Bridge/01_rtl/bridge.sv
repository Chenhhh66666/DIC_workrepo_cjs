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

    //***************发送receiver信号部分***************
    assign data_out = (req & ack) ? fifo_data_out : 'd0;

    typedef enum logic [1:0] {
        IDLE = 2'b00,  //req=0,ack=0
        READFIFO = 2'b01,  //读数据
        REQON = 2'b10,  //req=1,ack=1
        STOP = 2'b11  //req=0,ack=0
    } state_send;
    state_send c_send_state, n_send_state;
    // 状态切换
    always_ff @(posedge clk or negedge rst) begin : send_data
        if (!rst) begin
            c_send_state <= IDLE;
            // n_send_state <= IDLE;
        end else begin
            c_send_state <= n_send_state;
        end
    end
    always_comb begin
        case (c_send_state)
            IDLE: begin
                n_send_state = empty ? IDLE :READFIFO;
                rd_en        = 1'b0;
                req          = 1'b0;
            end
            READFIFO: begin
                n_send_state = empty ? IDLE : REQON;
                rd_en        = empty ? 1'b0 : 1'b1;
                req          = 1'b0;
            end
            REQON: begin
                n_send_state = ack ? STOP : REQON;
                rd_en        = 1'b0;
                req          = 1'b1;
            end
            STOP: begin
                n_send_state = READFIFO;
                rd_en        = 1'b0;
                req          = 1'b0;
            end
            default: begin
                n_send_state = IDLE;
                rd_en        = 1'b0;
                req          = 1'b0;
            end
        endcase
    end
endmodule
