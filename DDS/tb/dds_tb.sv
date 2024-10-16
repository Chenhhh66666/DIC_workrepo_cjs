`include "defines.sv"
module dds_tb;
    logic                clk = 1'b1;
    logic                reset = 1'b1;
    logic                dds_en = 1'b0;
    logic [ `ADDR-1 : 0] phase_start1;
    logic [ `ADDR-1 : 0] phase_start2;
    logic [ `ADDR-1 : 0] phase_start3;
    logic [         3:0] step1 = 'd0;
    logic [         3:0] step2 = 'd0;
    logic [         3:0] step3 = 'd0;
    logic [`WIDTH-1 : 0] dout1;
    logic [`WIDTH-1 : 0] dout2;
    logic [`WIDTH-1 : 0] dout3;

    dds #(
        .WAVETYPE("TRI")
    ) dds_inst1 (
        .dds_en     (dds_en),
        .clk        (clk),
        .reset      (reset),
        .phase_start(phase_start1),
        .step       (step1),
        .dout       (dout1)
    );
    dds #(
        .WAVETYPE("SIN")
    ) dds_inst2 (
        .dds_en     (dds_en),
        .clk        (clk),
        .reset      (reset),
        .phase_start(phase_start2),
        .step       (step2),
        .dout       (dout2)
    );
    dds #(
        .WAVETYPE("SQU")
    ) dds_inst3 (
        .dds_en     (dds_en),
        .clk        (clk),
        .reset      (reset),
        .phase_start(phase_start3),
        .step       (step3),
        .dout       (dout3)
    );
    initial begin
        clk = 1'b1;
        forever #10 clk = ~clk;
    end

    task automatic dds_init();
        @(posedge clk);
        step1        <= 1;
        phase_start1 <= 256;
        step2        <= 2;
        phase_start2 <= 384;
        step3        <= 4;
        phase_start3 <= 512;
    endtask  //automatic

    initial begin
        dds_init();
        dds_en = 1'b1;
        #20;
        reset = 1'b0;
        #20;
        reset = 1'b1;
        #10000;
        //$finish();
    end

endmodule
