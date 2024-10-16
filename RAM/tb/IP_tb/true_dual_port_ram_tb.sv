`timescale 1ns / 1ps
`include "defines.sv"

module true_dual_port_ram_tb;

    logic               clka = 1'b0;
    logic               ena = 1'b0;
    logic               wea = 1'b0;
    logic [ ADDR-1 : 0] addra = 'd0;
    logic [WIDTH-1 : 0] dina = 'd0;
    logic [WIDTH-1 : 0] douta = 'd0;
    logic               clkb = 1'b0;
    logic               enb = 1'b0;
    logic               web = 1'b0;
    logic [ ADDR-1 : 0] addrb = 'd0;
    logic [WIDTH-1 : 0] dinb = 'd0;
    logic [WIDTH-1 : 0] doutb = 'd0;

    true_dual_port_ram your_instance_name (
        .clka (clka),   // input wire clka
        .ena  (ena),    // input wire ena
        .wea  (wea),    // input wire [0 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina (dina),   // input wire [31 : 0] dina
        .douta(douta),  // output wire [31 : 0] douta
        .clkb (clkb),   // input wire clkb
        .enb  (enb),    // input wire enb
        .web  (web),    // input wire [0 : 0] web
        .addrb(addrb),  // input wire [9 : 0] addrb
        .dinb (dinb),   // input wire [31 : 0] dinb
        .doutb(doutb)   // output wire [31 : 0] doutb
    );

    initial begin
        clka = 1'b1;
        forever #10 clka = ~clka;
    end

    initial begin
        clkb = 1'b1;
        forever #10 clkb = ~clkb;
    end

    task automatic ram_init();
        ena = 1'b1;
        enb = 1'b1;
    endtask  //automatic

    task automatic ram_write_a(input logic [ADDR-1 : 0] addr, input logic [WIDTH-1 : 0] data);
        wea = 1'b1;
        @(posedge clka);
        addra <= addr;
        dina  <= data;
        //wea = 1'b0;
    endtask  //automatic

    task automatic ram_read_a(input logic [ADDR-1 : 0] addr);
        wea <= 1'b0;
        @(posedge clka);
        addra <= addr;
    endtask  //automatic

    task automatic ram_write_b(input logic [ADDR-1 : 0] addr, input logic [WIDTH-1 : 0] data);
        web = 1'b1;
        @(posedge clkb);
        addrb <= addr;
        dinb  <= data;
        //web = 1'b0;
    endtask  //automatic

    task automatic ram_read_b(input logic [ADDR-1 : 0] addr);
        web = 1'b0;
        @(posedge clkb);
        addrb <= addr;
        //web = 1'b1;
    endtask  //automatic

    //总的输出逻辑
    initial begin
        ram_init();
        //portA对前0~511的数据读写,portB对512~1023的数据做读写
        for (int i = 0; i < 512; i++) begin
            ram_write_a(i, i);
            ram_read_a(i);
            ram_write_b(i + 512, i + 512);
            ram_read_b(i + 512);
        end
        #100;
        $finish();
    end

endmodule
