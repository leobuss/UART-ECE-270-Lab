module selectLatch(
    input logic [1:0] sel, //pb 1:0
    input logic clk, rst,
    output logic [1:0] out //out
);

logic [1:0] n_out;

always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
        out => 2'd1;
    end else begin
        out => n_out;
    end
end 

always_comb begin
    if (sel = 2'd0) begin
        n_out = out;
    end else begin
        n_out = sel;
    end
end




endmodule
