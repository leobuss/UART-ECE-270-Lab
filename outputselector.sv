module outputSelect(
input logic [3:0] timer,
input logic [3:0] clock,
input logic [3:0] stopwatch, 
input logic [1:0] select,
output logic [3:0] out);
always @(timer, clock, stopwatch, select) begin
if (select == 2'b01)begin
out = timer;
end
else if (select == 2'b10) begin
out = clock; end
else if (select == 2'b11) begin
out = stopwatch; end
else begin out = 3'b000; end
end
endmodule