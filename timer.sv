module timer(
    input logic clk, //clock
    input logic reset, //reset active high
    input logic inc, dec, // either increase or decrease
    input logic state, // button to increment mode or clear expired time
    input logic start, // button to start/stop
    input logic [1:0] sel, // needs to be 11 in order for anything to run in this module 
    output logic [5:0] hours, // hours place
    output logic [5:0] minutes, // minutes plalce
    output logic [5:0] seconds, // seconds place
    output logic [6:0] milliseconds, // decimal places
    output logic done // 1 when timer has expired
);

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
                next_done = 1'b0;
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


