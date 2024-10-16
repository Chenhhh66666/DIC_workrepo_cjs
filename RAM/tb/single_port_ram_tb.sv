`timescale 1ns / 1ps
`include "defines.sv"
module single_port_ram_tb;
    logic                clka = 1'b0;
    logic                ena = 1'b0;
    logic                wea = 1'b0;
    logic [ `ADDR-1 : 0] addra = 'd0;
    logic [`WIDTH-1 : 0] dina = 'd0;
    logic [`WIDTH-1 : 0] douta;
    //logic [`WIDTH-1 : 0] ram_data    [0:`DEPTH-1] = '{default: 'd0};
    single_port_ram single_port_ram_inst (
        .clka (clka),
        .ena  (ena),
        .wea  (wea),
        .addra(addra),
        .dina (dina),
        .douta(douta)
    );

    initial begin
        clka = 1'b1;
        forever #10 clka = ~clka;
    end

    task automatic ram_init();
        ena = 1'b1;  // 使能信号

    endtask  //automatic


    task automatic ram_read(input logic [`ADDR-1 : 0] addr);
        @(posedge clka);
        //wea   <= 1'b0;
        addra <= addr;

        // wea   <= 1'b0;
    endtask  //automatic

    task automatic ram_write(input logic [`ADDR-1 : 0] addr, input logic [`WIDTH-1 : 0] data);
        @(posedge clka);
        wea   <= 1'b1;
        addra <= addr;
        dina  <= data;
    endtask  //automatic

    // task automatic CLASH(input logic [`ADDR-1 : 0] addr, input logic[`WIDTH-1 : 0] data);
    //     @(posedge clka);
    //     wea     


    // endtask //automatic


    initial begin
        // ram_init();
        // wea = 1'b1;
        // $readmemb("coe_tb.txt", ram_data, 0, 1023);
        // 先初始化再给使能否则加载不出来！！
        ram_init();
        for (int i = 0; i < `DEPTH; i = i + 1) begin
            ram_write(i, `DEPTH - i);
        end
        #1000;
        wea = 1'b0;
        for (int i = 0; i < `DEPTH; i++) begin
            ram_write(i, i);
            //ram_read(i);
        end
        //ram_read(256);
        #200;
        $finish();
    end

endmodule
