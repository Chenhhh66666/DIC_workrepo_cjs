`timescale 1ns / 1ps
`include "defines.sv"
module bridge_tb;
    logic                clk = 'd0;
    logic                valid = 'd0;
    logic                ack = 'd0;
    logic                rst = 'd0;
    logic                sender_en = 'd0;
    logic                bridge_en = 'd0;
    logic                receive_en = 'd0;
    logic                ready = 'd0;
    logic                req = 'd0;
    // logic [`WIDTH-1 : 0] sender_Datain = 'd0;
    logic [`WIDTH-1 : 0] rece_Dataout = 'd0;
    logic [`WIDTH-1 : 0] data_in = 'd0;
    logic [`WIDTH-1 : 0] data_out = 'd0;

    sender sender_inst (  // 发送
        .ready   (ready),
        .clk     (clk),
        .rst     (rst),
        // .data_in (sender_Datain),
        .en      (sender_en),
        .data_out(data_in),
        .valid   (valid)
    );

    bridge bridge_inst (  // 桥接
        .clk     (clk),
        .valid   (valid),
        .data_in (data_in),
        .ack     (ack),
        .rst     (rst),
        .en      (bridge_en),
        .ready   (ready),
        .req     (req),
        .data_out(data_out)
    );

    receiver receiver_inst (  //接收
        .clk         (clk),
        .rst         (rst),
        .en          (receive_en),
        .data_in     (data_out),
        .req         (req),
        .ack         (ack),
        .receive_data(rece_Dataout)
    );

    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    task automatic reset();
        rst = 1'b1;
        #30;
        rst = 1'b0;
        #20;
        rst       = 1'b1;
        bridge_en = 1'b1;
        //sender_en = 1'b1;
        #50;

    endtask  //automatic

    task automatic sender_senddata();
        @(posedge clk);
        sender_en <= 1'b1;
        // @(posedge clk);
        // sender_en <= 1'b0;
        // @(posedge clk);
        // @(posedge clk);
    endtask  //automatic

    task automatic receive_data();
        @(posedge clk);
        receive_en <= 1'b1;
        @(posedge clk);
        receive_en <= 1'b0;
        @(posedge clk);
        @(posedge clk);
    endtask

    initial begin
        reset();
        // sender_senddata();
        // sender_senddata();
        // sender_senddata();
        // // #500;
        // // receive_en = 1'b1;
        // #100;
        // receive_data();
        // receive_data();
        // receive_data();
        sender_senddata();
        sender_senddata();
        receive_data();
        sender_senddata();
        receive_data();
        sender_senddata();
        receive_data(); 
        // receive_data(); 
        #200;
        $finish();
    end

endmodule
