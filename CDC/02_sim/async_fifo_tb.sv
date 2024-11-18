`timescale 1ns / 1ps
module asyc_fifo_tb;

    // Parameters
    localparam DATA_DEPTH = 10;
    localparam DATA_WIDTH = 32;

    //Ports
    logic [DATA_WIDTH-1 : 0] write_data = 'd0;
    logic                    w_clk = 'd0;
    logic                    w_rstn = 'd0;
    logic                    w_en = 'd0;
    logic [DATA_WIDTH-1 : 0] read_data;
    logic                    r_clk = 'd0;
    logic                    r_rstn = 'd0;
    logic                    r_en = 'd0;
    logic                    fifo_full;
    logic                    fifo_empty;

    asyc_fifo #(
        .DATA_DEPTH(DATA_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) asyc_fifo_inst (
        .write_data(write_data),
        .w_clk     (w_clk),
        .w_rstn    (w_rstn),
        .w_en      (w_en),
        .read_data (read_data),
        .r_clk     (r_clk),
        .r_rstn    (r_rstn),
        .r_en      (r_en),
        .fifo_full (fifo_full),
        .fifo_empty(fifo_empty)
    );

    initial begin
        forever begin
            #5 w_clk = !w_clk;  //读时钟100M
        end
    end

    initial begin
        forever begin
            #50 r_clk = !r_clk;  //写时钟10M
        end
    end

    task automatic wr_reset();
        w_rstn = 1'b1;
        #50;
        w_rstn = 1'b0;
        #50;
        w_rstn = 1'b1;
    endtask  //automatic

    task automatic rd_reset();
        r_rstn = 1'b1;
        #50;
        r_rstn = 1'b0;
        #50;
        r_rstn = 1'b1;
    endtask  //automatic

    // task automatic write_en();
    //     w_en = 1'b1;
    // endtask //automatic
    task automatic writedata(input logic [DATA_WIDTH-1 : 0] data);
        @(posedge w_clk);
        w_en       <= 1'b1;
        write_data <= data;
    endtask  //automatic


    initial begin
        wr_reset();
        rd_reset();
        // w_en = 1'b1;
        for (int i = 0; i < 1124; i++) begin
            writedata(i);
        end
        w_en = 1'b0;

        r_en = 1'b1;
        #110000;  //等读完
        r_en = 1'b0;
        for (int i = 0; i < 100; i++) begin
            writedata(i);
        end

        r_en = 1'b1;  //边读边写
        for (int i = 0; i < 924; i++) begin
            writedata(i);
        end
        w_en = 1'b0;
        #1000;
        // $finish();
    end
endmodule
