`include "defines.sv"
module syncfifo (
    input  logic                clk,
    input  logic                rst_n,
    input  logic                wr_en,
    input  logic                rd_en,
    input  logic [`WIDTH-1 : 0] data_in,
    output logic [`WIDTH-1 : 0] data_out,
    output logic                full,
    output logic                empty,
    output logic                full_th,   //空水位
    output logic                empty_th   //满水位
);
    logic [`DEPTH-1 : 0] fifo_cnt;  //计数器
    logic [`WIDTH-1 : 0] fifo_dat  [`FIFO_CNT_MAX : 0];
    logic [`DEPTH-1 : 0] wr_addr;  //写地址
    logic [`DEPTH-1 : 0] rd_addr;  //读地址

    always_ff @(posedge clk or negedge rst_n) begin : write_data
        if (!rst_n) begin
            wr_addr <= 'd0;
        end else if (!full & wr_en) begin
            wr_addr           <= wr_addr + 1;  //自动递增
            fifo_dat[wr_addr] <= data_in;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : read_data
        if (!rst_n) begin
            rd_addr <= 'd0;
        end else if (!empty) begin
            case (`PATTERN)
                "FWFT": begin  //数据透明
                    data_out <= fifo_dat[rd_addr];
                    rd_addr  <= rd_en ? (rd_addr + 1) : rd_addr;
                end
                "Standard": begin  //非使能不输出
                    if (rd_en) begin
                        data_out <= fifo_dat[rd_addr];
                        rd_addr  <= rd_addr + 1;
                    end
                end
                default: ;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin : fifo_count
        if (!rst_n) begin
            fifo_cnt <= 0;
        end else begin
            case ({
                wr_en, rd_en
            })
                2'b00:   fifo_cnt <= fifo_cnt;
                2'b01:   fifo_cnt <= fifo_cnt - 1;
                2'b10:   fifo_cnt <= fifo_cnt + 1;
                2'b11:   fifo_cnt <= fifo_cnt;
                default: ;
            endcase
        end
    end

    //信号处理
    assign full     = (fifo_cnt == `FIFO_CNT_MAX) ? 1'b1 : 1'b0;
    assign empty    = (fifo_cnt == 'd0) ? 1'b1 : 1'b0;  //刚开始就一起写一起读
    assign full_th  = (fifo_cnt == `FIFO_CNT_MAX - `THRESHOLD) ? 1'b1 : 1'b0;  //满水位
    assign empty_th = (fifo_cnt == `THRESHOLD) ? 1'b1 : 1'b0;  //空水位

endmodule
