`timescale 1ms/10ps

module clock_tb();

    logic clk, rst, en, inc, dec, state;
    logic [5:0] hours, minutes, seconds;

    clock dut (.clk(clk), .reset(rst), .en(en), .inc(inc), .dec(dec), .state(state),
    .hours(hours), .minutes(minutes), .seconds(seconds));

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
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) begin
                @(negedge clk);
                en = 1;
                @(negedge clk);
                en = 0;
            end
        end
    endtask

    initial begin
        $dumpfile("clock.vcd");
        $dumpvars(0, clock_tb);

        clk = 0;
        rst = 0;
        en = 0;
        inc = 0;
        dec = 0;
        state = 0;

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
