`include "defines.sv"

module single_port_ram (
    input  logic                clka,
    input  logic                ena,
    input  logic                wea,    //写使能
    // input  logic                ra,     //读使能
    input  logic [ `ADDR-1 : 0] addra,
    input  logic [`WIDTH-1 : 0] dina,
    output logic [`WIDTH-1 : 0] douta
);


    //实现形式 block distributed

    (* ram_style="distributed"*) logic [`WIDTH-1 : 0] RAM_DATA[0 : `DEPTH-1];  //RAM中存的数据

    initial begin
        $readmemb("dds_init.txt", RAM_DATA, 0, 3071);  ///初始化波形数据
    end

    always_ff @(posedge clka) begin
        if (ena) begin
            case (`CLASH)
                "READFIRST": begin
                    douta <= RAM_DATA[addra];
                    if (wea) RAM_DATA[addra] <= dina;
                end
                "WRITEFIRST": begin
                    if (wea) begin
                        RAM_DATA[addra] <= dina;
                        douta           <= dina;
                    end else begin
                        douta <= RAM_DATA[addra];
                    end
                end
                "NOCHANGE": begin
                    if (wea) begin
                        RAM_DATA[addra] <= dina;
                    end else begin
                        douta <= RAM_DATA[addra];
                    end
                end
                default: ;
            endcase
        end
        // else begin
        //     douta <= 'd0;
        // end
    end
endmodule
