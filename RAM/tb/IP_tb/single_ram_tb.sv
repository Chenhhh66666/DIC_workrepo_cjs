`timescale 1ns / 1ps
`include "defines.sv"

module single_port_ram_tb;

    logic                       clka = 1'b1;
    logic                       rsta = 1'b1;  //低电平有效复位
    logic                       ena = 1'b0;
    logic                       wea = 1'b0;
    logic [ ADDR-1 : 0] addra = 'd0;
    logic [WIDTH-1 : 0] dina = 'd0;
    logic [WIDTH-1 : 0] douta = 'd0;

    single_port_ram single_port_ram_inst (
        .clka (clka),   // input wire clka
        // a.rsta     (rsta),      // input wire rsta
        .ena  (ena),    // input wire ena
        .wea  (wea),    // input wire [0 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina (dina),   // input wire [31 : 0] dina
        .douta(douta)   // output wire [31 : 0] douta
        // .rsta_busy(rsta_busy)  // output wire rsta_busy
    );

    initial begin
        clka = 1;
        forever #10 clka = ~clka;
    end

    task automatic rsta_init();
        rsta = 1'b0;
        #20;
        rsta = 1'b1;
        ena  = 1'b1;
        #50;
    endtask

    task automatic single_ram_write(input logic [WIDTH-1 : 0] data, input logic [ADDR-1 : 0] addr);
        @(posedge clka);
        wea   <= 1'b1;
        addra <= addr;
        dina  <= data;
        @(posedge clka);
        wea <= 1'b0;
        // #1000;
    endtask  //automatic

    task automatic single_ram_read(input logic [ADDR-1 : 0] addr);
        @(posedge clka);
        wea   <= 1'b0;
        addra <= addr;
        @(posedge clka);
    endtask  //automatic

    task automatic single_ram_readcoe();  //coe文件全部读出来
        wea = 1'b0;
        for (int i = 0; i < DEPTH; i++) begin
            @(posedge clka);
            addra <= i;
        end
        wea = 1'b1;
    endtask  //automatic

    initial begin
        rsta_init();
        //single_ram_write('d12, 'd100);
        //single_ram_read('d100);
        single_ram_readcoe();
        for (int i = 0 ; i <DEPTH ; i ++ ) begin
            single_ram_write(i, i);
            single_ram_read(i);
        end
        #1000;
        $finish();
    end
    //逻辑初始化

endmodule
