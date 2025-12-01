// change number into a seg7 capable output
module hex2seg7 (
    input  logic [3:0] hex,
    output logic [6:0] seg
);
    always_comb begin
        unique case (hex)
   4'd0 : begin seg = 7'b0111111; end
            4'd1 : begin seg = 7'b0000110; end
            4'd2 : begin seg = 7'b1011011; end
            4'd3 : begin seg = 7'b1001111; end
            4'd4 : begin seg = 7'b1100110; end
            4'd5 : begin seg = 7'b1101101; end
            4'd6 : begin seg = 7'b1111101; end
            4'd7 : begin seg = 7'b0000111; end
            4'd8 : begin seg = 7'b1111111; end
            4'd9 : begin seg = 7'b1100111; end
            4'hA : begin seg = 7'b1110111; end
            4'hB : begin seg = 7'b1111100; end
            4'hC : begin seg = 7'b0111001; end
            4'hD : begin seg = 7'b1011110; end
            4'hE : begin seg = 7'b1111001; end
            4'hF : begin seg = 7'b1110001; end
            default: begin seg = 7'd0; end
        endcase
    end
endmodule
