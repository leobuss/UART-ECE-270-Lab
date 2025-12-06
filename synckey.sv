// not used
module synckey(
    input logic [19:0] bin,
    output logic [4:0] bout,
    input logic clk, rst,
    output logic strobe
);



logic [4:0] high, n_out;
logic initStrobe;
logic Q;


always_ff @(posedge clk, posedge rst) begin

    if(rst) begin 
        Q <=0;
        strobe <= 0;
        bout <= 0;
    end
    else begin
        bout <= n_out;
        Q<=initStrobe;
        strobe <= Q;
    end

end

always_comb begin   

    initStrobe = |bin;
    high = 5'd0;

    //bout = 5'd0;
    for(int i = 0; i<20; i++) begin
        if(bin[i]) begin
            high = i[4:0];
            
        end
    end

    n_out = high;

end

endmodule