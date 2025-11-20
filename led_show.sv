module led_show(
    input logic clk,
    input logic reset,
    input logic [1:0] sel,
    input logic done,
    output logic [7:0] left_leds,
    output logic [7:0] right_leds

);
    logic [4:0] div_cnt;
    logic step;
    logic [4:0] pos;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            div_cnt <= 5'd0;
            step <= 1'b0;
        end
        else begin
            if (sel == 2'd2 && done) begin
                if (div_cnt == 5'd24) begin
                    div_cnt <= 5'd0;
                    step <= 1'b1;
                end
                else begin
                    div_cnt <= div_cnt + 5'd1;
                    step <= 1'b0;
                end
            end
            else begin
                div_cnt <= 5'd0;
                step <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            pos <= 5'd0;
        end
        else begin
            if (sel == 2'd2 && done) begin
                if (step) begin
                    if (pos == 5'd15)
                        pos <= 5'd0;
                    else
                        pos <= pos + 5'd1;
                end
            end
            else begin
                pos <= 5'd0;
            end
        end
    end

    always_comb begin
        left_leds = 8'b00000000;
        right_leds = 8'b00000000;

        if (sel == 2'd2 && done) begin
            case (pos)
                5'd0: left_leds = 8'b10000000;
                5'd1: left_leds = 8'b01000000;
                5'd2: left_leds = 8'b00100000;
                5'd3: left_leds = 8'b00010000;
                5'd4: left_leds = 8'b00001000;
                5'd5: left_leds = 8'b00000100;
                5'd6: left_leds = 8'b00000010;
                5'd7: left_leds = 8'b00000001;

                5'd8: right_leds = 8'b10000000;
                5'd9: right_leds = 8'b01000000;
                5'd10: right_leds = 8'b00100000;
                5'd11: right_leds = 8'b00010000;
                5'd12: right_leds = 8'b00001000;
                5'd13: right_leds = 8'b00000100;
                5'd14: right_leds = 8'b00000010;
                5'd15: right_leds = 8'b00000001;

                default: begin
                    left_leds = 8'b00000000;
                    right_leds = 8'b00000000;
                end
            endcase
        end
    end

endmodule
