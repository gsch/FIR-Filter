// SP-RAM based moving average filter
// y(n) = 1/WindowSize * SUM_WindowSize{x(n)}; 
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
  
  localparam WIND_WIDTH = $clog2(WIND_DEPTH);
  localparam MAVG_WIDTH = WIND_WIDTH + DATA_WIDTH;
  
  logic [DATA_WIDTH-1:0] x_N_int;
  logic [DATA_WIDTH-1:0] x_N_last;
  logic [MAVG_WIDTH-1:0] y_N_acc;
  logic [WIND_WIDTH-1:0] addr;
  logic window_valid;
  // assert when window get filled after reset
  always_ff @(posedge clk) begin
    if (reset) begin
      window_valid <= 1'b0;
    end else if (~window_valid && addr == WIND_DEPTH-1) begin
      window_valid <= 1'b1;
    end
  end
  // address generation to store previous x[N] samples
  always_ff @(posedge clk) begin
    if (reset) begin
      addr <= {WIND_WIDTH{1'b0}};
    end else if (x_N_valid) begin
      if (addr == WIND_DEPTH-1) begin
        addr <= {WIND_WIDTH{1'b0}};
      end else begin
        addr <= addr + 1'b1;
      end
    end
  end
  // RAM store previous x[N] samples
  moving_avg_sp_bram #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(WIND_WIDTH)
  ) moving_avg_sp_bram_inst (
    .clk  (clk),
    .we   (x_N_valid),
    .addr (addr),
    .din  (x_N),
    .dout (x_M)
  );
  // accumulates x[N] samples, ie. SUM_WindowSize{x(n)}
  always_ff @(posedge clk) begin
    if (x_N_valid) begin
      y_N_acc <= y_N_acc + x_N - x_N_int;
    end
  end
  assign x_N_int = window_valid ? x_N_last : {DATA_WIDTH{1'b0}};

endmodule
// Block RAM buliding blocks are RAMB36K or 2-RAMB18K
module moving_avg_sp_bram #(
  parameter DATA_WIDTH = 16, // > 16 need to use BRAM
  parameter ADDR_WIDTH = 4
  ) (
  input  logic clk,
  input  logic we,
  input  logic [ADDR_WIDTH-1:0] addr,
  input  logic [DATA_WIDTH-1:0] din,
  output logic [DATA_WIDTH-1:0] dout
  );
  
  (* ram_style = "block" *)
  logic [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH];
  always_ff @(posedge clk) begin
    if (we) begin
      mem[addr] <= din;
    end
  end
  always_ff @(posedge clk) begin
    dout <= mem[addr];
  end
  
endmodule

