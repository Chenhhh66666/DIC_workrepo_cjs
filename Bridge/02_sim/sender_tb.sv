`include "defines.sv"
module sender_tb;
    logic                ready = 'd0;
    logic                clk = 'd0;
    logic                rst = 'd0;
    logic                en = 'd0;
    logic                valid = 'd0;
    // logic [`WIDTH-1 : 0] data_in = 'd0;
    logic [`WIDTH-1 : 0] data_ou = 'd0;

    sender sender_inst (
        .ready   (ready),
        .clk     (clk),
        .rst     (rst),
        // .data_in (data_in),
        .en      (en),
        .data_out(data_out),
        .valid   (valid)
    );

    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    task automatic send_data();
        @(posedge clk);
        //data_in <= data;
        en <= 1'b1;
        @(posedge clk);
        en <= 1'b0;
    endtask  //automatic

    task automatic ready_sign();
        @(posedge clk);
        ready <= 1'b1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        ready <= 1'b0;
    endtask  //automatic

    initial begin
        rst = 1'b1;
        #20;
        rst = 1'b0;
        #30;
        rst = 1'b1;
        #50;

        send_data();
        ready_sign();

        #500;
        send_data();
        ready_sign();
        #500;
    end


endmodule
