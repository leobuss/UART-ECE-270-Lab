// module to smooth input signals
module pb_divider (
    input logic clk,
    input logic in,
    output logic out
);
    
  logic [4:0] count;
  initial begin
      count   = 5'd0;
      out = 1'b0;
  end

    
    always_ff @(posedge clk) begin
      if (count == 5'd24) begin
            count   <= 5'd0;
            out <= in;
        end
        else begin
            count   <= count + 5'd1;
            out <= 1'b0;
        end
    end
endmodule
