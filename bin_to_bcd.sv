`default_nettype none

// module to divide an input number into tens and ones digit
module bin_to_bcd(
    input  logic [6:0] num, 
    output logic [3:0] tens, // tens digit 
    output logic [3:0] ones // ones digit 
);

    always_comb begin
        logic [6:0] tmp;
        logic [6:0] t;

        tmp = num; 
        t   = 0;

  
        for (int i = 0; i < 10; i++) begin
            if (tmp >= 10) begin
                tmp = tmp - 10;
                t = t + 1;
            end
        end
        tens = t[3:0];
        ones = tmp[3:0];
    end
endmodule
