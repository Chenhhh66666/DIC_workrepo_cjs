`timescale 1ns / 1ps

module rxd_clk #(
    parameter CLK_FREQUENCE = 50_000_000,  //Ĭ��ʱ��
    parameter BPS           = 9600         //������
) (
    input  logic clk,
    input  logic rst_n,      //ȫ���첽��λ
    input  logic rx_start,   //��ʼ����
    input  logic rx_done,    //�������
    output logic sample_clk  //����ʱ��
);
    localparam SMP_CLK_CNT = (CLK_FREQUENCE / (BPS*9))  - 1;  //1bit�����Ŵ�
    localparam CNT_WIDTH = $clog2(SMP_CLK_CNT);  //����λ��

    logic [CNT_WIDTH-1 : 0] clk_count;

    typedef enum logic [1:0] {
        IDLE,
        RECEIVE
    } state;

    state current_state, next_state;  //��̬�ʹ�̬
    //״̬ת���߼�
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end
    //��̬�߼�
    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE:    next_state = rx_start ? RECEIVE : IDLE;
            RECEIVE: next_state = rx_done ? IDLE : RECEIVE;
            default: next_state = IDLE;
        endcase
    end
    //����߼�

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_count <= '0;
        else begin
            case (current_state)
                IDLE:    clk_count <= '0;
                RECEIVE: clk_count <= clk_count == SMP_CLK_CNT ? '0 : clk_count + 1'b1;
                default: clk_count <= '0;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk <= 1'b0;  //��λ
        else if (clk_count == SMP_CLK_CNT) sample_clk <= 1'b1;  //��������
        else sample_clk <= 1'b0;
    end

    //�����������
    function integer log2(input integer v);
        begin
            log2 = 0;
            while (v >> log2) begin
                log2 = log2 + 1;  //�������ƶ�ֱ��Ϊ0
            end
        end
    endfunction

endmodule
