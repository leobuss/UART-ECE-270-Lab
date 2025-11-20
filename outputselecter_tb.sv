module outputSelect_tb();    
    logic [3:0] timer;
    logic [3:0] clock;
    logic [3:0] stopwatch;
    logic [1:0] select;
    logic [3:0] out;
    outputSelect dut (.timer(timer),.clock(clock),
   .stopwatch(stopwatch),.select(select),.out(out));
    task apply_test(
        input logic [3:0] t_val,
        input logic [3:0] c_val,
        input logic [3:0] s_val,
        input logic [1:0] sel_val
    );
    begin
        timer = t_val;
        clock = c_val;
        stopwatch = s_val;
        select = sel_val;
        #2;  
    end
    endtask
    initial begin
        $dumpfile("outputSelect.vcd");
        $dumpvars(0, outputSelect_tb);
        timer = 4'd0;
        clock = 4'd0;
        stopwatch = 4'd0;
        select = 2'b00;
        apply_test(4'b0101, 4'b1111, 4'b0011, 2'b01);   
        apply_test(4'b0101, 4'b1010, 4'b0011, 2'b10);
        apply_test(4'b0101, 4'b1010, 4'b0110, 2'b11);
        apply_test(4'b0101, 4'b1010, 4'b0110, 2'b00);
        #20;
        $finish;
    end
endmodule