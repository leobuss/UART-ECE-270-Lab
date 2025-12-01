
`default_nettype none
module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

logic [1:0] sel; //signal outputed from selectLatch

logic [5:0] timer_h, timer_min, timer_s, 
            stopwatch_h, stopwatch_min, stopwatch_s,
            clock_h, clock_min, clock_s;


logic [6:0] milliseconds;

logic timer_d, strobe;

logic [19:0] buttons;

// logic [4:0] bout;

logic inc_div, dec_div, pb6, pb7;

assign buttons = pb[19:0];


// encoder encode(.in(bout), .out(buttons));

// synckey debounce(.bin(pb[19:0]), .bout(bout), .clk(hz100), .rst(buttons[16]), .strobe(red));
  
  // Selects which output to show (and be affected by inputs)
selectLatch gurt(.sel(buttons[2:0]), .clk(hz100),.rst(buttons[16]),.out(sel));

// show current selection
assign left[1:0] = sel;

  // Make it so the inputs only read one tick per .25 seconds (makes adjustment easier)
pb_divider inc_divide(.clk(hz100), .in(buttons[6]), .out(pb6));
pb_divider inc_divir(.clk(hz100), .in(buttons[7]), .out(pb7));
pb_divider inc_divider(.clk(hz100), .in(buttons[5]), .out(inc_div));
pb_divider dec_divider(.clk(hz100), .in(buttons[4]), .out(dec_div));

// instantiate timer module
timer tierer(.sel(sel), .clk(hz100), .reset(buttons[16]), .inc(inc_div), .dec(dec_div), .start(pb7),
            .state (pb6), .hours(timer_h), .minutes(timer_min),.seconds(timer_s), .done(timer_d)); 
// instantiate clock module
clock cloc(.clk(hz100), .reset(buttons[16]), .inc(inc_div), .dec(dec_div), 
          .state(pb6), .sel(sel), .hours(clock_h), .minutes(clock_min),
          .seconds(clock_s));
// instantiate stopwatch module
stopwatch watch(.clk(hz100), .reset(buttons[16]), .start(pb6), .sel(sel), .hours(stopwatch_h),
                .minutes(stopwatch_min), .seconds(stopwatch_s), .milliseconds(milliseconds));

//led_show soStylish(.clk(hz100), .reset(buttons[16]), .sel(sel), .done(timer_d), .left_leds(left[7:0]),
                  //  .right_leds(right[7:0]));
// instantiate display module
display showItOff(
    .clk_hours     (clock_h), 
    .clk_minutes   (clock_min),
    .clk_seconds   (clock_s),
    .sw_milliseconds (milliseconds),
    .tmr_hours     (timer_h),
    .tmr_minutes   (timer_min),
    .tmr_seconds   (timer_s),
    .sw_hours      (stopwatch_h),
    .sw_minutes    (stopwatch_min),
    .sw_seconds    (stopwatch_s),
    .sel           (sel),
    .rst         (buttons[16]),
    .hours_tens_ss7      (ss7),
    .hours_ones_ss7      (ss6),
    .minutes_tens_ss7    (ss5),
    .minutes_ones_ss7    (ss4),
    .seconds_tens_ss7    (ss3),
    .seconds_ones_ss7    (ss2),
    .milliseconds_ones_ss7 (ss0),
    .milliseconds_tens_ss7 (ss1)
);
endmodule

// timer module
module timer(
    input logic clk, //clock
    input logic reset, //reset active high
    input logic inc, dec, // either increase or decrease
    input logic state, // button to increment mode or clear expired time
    input logic start, // button to start/stop
    input logic [1:0] sel, // needs to be 10 in order for anything to run in this module 
    output logic [5:0] hours, // hours place
    output logic [5:0] minutes, // minutes plalce
    output logic [5:0] seconds, // seconds place
    //output logic [6:0] milliseconds, // decimal places
    output logic done // 1 when timer has expired
);

    logic [6:0] milliseconds;

    typedef enum logic [1:0] {HOURS, MINUTES, CLOCK} mode_t;
    typedef enum logic [1:0] {STOPPED, RUNNING, EXPIRED} run_t;

    mode_t mode, next_mode;
    run_t run_state, next_run_state;

    logic [5:0] next_hours, next_minutes, next_seconds;
    logic [6:0] next_milliseconds;
    logic next_done;
    
    //flip flop
    always_ff @ (posedge clk, posedge reset) begin
        if (reset) begin
            hours <= 6'd0;
            minutes <= 6'd0;
            seconds <= 6'd0;
            milliseconds <= 7'd0;
            mode <= HOURS;   
            run_state <= STOPPED;
            done <= 1'b0;
        end
        else begin
            hours <= next_hours;
            minutes <= next_minutes;
            seconds <= next_seconds;
            milliseconds <= next_milliseconds;
            mode <= next_mode;
            run_state <= next_run_state;
            done <= next_done;
        end
    end
    
    // combinational logic
    always_comb begin
        next_hours = hours;
        next_minutes = minutes;
        next_seconds = seconds;
        next_milliseconds = milliseconds;
        next_mode = mode;
        next_run_state = run_state;
        next_done = done;
        
        
        if (state && run_state != RUNNING && run_state != EXPIRED && sel == 2'd2) begin
            case (mode)
                HOURS: next_mode = MINUTES;
                MINUTES: next_mode = CLOCK;
                CLOCK: next_mode = HOURS;
                default: next_mode = HOURS;
            endcase
        end
        
        // startstop toggle only when not expired
        if (start && mode == CLOCK && run_state != EXPIRED && sel == 2'd2) begin
            case (run_state)
                STOPPED: next_run_state = RUNNING;
                RUNNING: next_run_state = STOPPED;
                default: next_run_state = STOPPED;
            endcase
        end


        if (run_state == EXPIRED && sel == 2'd2) begin
            if (state) begin
                next_mode = HOURS;
                next_run_state = STOPPED;
                next_done = 1'b1;
            end
        end


        if (run_state == STOPPED && run_state != EXPIRED && sel == 2'd2) begin
            if (mode == HOURS) begin
                if (inc) begin
                    next_done = 1'b0;
                    if (hours == 6'd23)
                        next_hours = 6'd0;
                    else 
                        next_hours = hours + 6'd1;
                end
                else if (dec) begin
                    next_done = 1'b0;
                    if (hours == 6'd0)
                        next_hours = 6'd23;
                    else 
                        next_hours = hours - 6'd1;
                end
            end
            
            if (mode == MINUTES) begin
                if (inc) begin
                    next_done = 1'b0;
                    if (minutes == 6'd59)
                        next_minutes = 6'd0;
                    else 
                        next_minutes = minutes + 6'd1;
                end
                else if (dec) begin
                    next_done = 1'b0;
                    if (minutes == 6'd0)
                        next_minutes = 6'd59;
                    else 
                        next_minutes = minutes - 6'd1;
                end
            end
        end
         if (mode == CLOCK && run_state == RUNNING && sel == 2'd2) begin
            // already at zero
            if (hours == 6'd0 && minutes == 6'd0 && seconds == 6'd0 && milliseconds == 7'd0) begin
                next_run_state = EXPIRED;
                next_done = 1'b1;
            end
            else begin
                // decrement 0.01s
                if (milliseconds == 7'd0) begin
                    next_milliseconds = 7'd99;
                    if (seconds == 6'd0) begin
                        next_seconds = 6'd59;
                        if (minutes == 6'd0) begin
                            next_minutes = 6'd59;
                            if (hours == 6'd0)
                                next_hours = 6'd0;
                            else
                                next_hours = hours - 6'd1;
                        end
                        else
                            next_minutes = minutes - 6'd1;
                    end
                    else
                        next_seconds = seconds - 6'd1;
                end
                else begin
                    next_milliseconds = milliseconds - 7'd1;
                end
                
                // if next value is 0 go to expired
                if (next_hours == 6'd0 && next_minutes == 6'd0 &&
                    next_seconds == 6'd0 && next_milliseconds == 7'd0) begin
                    next_run_state = EXPIRED;
                    next_done = 1'b1;
                end
            end
        end
    end
endmodule

// module to smooth input signals
module pb_divider (
    input logic clk,
    input logic in,
    output logic out
);
    
  logic [4:0] count;
  initial begin
      count   = 5'd0;
      out = 1'b0;
  end

    
    always_ff @(posedge clk) begin
      if (count == 5'd24) begin
            count <= 5'd0;
            out <= in;
        end
        else begin
            count <= count + 5'd1;
            out <= 1'b0;
        end
    end
endmodule






// module to divide an input number into tens and ones digit
module bin_to_bcd(
    input  logic [6:0] num, 
    output logic [3:0] tens, // tens digit 
    output logic [3:0] ones // ones digit 
);

    always_comb begin
        logic [6:0] tmp;
        logic [6:0] t;

        tmp = num; 
        t   = 0;

  
        for (int i = 0; i < 10; i++) begin
            if (tmp >= 10) begin
                tmp = tmp - 10;
                t = t + 1;
            end
        end
        tens = t[3:0];
        ones = tmp[3:0];
    end
endmodule

// clock module
module clock(

    input logic clk, //clock
    input logic reset, //reset active high
    input logic inc, dec, // either increase of decrease //buttons5, buttons4    
    input logic state, // button to increment state //buttons6
    input logic [1:0] sel,  // buttons 1:0
    output logic [5:0] hours, // hours place
    output logic [5:0] minutes, // minutes plalce
    output logic [5:0] seconds // seconds place
    //output logic [6:0] milliseconds // milliseconds placee
    

);

    logic [6:0] milliseconds; // milliseconds placee

    // local variables
    typedef enum logic [1:0] {HOURS, MINUTES, CLOCK} mode_t;
    logic [5:0] next_hours, next_minutes, next_seconds;
    logic [6:0] next_milliseconds;
    mode_t mode, next_mode;
    
    //flip flop
    always_ff @ (posedge clk, posedge reset) begin
        if (reset) begin
            hours <= 6'd0;
            minutes <= 6'd0;
            seconds <= 6'd0;
            milliseconds <= 7'd0;
            mode <= HOURS;
        end
        else begin
            hours <= next_hours;
            minutes <= next_minutes;
            seconds <= next_seconds;
            milliseconds <= next_milliseconds;
            mode <= next_mode;
        end
    end
    
    // combinational logic
    always_comb begin
        // defaults (should never happen)
        next_hours = hours;
        next_minutes = minutes;
        next_seconds = seconds;
        next_milliseconds = milliseconds;
        next_mode = mode;
        
        // chnage  mode
        if (state && sel == 2'd1) begin
            case (mode)
                HOURS: next_mode = MINUTES;
                MINUTES: next_mode = CLOCK;
                CLOCK: next_mode = HOURS;
                default: next_mode = CLOCK;
            endcase
        end
        
        if (sel == 2'd1) begin
        // handle changing hour place
        if (mode == HOURS) begin
            if (inc) begin
                if (hours == 6'd23) //gurt yo!
                    next_hours = 6'd0;
                else 
                    next_hours = hours + 6'd1;
            end
            else if (dec) begin
                if (hours == 6'd0)
                    next_hours = 6'd23;
                else 
                    next_hours = hours - 6'd1;
            end
        end
        
        // handle changing minutes place
        if (mode == MINUTES) begin
            if (inc) begin
                if (minutes == 6'd59)
                    next_minutes = 6'd0;
                else 
                    next_minutes = minutes + 6'd1;
            end
            else if (dec) begin
                if (minutes == 6'd0)
                    next_minutes = 6'd59;
                else 
                    next_minutes = minutes - 6'd1;
            end
        end
        end
        // otherwise, increment clock, handling any overflow
        if (mode == CLOCK) begin
            if (milliseconds == 7'd99) begin
                next_milliseconds = 7'd0;
                if (seconds == 6'd59) begin
                    next_seconds = 6'd0;
                    if (minutes == 6'd59) begin
                        next_minutes = 6'd0;
                        if (hours == 6'd23)
                            next_hours = 6'd0;
                        else
                            next_hours = hours + 6'd1;
                    end
                    else
                        next_minutes = minutes + 6'd1;
                end
                else
                    next_seconds = seconds + 6'd1;
            end
            else
                next_milliseconds = milliseconds + 7'd1;
        end
    end
endmodule

// module to deal with displaying on the 7seg display
module display(
    input logic [5:0] clk_hours, clk_minutes, clk_seconds,
    input logic [6:0] sw_milliseconds,
    input logic [5:0] tmr_hours, tmr_minutes, tmr_seconds,
    input logic [5:0] sw_hours, sw_minutes, sw_seconds,
    input logic [1:0] sel,
    input logic rst,
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


// change number into a seg7 capable output
module hex2seg7 (
    input  logic [3:0] hex,
    output logic [6:0] seg
);
    always_comb begin
        unique case (hex)
   4'd0 : begin seg = 7'b0111111; end
            4'd1 : begin seg = 7'b0000110; end
            4'd2 : begin seg = 7'b1011011; end
            4'd3 : begin seg = 7'b1001111; end
            4'd4 : begin seg = 7'b1100110; end
            4'd5 : begin seg = 7'b1101101; end
            4'd6 : begin seg = 7'b1111101; end
            4'd7 : begin seg = 7'b0000111; end
            4'd8 : begin seg = 7'b1111111; end
            4'd9 : begin seg = 7'b1100111; end
            4'hA : begin seg = 7'b1110111; end
            4'hB : begin seg = 7'b1111100; end
            4'hC : begin seg = 7'b0111001; end
            4'hD : begin seg = 7'b1011110; end
            4'hE : begin seg = 7'b1111001; end
            4'hF : begin seg = 7'b1110001; end
            default: begin seg = 7'd0; end
        endcase
    end
endmodule

// LED show to alert that timer is done, not implemented
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

// depending on input, change the current display signal (if no input, remain same)
module selectLatch(
    input logic [2:0] sel, //buttons 1:0
    input logic clk, rst,
    output logic [1:0] out //out
);

typedef enum logic [1:0] {STOPWATCH = 2'b11, TIMER=2'd2, CLOCK=2'd1} state_t;
state_t state, next_state;


always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        state <= CLOCK;
    end else begin
        state <= next_state;
    end
end 

always_comb begin
    next_state = state;
    if (sel == 3'd1) begin
        next_state = CLOCK;
    end else if(sel == 3'd2) begin
        next_state = TIMER;
    end else if(sel == 3'd4) begin
        next_state = STOPWATCH;
    end

    out = state;
end




endmodule

// stopwatch module
module stopwatch(

    input logic clk, //clock
    input logic reset, //reset active high
    input logic start, // button to start/stop
    input logic [1:0] sel, //must be 3
    output logic [5:0] hours, // hours place
    output logic [5:0] minutes, // minutes plalce
    output logic [5:0] seconds, // seconds place
    output logic [6:0] milliseconds // milliseconds
    

);


    typedef enum logic [1:0] {STOPPED, RUNNING} mode_t;
    logic [5:0] next_hours, next_minutes, next_seconds;
    logic [6:0] next_milliseconds;
    mode_t mode, next_mode;
    
    
    always_ff @ (posedge clk or posedge reset) begin
        if (reset) begin
            hours <= 6'd0;
            minutes <= 6'd0;
            seconds <= 6'd0;
            milliseconds <= 7'd0;
            mode <= STOPPED;
        end
        else begin
            hours <= next_hours;
            minutes <= next_minutes;
            seconds <= next_seconds;
            milliseconds <= next_milliseconds;
            mode <= next_mode;
        end
    end   
    
    always_comb begin
        next_hours = hours;
        next_minutes = minutes;
        next_seconds = seconds;
        next_milliseconds = milliseconds;
        next_mode = mode;
        
        if (start && sel == 2'd3) begin
            case (mode)
                STOPPED: next_mode = RUNNING;
                RUNNING: next_mode = STOPPED;
                default: next_mode = STOPPED;
            endcase
        end
        
        if (mode == RUNNING) begin
            // freeze at max
            if (hours == 6'd23 && minutes == 6'd59 &&
                seconds == 6'd59 && milliseconds == 7'd99) begin
                // do nothing
            end
            else if (milliseconds == 7'd99) begin
                next_milliseconds = 7'd0;
                if (seconds == 6'd59) begin
                    next_seconds = 6'd0;
                    if (minutes == 6'd59) begin
                        next_minutes = 6'd0;
                        if (hours == 6'd23)
                            next_hours = 6'd23; // unreachable because of freeze check
                        else
                            next_hours = hours + 6'd1;
                    end
                    else
                        next_minutes = minutes + 6'd1;
                end
                else begin
                    next_seconds = seconds + 6'd1;
                end
            end
            else begin
                next_milliseconds = milliseconds + 7'd1;
            end
        end
    end
endmodule

// not used
module encoder (
    input  logic [4:0]  in,
    output logic [19:0] out
);

    always_comb begin
        case (in)
            5'd0 : out = 20'b00000000000000000001;
            5'd1 : out = 20'b00000000000000000010;
            5'd2 : out = 20'b00000000000000000100;
            5'd3 : out = 20'b00000000000000001000;
            5'd4 : out = 20'b00000000000000010000;
            5'd5 : out = 20'b00000000000000100000;
            5'd6 : out = 20'b00000000000001000000;
            5'd7 : out = 20'b00000000000010000000;
            5'd8 : out = 20'b00000000000100000000;
            5'd9 : out = 20'b00000000001000000000;
            5'd10: out = 20'b00000000010000000000;
            5'd11: out = 20'b00000000100000000000;
            5'd12: out = 20'b00000001000000000000;
            5'd13: out = 20'b00000010000000000000;
            5'd14: out = 20'b00000100000000000000;
            5'd15: out = 20'b00001000000000000000;
            5'd16: out = 20'b00010000000000000000;
            5'd17: out = 20'b00100000000000000000;
            5'd18: out = 20'b01000000000000000000;
            5'd19: out = 20'b10000000000000000000;
            default: out = 20'd0;
        endcase
    end

endmodule

// not used
module synckey(
    input logic [19:0] bin,
    output logic [4:0] bout,
    input logic clk, rst,
    output logic strobe
);



logic [4:0] high, n_out;
logic initStrobe;
logic Q;


always_ff @(posedge clk, posedge rst) begin

    if(rst) begin 
        Q <=0;
        strobe <= 0;
        bout <= 0;
    end
    else begin
        bout <= n_out;
        Q<=initStrobe;
        strobe <= Q;
    end

end

always_comb begin   

    initStrobe = |bin;
    high = 5'd0;

    //bout = 5'd0;
    for(int i = 0; i<20; i++) begin
        if(bin[i]) begin
            high = i[4:0];
            
        end
    end

    n_out = high;

end

endmodule

/*
I met a traveller from an antique land,
Who said—“Two vast and trunkless legs of stone
Stand in the desert.... Near them, on the sand,
Half sunk a shattered visage lies, whose frown,
And wrinkled lip, and sneer of cold command,
Tell that its sculptor well those passions read
Which yet survive, stamped on these lifeless things,
The hand that mocked them, and the heart that fed;
And on the pedestal, these words appear:
My name is Ozymandias, King of Kings;
Look on my Works, ye Mighty, and despair!"
Nothing beside remains. Round the decay
Of that colossal Wreck, boundless and bare
The lone and level sands stretch far away.
*/
