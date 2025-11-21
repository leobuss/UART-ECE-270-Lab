`default_nettype none

module display(
    input logic [5:0] clk_hours, clk_minutes, clk_seconds,
    input logic [6:0] sw_milliseconds,
    input logic [5:0] tmr_hours, tmr_minutes, tmr_seconds,
    input logic [5:0] sw_hours, sw_minutes, sw_seconds,
    input logic [1:0] sel,
    input logic clk,
    output logic [7:0] hours_tens_ss7,
    output logic [7:0] hours_ones_ss7,
    output logic [7:0] minutes_tens_ss7,
    output logic [7:0] minutes_ones_ss7,
    output logic [7:0] seconds_tens_ss7,
    output logic [7:0] seconds_ones_ss7,
    output logic [7:0] milliseconds_ones_ss7,
    output logic [7:0] milliseconds_tens_ss7
);

    logic [5:0] disp_hours, disp_minutes, disp_seconds;
    logic [6:0] disp_milliseconds;

    always_comb begin
        unique case (sel)
            2'b01: begin
                disp_hours = clk_hours;
                disp_minutes = clk_minutes;
                disp_seconds = clk_seconds;
                disp_milliseconds = 7'd0;
            end
            2'b10: begin
                disp_hours = tmr_hours;
                disp_minutes = tmr_minutes;
                disp_seconds = tmr_seconds;
                disp_milliseconds = 7'd0;
            end
            2'b11: begin
                disp_hours = sw_hours;
                disp_minutes = sw_minutes;
                disp_seconds = sw_seconds;
                disp_milliseconds = sw_milliseconds;
            end
            default: begin
                disp_hours = clk_hours;
                disp_minutes = clk_minutes;
                disp_seconds = clk_seconds;
                disp_milliseconds = 7'd0;
            end
        endcase
    end

    logic [3:0] hours_tens_bcd, hours_ones_bcd;
    logic [3:0] minutes_tens_bcd, minutes_ones_bcd;
    logic [3:0] seconds_tens_bcd, seconds_ones_bcd;
    logic [3:0] ms_tens_bcd, ms_ones_bcd;

    bin_to_bcd bcd_hours(.num({1'b0, disp_hours}), .tens(hours_tens_bcd), .ones(hours_ones_bcd));

    bin_to_bcd bcd_minutes(.num({1'b0, disp_minutes}),.tens(minutes_tens_bcd), .ones(minutes_ones_bcd));

    bin_to_bcd bcd_seconds(.num({1'b0, disp_seconds}), .tens(seconds_tens_bcd), .ones(seconds_ones_bcd));

    bin_to_bcd bcd_milliseconds(.num(disp_milliseconds), .tens(ms_tens_bcd), .ones(ms_ones_bcd));

    logic [6:0] h_tens_seg, h_ones_seg;
    logic [6:0] m_tens_seg, m_ones_seg;
    logic [6:0] s_tens_seg, s_ones_seg;
    logic [6:0] ms_tens_seg, ms_ones_seg;

    hex2seg7 h_tens(.hex(hours_tens_bcd), .seg(h_tens_seg));

    hex2seg7 h_ones(.hex(hours_ones_bcd), .seg(h_ones_seg));

    hex2seg7 m_tens(.hex(minutes_tens_bcd), .seg(m_tens_seg));

    hex2seg7 m_ones(.hex(minutes_ones_bcd), .seg(m_ones_seg));

    hex2seg7 s_tens(.hex(seconds_tens_bcd), .seg(s_tens_seg));

    hex2seg7 s_ones (.hex(seconds_ones_bcd), .seg(s_ones_seg));

    hex2seg7 ms_tens (.hex(ms_tens_bcd), .seg(ms_tens_seg));

    hex2seg7 ms_ones (.hex(ms_ones_bcd), .seg(ms_ones_seg));

    assign hours_tens_ss7 = {1'b0, h_tens_seg};
    assign hours_ones_ss7 = {1'b1, h_ones_seg};
    assign minutes_tens_ss7 = {1'b0, m_tens_seg};
    assign minutes_ones_ss7 = {1'b1, m_ones_seg};
    assign seconds_tens_ss7 = {1'b0, s_tens_seg};
    assign seconds_ones_ss7 = {1'b1, s_ones_seg};
    assign milliseconds_tens_ss7 = {1'b0, ms_tens_seg};
    assign milliseconds_ones_ss7 = {1'b0, ms_ones_seg};

endmodule


// agartha is ours!
