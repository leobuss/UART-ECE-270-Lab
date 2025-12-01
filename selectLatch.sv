// depending on input, change the current display signal (if no input, remain same)
module selectLatch(
    input logic [2:0] sel, //buttons 1:0
    input logic clk, rst,
    output logic [1:0] out //out
);

typedef enum logic [1:0] {STOPWATCH = 2'b11, TIMER=2'd2, CLOCK=2'd1} state_t;
state_t state, next_state;


always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        state <= CLOCK;
    end else begin
        state <= next_state;
    end
end 

always_comb begin
    next_state = state;
    if (sel == 3'd1) begin
        next_state = CLOCK;
    end else if(sel == 3'd2) begin
        next_state = TIMER;
    end else if(sel == 3'd4) begin
        next_state = STOPWATCH;
    end

    out = state;
end




endmodule
