`include "defines.sv"
module dds #(
    parameter WAVETYPE = "TRI"
) (
    input  logic                dds_en,
    input  logic                clk,
    input  logic                reset,
    input  logic [ `ADDR-1 : 0] phase_start,
    input  logic [         3:0] step,         //即频率
    output logic [`WIDTH-1 : 0] dout
);
    logic                wea;
    logic                ena;
    logic [`WIDTH-1 : 0] dina;
    logic [`WIDTH-1 : 0] douta;
    logic [        11:0] addra;
    assign ena = 1'b1;  //一直使能
    assign wea = 1'b0;
    single_port_ram single_port_ram_inst (  //初始化了波形数据在里面 0-1023三角波1024-2047正弦波2048-3071方波
        .clka (clk),
        .ena  (ena),
        .wea  (wea),
        .addra(addra),
        .dina (dina),
        .douta(douta)
    );

    logic [`ADDR-1:0] phase;
    logic [      1:0] addr_MSB;
    always_ff @(posedge clk) begin : blockName
        case (WAVETYPE)
            "TRI":   addr_MSB <= 2'b00;
            "SIN":   addr_MSB <= 2'b01;
            "SQU":   addr_MSB <= 2'b10;
            default: ;
        endcase
    end

    always_ff @(posedge clk or negedge reset) begin
        if (dds_en) begin
            if (!reset) begin
                dout <= 'd0;
                phase <= phase_start;
            end else begin
                phase <= phase + step;
                addra <= {addr_MSB, phase};
                dout  <= douta;
            end
        end
    end
endmodule
