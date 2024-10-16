`timescale 1ns / 1ps
`include "defines.sv"
module simple_dual_port_ram_tb;
    logic                clka = 1'b0;
    logic                ena = 1'b0;
    logic                wea = 1'b0;
    logic [ `ADDR-1 : 0] addra = 'd0;
    logic [`WIDTH-1 : 0] dina = 'd0;
    logic                clkb = 1'b0;
    logic                enb = 1'b0;
    logic [ `ADDR-1 : 0] addrb = 'd0;
    logic [`WIDTH-1 : 0] doutb;

    simple_dual_port_ram simple_dual_port_ram_inst (
        .clka (clka),
        .ena  (ena),
        .wea  (wea),
        .addra(addra),
        .dina (dina),
        .clkb (clkb),
        .enb  (enb),
        .addrb(addrb),
        .doutb(doutb)
    );

    initial begin
        clka = 1'b1;
        forever #10 clka = ~clka;
    end

    initial begin
        clkb = 1'b1;
        forever #10 clkb = ~clkb;
    end

    task automatic portBen();
        enb = 1'b1;
    endtask  //automatic

    task automatic portAen();
        ena = 1'b1;
    endtask  //automatic

    task automatic portBread(input logic [`ADDR-1 : 0] addr);
        @(posedge clkb);
        addrb <= addr;
    endtask  //automatic

    task automatic portAwrite(input logic [`ADDR-1 : 0] addr, input logic [`WIDTH-1 : 0] data);
        @(posedge clka);
        addra <= addr;
        dina  <= data;
        wea   <= 1'b1;
    endtask  //automatic

    task automatic AWBR(input logic [`ADDR-1 : 0] addr, input logic [`WIDTH-1 : 0] data);
        @(posedge clka);
        addra <= addr;
        dina  <= data;
        wea   <= 1'b1;
        @(posedge clkb);
        addrb <= addr;
    endtask  //automatic

    initial begin
        portBen();
        portAen();
        for (int i = 0; i < `DEPTH; i++) begin  //读一遍初始化数据
            portBread(i);
        end
        for (int i = 0; i < `DEPTH; i++) begin
            AWBR(i, i);
            //portBread(i);
        end
        wea = 1'b0;  //关闭写操作
        #200;
        // for (int i = 0; i < `DEPTH; i++) begin
        //     portBread(i);
        // end
        $finish();
    end

endmodule
