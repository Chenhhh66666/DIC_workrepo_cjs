`include "defines.sv"

module single_port_ram (
    input  logic                clka,
    input  logic                ena,
    input  logic                wea,    //дʹ��
    // input  logic                ra,     //��ʹ��
    input  logic [      11 : 0] addra,
    input  logic [`WIDTH-1 : 0] dina,
    output logic [`WIDTH-1 : 0] douta
);
    //ʵ����ʽ 
    (* ram_style=`RAM_STYLE*) logic [`WIDTH-1 : 0] RAM_DATA[0 : `DEPTH-1];  //RAM�д������

    initial begin
        $readmemb("dds_init.txt", RAM_DATA, 0, 3071);  ///��ʼ����������
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
