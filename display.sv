// Urgent message from Yakub:
module display(
    input logic [5:0] clk_hours, clk_minutes, clk_seconds,
    input logic [6:0] sw_milliseconds,
    input logic [5:0] tmr_hours, tmr_minutes, tmr_seconds,
    input logic [5:0] sw_hours, sw_minutes, sw_seconds,
    input logic [1:0] sel,
    input logic clk, reset,
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
        case (sel)
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
                disp_milliseconds = clk_milliseconds;
            end
        endcase
    end

    logic [3:0] hours_tens_bcd, hours_ones_bcd;
    logic [3:0] minutes_tens_bcd, minutes_ones_bcd;
    logic [3:0] seconds_tens_bcd, seconds_ones_bcd;
    logic [3:0] milliseconds_tens_bcd, milliseconds_ones_bcd;
