// 2Stage pipelined FIR Filter Inverse Structure
// y(n) = x(n)*w(0) + x(n-1)*w(1) + x(n-2)*w(2) + x(n-3)*w(3)
module fir_filter #(
  parameter TAPS = 4,
  parameter DATA_WIDTH = 16
) (
  input  logic clk,
  input  logic [DATA_WIDTH-1:0] x_N,
  input  logic [DATA_WIDTH-1:0] w_N[TAPS],
  output logic [DATA_WIDTH-1:0] y_N
);
  
  logic [DATA_WIDTH-1:0] y_M[TAPS+1];
  logic [DATA_WIDTH-1:0] x_M[TAPS+1];
  
  assign x_M[0] = x_N;
  assign y_M[0] = {DATA_WIDTH{1'b0}};
  genvar i;
  generate for (i=1; i<=TAPS; i++) begin : gen
    fir_compute #(DATA_WIDTH) fir_stage_inst (
      .clk (clk),
      .x_N (x_M[i-1]),
      .w_N (w_N[i-1]),
      .y_M (y_M[i-1]),
      .x_M (x_M[i]),
      .y_N (y_M[i])
    );
  end endgenerate
  assign y_N = y_M[TAPS];
  
endmodule

module fir_compute #(
  parameter DATA_WIDTH = 16
) (
  input  logic clk,
  input  logic [DATA_WIDTH-1:0] x_N,
  input  logic [DATA_WIDTH-1:0] w_N,
  input  logic [DATA_WIDTH-1:0] y_M,
  output logic [DATA_WIDTH-1:0] x_M,
  output logic [DATA_WIDTH-1:0] y_N
);

  logic signed [1*DATA_WIDTH-1:0] reg_x_N;
  logic signed [1*DATA_WIDTH-1:0] reg_y_M;
  logic signed [1*DATA_WIDTH-1:0] reg_w_N;
  logic signed [2*DATA_WIDTH-1:0] reg_y_N;
  // pipeline inputs
  always_ff @(posedge clk) begin
    reg_x_N <= x_N;
    reg_y_M <= y_M;
    reg_w_N <= w_N;
  end
  // pipeline multiply-add outputs
  always_ff @(posedge clk) begin
    reg_y_N <= (reg_x_N * reg_w_N) + reg_y_M;
  end
  
  assign x_M = reg_x_N;
  assign y_N = reg_y_N[2*DATA_WIDTH-1:DATA_WIDTH] ^ reg_y_N[DATA_WIDTH-1:0];
  
endmodule
