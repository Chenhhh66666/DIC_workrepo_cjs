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
    logic [ `ADDR-1 : 0] addra;
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

    always_ff @(posedge clk or negedge reset) begin
        if (dds_en) begin
            if (!reset) begin
                dout <= 'd0;
                case (WAVETYPE)
                    "TRI":   phase <= phase_start;
                    "SIN":   phase <= phase_start + 12'd1024;
                    "SQU":   phase <= phase_start + 12'd2048;
                    default: ;
                endcase
                //phase <= phase_start;
            end else begin
                phase <= phase + step;
                case (WAVETYPE)
                    "TRI": begin
                        if (phase + step >= 1023) phase <= 0;
                        addra <= phase;
                    end
                    "SIN": begin
                        if (phase + step >= 2047) phase <= 1024;
                        addra <= phase;
                    end
                    "SQU": begin
                        if (phase + step >= 3071) phase <= 2048;
                        addra <= phase;
                    end
                    default: ;
                endcase
                dout <= douta;
            end
        end
    end
endmodule
