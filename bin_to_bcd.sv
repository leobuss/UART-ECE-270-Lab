`default_nettype none

module bin_to_bcd(
    input  logic [6:0] num, // 0 to 99
    output logic [3:0] tens, // tens digit 0–9
    output logic [3:0] ones // ones digit 0–9
);

    always_comb begin
        integer tmp;
        integer t;

        tmp = num;   // copy of input
        t   = 0;

        // subtract 10 as many times as possible, up to 9 times
        // no division or modulus, fully synthesizable
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
