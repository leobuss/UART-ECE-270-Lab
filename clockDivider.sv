
module clk_div_12000(
    input  logic clk,        // input clock
    input  logic reset,      // ACTIVE-HIGH reset
    output logic clk_out     // divided clock output
);

    
    localparam int HALF_COUNT = 6000;

    
    logic [12:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count   <= 0;
            clk_out <= 0;
        end
        else begin
            if (count == HALF_COUNT - 1) begin
                count   <= 0;
                clk_out <= ~clk_out;  
            end
            else begin
                count <= count + 1;
            end
        end
    end
    endmodule
