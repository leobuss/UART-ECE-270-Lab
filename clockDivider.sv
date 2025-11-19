
module clk_div_100(
    input  logic clk, // input clock
    output logic clk_out // divided clock output
);
    
    logic [6:0] count;
    initial begin
        count   = 7'd0;
        clk_out = 1'b0;
    end

    always_ff @(posedge clk) begin
        if (count == 7'd99) begin
            count   <= 7'd0;
            clk_out <= 1'b1;
        end
        else begin
            count   <= count + 7'd1;
            clk_out <= 1'b0;
        end
    end
    endmodule


