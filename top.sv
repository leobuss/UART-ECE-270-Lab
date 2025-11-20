module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);

logic [1:0] sel;

selectLatch gurt(.sel(pb[1:0]), .clk(hz100),.rst(pb[16]),.out(sel));

timer time(.sel(sel), .clk(hz100), .reset(pb[16]), .inc(pb[5]), .dec(pb[4]), .state(pb[6]), .); //finish tmrw




endmodule