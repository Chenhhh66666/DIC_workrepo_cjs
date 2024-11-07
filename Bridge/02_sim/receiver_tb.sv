`include "defines.sv"

module receiver_tb;

    logic                clk = 'd0;
    logic                rst = 'd0;
    logic                req = 'd0;
    logic                ack = 'd0;
    logic [`WIDTH-1 : 0] data_in = 'd0;
    logic [`WIDTH-1 : 0] receive_data = 'd0;

    receiver receiver_inst (
        .clk         (clk),
        .rst         (rst),
        .data_in     (data_in),
        .req         (req),
        .ack         (ack),
        .receive_data(receive_data)
    );

    task automatic reset();
        rst = 1'b1;
        #20;
        rst = 1'b0;
        #30;
        rst = 1'b1;
        #50;
    endtask  //automatic

    task automatic send_data(input logic [`WIDTH-1 : 0] data);
        @(posedge clk);
        data_in <= data;
        req <= 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
    endtask  //automatic

    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    initial begin
        reset();
        send_data(32'hcdef);
        req = 1'b0;

    end
endmodule
