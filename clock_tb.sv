`timescale 1ms/10ps

module clock_tb();

    logic clk, rst, inc, dec, state;
    logic [1:0] sel;
    logic [5:0] hours, minutes, seconds;
    logic [6:0] milliseconds;

    clock kcolc (.clk(clk), .reset(rst), .sel(sel), .inc(inc), .dec(dec), .state(state),
                 .hours(hours), .minutes(minutes), .seconds(seconds), .milliseconds(milliseconds));

    always begin
        #1
        clk = ~clk;
    end

    task reset();
        begin
            @(negedge clk);
            rst = 0;
            @(negedge clk);
            rst = 1;
            @(negedge clk);
            rst = 0;
        end
    endtask

    // pulse the state button to cycle
    task pulse_state();
        begin
            @(negedge clk);
            state = 0;
            @(negedge clk);
            state = 1;
            @(negedge clk);
            state = 0;
        end
    endtask

    // single increment pulse
    task pulse_inc();
        begin
            @(negedge clk);
            inc = 0;
            @(negedge clk);
            inc = 1;
            @(negedge clk);
            inc = 0;
        end
    endtask

    // single decrement pulse
    task pulse_dec();
        begin
            @(negedge clk);
            dec = 0;
            @(negedge clk);
            dec = 1;
            @(negedge clk);
            dec = 0;
        end
    endtask

    task tick_seconds(input integer n);
        integer i, j;
        begin
            for (i = 0; i < n; i = i + 1) begin
                for (j = 0; j < 100; j = j + 1) begin
                    @(negedge clk);
                end
            end
        end
    endtask

    initial begin
        $dumpfile("clock.vcd");
        $dumpvars(0, clock_tb);

        clk = 0;
        rst = 0;
        inc = 0;
        dec = 0;
        state = 0;
        sel = 2'd1;

        // reset clock, mode starts in HOURS
        #2
        reset();
        #2

        // adjust hours
        pulse_inc();
        pulse_inc();
        pulse_inc();

        // go to minutes mode
        pulse_state();
        pulse_inc();
        pulse_inc();   // minutes = 2
        // go to clock mode 
        pulse_state();
        tick_seconds(65);

        

        #50
        $finish;
    end

endmodule

//agartha has been found
