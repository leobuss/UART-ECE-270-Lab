`timescale 1ms/10ps

module stopwatch_tb();

    logic clk, rst, start;
    logic [1:0] sel;
    logic [5:0] hours, minutes, seconds;
    logic [6:0] milliseconds;

    stopwatch watchstop (.clk(clk), .reset(rst), .start(start), .sel(sel),
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
        $dumpfile("waves/stopwatch.vcd");
        $dumpvars(0, stopwatch_tb);

        clk = 0;
        rst = 0;
        start = 0;
        sel = 2'd1;

        #2
        reset();
        #2

        pulse_start();
        
        tick_seconds(5);
        
        pulse_start();
        #10
        pulse_start();
        
        tick_seconds(200);

        #50
        $finish;
    end

endmodule

