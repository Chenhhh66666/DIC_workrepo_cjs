module asyc_fifo #(
    parameter DEPTH_WIDTH = 10,
    parameter DEPTH      = 1024,  //深度1024
    parameter DATA_WIDTH = 32     //位宽32
) (
    input logic [DATA_WIDTH-1 : 0] write_data,
    input logic                    w_clk,
    input logic                    w_rstn,
    input logic                    w_en,

    output logic [DATA_WIDTH-1 : 0] read_data,
    input  logic                    r_clk,
    input  logic                    r_rstn,
    input  logic                    r_en,

    output logic fifo_full,
    output logic fifo_empty
);

    logic [DATA_WIDTH-1 : 0] fifo_data              [DEPTH-1 : 0];  //定义fifo数据空间
    logic [  DEPTH_WIDTH : 0] w_pointer;  //写指针
    logic [  DEPTH_WIDTH : 0] r_pointer;  //读指针
    logic [DEPTH_WIDTH-1 : 0] w_addr;  //写地址
    logic [DEPTH_WIDTH-1 : 0] r_addr;  //读地址
    assign w_addr = w_pointer[DEPTH_WIDTH-1 : 0];  //最高位做标志位
    assign r_addr = r_pointer[DEPTH_WIDTH-1 : 0];

    //write_data
    always_ff @(posedge w_clk or negedge w_rstn) begin : w_pointer_add
        if (!w_rstn) w_pointer <= 'd0;
        else if (w_en & !fifo_full) w_pointer <= w_pointer + 1;
        else w_pointer <= w_pointer;
    end
    always_ff @(posedge w_clk or negedge w_rstn) begin : writedata
        if (!w_rstn) fifo_data[w_addr] <= 'd0;
        else if (w_en & !fifo_full) fifo_data[w_addr] <= write_data;
        else fifo_data[w_addr] <= fifo_data[w_addr];
    end

    //read_data
    always_ff @(posedge r_clk or negedge r_rstn) begin : r_pointer_add
        if (!r_rstn) r_pointer <= 'd0;
        else if (r_en & !fifo_empty) r_pointer <= r_pointer + 1;
        else r_pointer <= r_pointer;
    end
    always_ff @(posedge r_clk or negedge r_rstn) begin : readdata
        if (!r_rstn) read_data <= 'd0;
        else if (r_en & !fifo_empty) read_data <= fifo_data[r_addr];
        else read_data <= read_data;
    end

    //GreyCode
    logic [DEPTH_WIDTH : 0] w_poit_gray;
    logic [DEPTH_WIDTH : 0] r_poit_gray;
    assign w_poit_gray = w_pointer ^ (w_pointer >> 1);
    assign r_poit_gray = r_pointer ^ (r_pointer >> 1);

    //CDC
    //在写指针域获得full信号，读指针同步到写指针域
    logic [DEPTH_WIDTH : 0] r_pointer1;
    logic [DEPTH_WIDTH : 0] r_pointer2;
    always_ff @(posedge w_clk or negedge w_rstn) begin : read_clock2writr_clock
        if (!w_rstn) begin
            r_pointer1 <= 'd0;
            r_pointer2 <= 'd0;
        end else begin
            r_pointer1 <= r_pointer;
            r_pointer2 <= r_pointer1;
        end
    end
    //在读指针域获得empty信号，写指针同步到读指针域
    logic [DEPTH_WIDTH : 0] w_pointer1;
    logic [DEPTH_WIDTH : 0] w_pointer2;
    always_ff @(posedge r_clk or negedge r_rstn) begin : write_clock2readclock
        if (!r_rstn) begin
            w_pointer1 <= 'd0;
            w_pointer2 <= 'd0;
        end else begin
            w_pointer1 <= w_pointer;
            w_pointer2 <= w_pointer1;
        end
    end

    //fifo_full,fifo_empty
    assign fifo_full  = ((r_pointer2 ^ w_pointer) == $pow(2, DEPTH_WIDTH)) ? 1'b1 : 1'b0;
    assign fifo_empty = ((w_pointer2 ^ r_pointer) == 'd0) ? 1'b1 : 1'b0;

endmodule
