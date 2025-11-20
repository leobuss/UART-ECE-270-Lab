module clock(

    input logic clk, //clock
    input logic reset, //reset active high
    input logic inc, dec, // either increase of decrease //pb5, pb4    
    input logic state, // button to increment state //pb6
    input logic [1:0] sel,  // pb 1:0
    output logic [5:0] hours, // hours place
    output logic [5:0] minutes, // minutes plalce
    output logic [5:0] seconds, // seconds place
    output logic [6:0] milliseconds // milliseconds placee
    

);

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
        if (state) begin
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
