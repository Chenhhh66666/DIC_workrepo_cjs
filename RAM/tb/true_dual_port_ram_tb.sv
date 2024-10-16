`timescale 1ns / 1ps
`include "defines.sv"
module true_dual_port_ram_tb;
    logic                clka = 1'b0;
    logic                ena = 1'b0;
    logic                wea = 1'b0;
    logic [ `ADDR-1 : 0] addra = 'd0;
    logic [`WIDTH-1 : 0] dina = 'd0;
    logic [`WIDTH-1 : 0] douta;
    //PORT;
    logic                clkb = 1'b0;
    logic                enb = 1'b0;
    logic                web = 1'b0;
    logic [ `ADDR-1 : 0] addrb = 'd0;
    logic [`WIDTH-1 : 0] dinb = 'd0;
    logic [`WIDTH-1 : 0] doutb;

    true_dual_port_ram true_dual_port_ram_inst (
        .clka (clka),
        .ena  (ena),
        .wea  (wea),
        .addra(addra),
        .dina (dina),
        .douta(douta),
        .clkb (clkb),
        .enb  (enb),
        .web  (web),
        .addrb(addrb),
        .dinb (dinb),
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

    task automatic AW(input logic [`ADDR-1 : 0] addr, input logic [`WIDTH-1 : 0] data);
        @(posedge clka);
        addra <= addr;
        dina  <= data;
        wea   <= 1'b1;
    endtask  //automatic

    task automatic BW(input logic [`ADDR-1 : 0] addr, input logic [`WIDTH-1 : 0] data);
        @(posedge clkb);
        addrb <= addr;
        dinb  <= data;
        web   <= 1'b1;
    endtask  //automatic

    task automatic AR(input logic [`ADDR-1 : 0] addr);
        @(posedge clka);
        addra <= addr;
        wea   <= 1'b0;
    endtask  //automatic

    task automatic BR(input logic [`ADDR-1 : 0] addr);
        web = 1'b0;
        @(posedge clkb);
        addrb <= addr;

    endtask  //automatic

    task automatic ARBR();
        for (int i = 0; i < `DEPTH; i++) begin
            AR(i);
            BR(i);
        end
    endtask  //automatic
    task automatic ARBW();
        for (int i = 0; i < `DEPTH; i++) begin
            AR(i);
            BW(i, i);
        end
    endtask  //automatic
    task automatic AWBR();
        for (int i = 0; i < `DEPTH; i++) begin
            AW(i, i);
            BR(i);
        end
    endtask  //automatic
    task automatic AWBW();
        for (int i = 0; i < `DEPTH; i++) begin
            AW(i, `DEPTH-i);
            BW(i, i);
        end
    endtask  //automatic

    initial begin
        ena = 1'b1;
        enb = 1'b1;
        #50;
        ARBR();
        #2000;
        AWBW();
        #2000;
        $finish();
    end


endmodule
