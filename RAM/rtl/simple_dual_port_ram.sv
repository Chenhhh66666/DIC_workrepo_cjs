`include "defines.sv"
module simple_dual_port_ram (
    input  logic                clka,   //写时钟
    input  logic                ena,    //写时钟使能
    input  logic                wea,    //写使能
    input  logic [ `ADDR-1 : 0] addra,  //写地址
    input  logic [`WIDTH-1 : 0] dina,   //写的数据
    input  logic                clkb,   //读时钟使能
    input  logic                enb,    //读时钟使能
    input  logic [ `ADDR-1 : 0] addrb,  //读地址
    output logic [`WIDTH-1 : 0] doutb   //读的数据
);
    (*ram_style = "block"*) logic [`WIDTH-1 : 0] RAM_DATA[0 : `DEPTH-1];
    initial begin
        $readmemb("coe_tb.txt", RAM_DATA, 0, 1023);  //初始化文件加载
    end
    //port A
    always_ff @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                RAM_DATA[addra] <= dina;
            end
        end
    end
    //port B
    always_ff @(posedge clkb) begin
        if (enb) begin
            case (`CLASH)
                "READFIRST": begin
                    doutb <= RAM_DATA[addrb];
                end
                "WRITEFIRST": begin
                    if (wea & (addra == addrb)) begin
                        doutb <= dina;
                    end//读写发生在同一地址
                    else begin
                        doutb <= RAM_DATA[addrb];
                    end
                end
                "NOCHANGE": begin
                    doutb <= wea ? doutb : RAM_DATA[addrb];
                end
                default: ;
            endcase
        end
    end
endmodule
