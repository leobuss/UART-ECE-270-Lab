`timescale 1ms/10ps

module stopwatch_tb();

    logic clk, rst, en, start;
    logic [5:0] hours, minutes, seconds;

    stopwatch dut (.clk(clk), .reset(rst), .en(en), .start(start), .hours(hours), .minutes(minutes),
        .seconds(seconds));


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
        $dumpfile("waves/stopwatch.vcd");
        $dumpvars(0, stopwatch_tb);

        clk = 0;
        rst = 0;
        en = 0;
        start = 0;

        #2
        reset();
        #2

        pulse_start();
        
        tick_seconds(5);
        
        pulse_start();
        #10
        pulse_start();
        
        tick_seconds(65);

        #50
        $finish;
    end

endmodule
