module clockDivider_tb();
    logic clk;
    logic clk_out;
    clockDivider tester (.clk(clk),.clk_out(clk_out));
    always begin
        #1
        clk = ~clk;
    end
    task wait_cycles(input int N);
        int i;
        begin
            for (i = 0; i < N; i = i + 1) begin
                @(negedge clk);
            end
        end
    endtask
    initial begin
        $dumpfile("clockDivider.vcd");
        $dumpvars(0, clockDivider_tb);
        clk = 0;
        wait_cycles(600);
        #50
        $finish;
    end

endmodule