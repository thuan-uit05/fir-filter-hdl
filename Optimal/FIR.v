	module FIR #(parameter N=4, DATA_WIDTH=16) (
		 input wire clk,
		 input wire rst,
		 input wire valid,
		 input wire [DATA_WIDTH-1:0] sample,
		 output reg [DATA_WIDTH-1:0] result,
		 input wire we_coeff,
		 input wire [3:0] addr_coeff,
		 input wire [DATA_WIDTH-1:0] data_coeff_i,
		 output reg [DATA_WIDTH-1:0] data_coeff_o
	);

		 reg signed [DATA_WIDTH-1:0] coeffs [0:N-1];
		 reg signed [DATA_WIDTH-1:0] samples [0:N-1];
		 reg signed [DATA_WIDTH*2-1:0] mult_stage [0:N-1];
		 reg signed [DATA_WIDTH*2-1:0] sum_stage [0:N-1];

		 integer i;

		 always @(posedge clk) begin
			  if (rst) begin
					for (i = 0; i < N; i = i + 1) begin
						 coeffs[i] <= 0;
						 samples[i] <= 0;
						 mult_stage[i] <= 0;
						 sum_stage[i] <= 0;
					end
					result <= 0;
					data_coeff_o <= 0;
			  end else begin
					// Ghi và đọc hệ số
					if (we_coeff)
						 coeffs[addr_coeff] <= data_coeff_i;
					data_coeff_o <= coeffs[addr_coeff];

					// Shift mẫu nếu có dữ liệu mới
					if (valid) begin
						 for (i = N-1; i > 0; i = i - 1)
							  samples[i] <= samples[i-1];
						 samples[0] <= sample;
					end

					// Stage 1: Multiply song song
					for (i = 0; i < N; i = i + 1)
						 mult_stage[i] <= coeffs[i] * samples[i];

					// Stage 2: Adder tree pipeline
					sum_stage[0] <= mult_stage[0] + mult_stage[1];
					sum_stage[1] <= mult_stage[2] + mult_stage[3];
					sum_stage[2] <= sum_stage[0] + sum_stage[1];

					// Stage 3: Output mỗi chu kỳ sau khởi động
					result <= sum_stage[2][DATA_WIDTH-1:0];
					
			  end
		 end

	endmodule
