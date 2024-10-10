`timescale 1ns / 1ps

module rxd #(
    parameter CLK_FREQUENCE = 50_000_000,
    parameter BPS           = 9600,
    parameter PARITY        = "NONE",
    parameter WIDTH         = 8            //????��??
) (
    input  logic               clk,        //???
    input  logic               rst_n,      //???????��
    input  logic               uart_rx,    //???????
    output logic               rx_done,    //??????????1????0?????
    output logic [WIDTH-1 : 0] rx_data,    //?????????
    output logic               data_error  //??????��???
);

    logic                     sample_clk;
    logic                     frame_en;
    logic                     cnt_en;
    logic [            3 : 0] sample_clk_cnt;
    logic [log2(WIDTH)-1 : 0] sample_bit_cnt;
    logic                     baud_rate_clk;

    typedef enum logic [2:0] {
        IDLE,
        START_BIT,
        DATA_RECE,
        PARITY_BIT,
        STOP,
        DONE
    } STATE_RX;
    STATE_RX current_state, next_state;

    // typedef enum logic [1:0] {
    //     ODD = 2'b00,
    //     EVEN = 2'b01,
    //     NONE = 2'b10
    // } STATE_PARITY;
    // STATE_PARITY       verigy_mode;

    logic [1:0] verify_mode;
    // generate
    //     if (PARITY == "ODD") assign verify_mode = 2'b01;
    //     else if (PARITY == "EVEN") assign verify_mode = 2'b10;
    //     else if (PARITY == "NONE") assign verify_mode = 2'b00;
    //     else assign verify_mode = 2'b00;
    // endgenerate
    always_comb begin
       case(PARITY)
       "ODD":verify_mode = 2'b01;
       "EVEN":verify_mode = 2'b10;
       "NONE":verify_mode = 2'b00;
       default:verify_mode = 2'b00;
    endcase

    end

    logic [3:0] uart_rx_bit;
    logic       neg_edge = '0;
    // logic              frame_en = '0;  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx_bit = 4'b0000;
        end else begin
            uart_rx_bit[0] <= uart_rx;
            uart_rx_bit[1] <= uart_rx_bit[0];
            uart_rx_bit[2] <= uart_rx_bit[1];
            uart_rx_bit[3] <= uart_rx_bit[2];
        end
    end


    // always_comb begin
    //     neg_edge = uart_rx_bit[3] & uart_rx_bit[2] & ~uart_rx_bit[1] & ~uart_rx_bit[0];
    //     frame_en = neg_edge && (current_state == IDLE);
    // end
    always_comb begin
        frame_en = (uart_rx_bit[3] & uart_rx_bit[2] & ~uart_rx_bit[1] & ~uart_rx_bit[0]);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cnt_en <= 1'b0;
        else if (frame_en) cnt_en <= 1'b1;  //????????????????
        else if (rx_done) cnt_en <= 1'b0;  //??????????????
        else cnt_en <= cnt_en;
    end

    assign baud_rate_clk = sample_clk & sample_clk_cnt == 4'd8;  //????????????????????

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_clk_cnt <= 4'd0;
        else if (cnt_en) begin
            if (baud_rate_clk) sample_clk_cnt <= 4'd0;
            else if (sample_clk) sample_clk_cnt <= sample_clk_cnt + 1'b1;  //?????????????
            else sample_clk_cnt <= sample_clk_cnt;
        end else sample_clk_cnt <= 4'd0;
    end
    //???��0??LSB????????MSB
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_bit_cnt <= 'b0;
        else if (current_state == IDLE) sample_bit_cnt <= 'b0;
        else if (baud_rate_clk)  //????��???????????baud????
            sample_bit_cnt <= sample_bit_cnt + 1'b1;
        else sample_bit_cnt <= sample_bit_cnt;
    end
    //?????????��????��?????????????
    logic [1:0] sample_data;  //??????????
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) sample_data <= 1'b0;
        else if (sample_clk) begin
            case (sample_clk_cnt)
                4'd0:             sample_data <= 4'd0;
                4'd3, 4'd4, 4'd5: sample_data <= sample_data + uart_rx;  //?????��??????
                default:          sample_data <= sample_data;
            endcase
        end
    end
    //???��?
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= IDLE;
        else current_state <= next_state;
    end
    //???????
    always_comb begin
        case (current_state)
            IDLE:       next_state = frame_en ? START_BIT : IDLE;
            START_BIT:  next_state = (baud_rate_clk & sample_data[1] == 1'b0) ? DATA_RECE : START_BIT;  //??????0?????��?????
            DATA_RECE: begin
                case (verify_mode[1] ^ verify_mode[0])
                    1'b1:    next_state = (sample_bit_cnt == WIDTH & baud_rate_clk) ? PARITY_BIT : DATA_RECE;
                    1'b0:    next_state = (sample_bit_cnt == WIDTH & baud_rate_clk) ? STOP : DATA_RECE;
                    default: next_state = (sample_bit_cnt == WIDTH & baud_rate_clk) ? STOP : DATA_RECE;
                endcase
            end
            PARITY_BIT: next_state = baud_rate_clk ? STOP : PARITY_BIT;
            STOP:       next_state = (baud_rate_clk & sample_data[1] == 1'b1) ? DONE : STOP;
            DONE:       next_state = IDLE;
            default:    next_state = IDLE;
        endcase
    end
    //??????
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data    <= 'b0;
            rx_done    <= 1'b0;
            data_error <= 1'b0;
        end else begin
            case (next_state)
                IDLE: begin
                    rx_data    <= 'b0;
                    rx_done    <= 1'b0;
                    data_error <= 1'b0;
                end
                START_BIT: begin
                    rx_data    <= 'b0;
                    rx_done    <= 1'b0;
                    data_error <= 1'b0;
                end
                DATA_RECE: begin
                    if (sample_clk & sample_clk_cnt == 4'd6) rx_data <= {sample_data[1], rx_data[WIDTH-1:1]};
                    else rx_data <= rx_data;
                    rx_done    <= 1'b0;
                    data_error <= 1'b0;
                end
                PARITY_BIT: begin
                    rx_data    <= rx_data;
                    rx_done    <= 1'b0;
                    data_error <= (sample_clk_cnt == 4'd8) ? (^rx_data ^ sample_data[1]) : data_error;
                end
                STOP: begin
                    rx_data    <= rx_data;
                    rx_done    <= 1'b0;
                    data_error <= data_error;
                end
                DONE: begin
                    data_error <= data_error;
                    rx_done    <= 1'b1;  //????
                    rx_data    <= rx_data;
                end
                default: begin
                    rx_data    <= rx_data;
                    rx_done    <= 1'b0;
                    data_error <= data_error;
                end
            endcase
        end
    end

    rxd_clk #(
        .CLK_FREQUENCE(CLK_FREQUENCE),
        .BPS(BPS)
    ) rxd_clk_inst (
        .clk       (clk),
        .rst_n     (rst_n),
        .rx_start  (frame_en),
        .rx_done   (rx_done),
        .sample_clk(sample_clk)
    );

    //???????????
    function integer log2(input integer v);
        begin
            log2 = 0;
            while (v >> log2) begin
                log2 = log2 + 1;  //?????????????0
            end
        end
    endfunction
endmodule
