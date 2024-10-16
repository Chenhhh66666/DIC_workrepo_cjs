`include "defines.sv"
module true_dual_port_ram (
    //PORTA
    input  logic                clka,
    input  logic                ena,
    input  logic                wea,
    input  logic [ `ADDR-1 : 0] addra,
    input  logic [`WIDTH-1 : 0] dina,
    output logic [`WIDTH-1 : 0] douta,
    //PORTB
    input  logic                clkb,
    input  logic                enb,
    input  logic                web,
    input  logic [ `ADDR-1 : 0] addrb,
    input  logic [`WIDTH-1 : 0] dinb,
    output logic [`WIDTH-1 : 0] doutb
);
    (*ram_style = `RAM_STYLE*) logic [`WIDTH-1 : 0] RAM_DATA[0 : `DEPTH-1];
    //PORTA
    initial begin
        $readmemb("coe_tb.txt", RAM_DATA, 0, 1023);
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            case (`CLASH)
                "READFIRST": begin
                    douta <= RAM_DATA[addra];
                    if (wea) begin
                        RAM_DATA[addra] <= dina;
                    end
                end
                "WRITEFIRST": begin
                    if (wea) begin
                        douta           <= dina;
                        RAM_DATA[addra] <= dina;
                    end else begin
                        douta <= RAM_DATA[addra];
                    end
                end
                "NOCHANGE": begin
                    if (wea) begin
                        RAM_DATA[addra] <= dina;
                        douta           <= douta;
                    end
                end
                default: ;
            endcase
        end
    end
    //PORTB
    always_ff @(posedge clkb) begin
        if (enb) begin
            case (`CLASHB)
                "READFIRST": begin
                    if (web & !(wea & (addra == addrb))) begin  //写写冲突的时候给wea让步
                        RAM_DATA[addrb] <= dinb;
                    end
                    doutb <= RAM_DATA[addrb];
                end
                "WRITEFIRST": begin
                    if (web & !(wea & (addra == addrb))) begin
                        RAM_DATA[addrb] <= dinb;
                        doutb           <= dinb;
                    end else begin
                        doutb <= RAM_DATA[addrb];
                    end
                end
                "NOCHANGE": begin
                    if (web & (wea & (addra == addrb))) begin
                        RAM_DATA[addrb] <= dinb;
                        doutb           <= doutb;
                    end else begin
                        doutb <= RAM_DATA[addrb];
                    end
                end
                default: ;
            endcase
        end
    end
endmodule
