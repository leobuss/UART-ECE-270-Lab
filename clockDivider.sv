
module clk_div_100(
    input  logic clk, // input clock
    input  logic reset, // ACTIVE-HIGH reset
    output logic clk_out // divided clock output
);

    
    logic [6:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count   <= 7'd0;
            clk_out <= 1'b0;
        end
        else begin
            if (count == 7'd99) begin
                count   <= 7'd0;
                clk_out <= 1'b1;
            end
            else begin
                count   <= count + 7'd1;
                clk_out <= 1'b0;
            end
        end
    end
    endmodule

