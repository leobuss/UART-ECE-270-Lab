module stopwatch(

    input logic clk, //clock
    input logic reset, //reset active high
    input logic start, // button to start/stop
    input logic [1:0] sel,
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
        
        if (start && sel != 2'd2) begin
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
