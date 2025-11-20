// greetings traveller, you have found our testbench for timer.sv! enjoy yourself while reading this amazing code
`timescale 1ms/10ps
module timer_tb();

    logic clk, rst, inc, dec, state, start;
    logic [1:0] sel;
    logic [5:0] hours, minutes, seconds;
    logic [6:0] milliseconds;
    logic done;

  timer remit (.clk(clk), .reset(rst), .inc(inc), .dec(dec), .state(state), .start(start), .sel(sel), .hours(hours),
                .minutes(minutes), .seconds(seconds), .milliseconds(milliseconds), .done(done));
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

    // pulse the state button to cycle modes or clear expired
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

    // start/stop toggle
    task pulse_start();
        begin
            @(negedge clk);
            start = 0;
            @(negedge clk);
            start = 1;
            @(negedge clk);
            start = 0;
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

    // let the timer run for n seconds
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
        $dumpfile("timer.vcd");
        $dumpvars(0, timer_tb);

        clk = 0;
        rst = 0;
        inc = 0;
        dec = 0;
        state = 0;
        start = 0;
        sel = 2'd2;   // enable timer module

        // reset timer
        #2
        reset();
        #2

        // set 1 minute countdown
        pulse_state();
        pulse_inc();

        // go to CLOCK mode
        pulse_state();

        // start countdown
        pulse_start();

        // let it run long enough to expire
        tick_seconds(65);

        // clear expired
        pulse_state();

        pulse_inc();
        pulse_state(); 
        pulse_inc();

        // searching for agartha
        pulse_state();
        pulse_start();
        tick_seconds(5);

        #50
        $finish;
    end

endmodule
