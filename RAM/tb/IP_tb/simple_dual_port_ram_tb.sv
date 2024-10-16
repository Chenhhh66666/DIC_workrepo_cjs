`timescale 1ns / 1ps
`include "defines.sv"
module simple_dual_port_ram_tb;
    logic               clka = 1'b0;
    logic               ena = 1'b0;
    logic               wea = 1'b0;
    logic [ ADDR-1 : 0] addra = 'd0;
    logic [WIDTH-1 : 0] dina = 'd0;
    logic               clkb = 1'b0;
    logic               enb = 1'b0;
    logic [ ADDR-1 : 0] addrb = 'd0;
    logic [WIDTH-1 : 0] doutb = 'd0;

    simple_dual_port_ram your_instance_name (
        .clka (clka),   // input wire clka
        .ena  (ena),    // input wire ena
        .wea  (wea),    // input wire [0 : 0] wea
        .addra(addra),  // input wire [9 : 0] addra
        .dina (dina),   // input wire [31 : 0] dina
        .clkb (clkb),   // input wire clkb
        .enb  (enb),    // input wire enb
        .addrb(addrb),  // input wire [9 : 0] addrb
        .doutb(doutb)   // output wire [31 : 0] doutb
    );

    initial begin
        clka = 1'b1;
        forever #10 clka = ~clka;
    end

    initial begin
        clka = 1'b1;
        forever #10 clkb = ~clkb;
    end

    task automatic ram_init();
        ena = 1'b1;
        enb = 1'b1;
        #50;
    endtask  //automatic

    task automatic simple_dp_ram_write(input logic [ADDR-1 : 0] addr, input logic [WIDTH-1 : 0] data);
        
        @(posedge clka);
        addra <= addr;
        dina <= data;

    endtask  //automatic

    task automatic simple_dp_ram_read(input logic [ADDR-1 : 0] addr);
        @(posedge clkb);
        addrb <= addr;
    endtask //automatic


    // initial begin
    //     ram_init();
    //     wea <= 1'b1;
    //     //先读后写
    //     for (int i = 0; i < DEPTH-1 ; i++) begin
    //         simple_dp_ram_read(i+1);
    //         simple_dp_ram_write(i,i);
    //     end
    //     wea <= 1'b0;
    //     #200;
    //     for (int i = 0; i < DEPTH; i++) begin
    //         simple_dp_ram_read(i);
    //     end
    //     #200;
    //     $finish();
    // end
    initial begin
        ram_init();
        wea <= 1'b1;
        //READ first
        for (int i = 0; i < DEPTH-1 ; i++) begin
            simple_dp_ram_write(i,i);
            simple_dp_ram_read(i);
            
        end
        wea <= 1'b0;
        #200;
        for (int i = 0; i < DEPTH; i++) begin
            simple_dp_ram_read(i);
        end
        #200;
        $finish();
    end

endmodule
