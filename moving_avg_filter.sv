module moving_avg_filter #(
  parameter WIND_DEPTH = 16,
  parameter DATA_WIDTH = 16
) (
  input  logic clk,
  input  logic reset,
  input  logic [DATA_WIDTH-1:0] x_N,
  input  logic x_N_valid,
  output logic [DATA_WIDTH-1:0] y_N,
  output logic y_N_valid
);

endmodule
