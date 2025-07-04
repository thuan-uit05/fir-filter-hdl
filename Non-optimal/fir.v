module fir #(parameter N=4, DATA_WIDTH=16) (
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
    integer i;
    reg signed [DATA_WIDTH*2-1:0] acc;
    reg [1:0] state;

    // Trạng thái điều khiển
    localparam IDLE = 0;
    localparam SHIFT = 1;
    localparam CALC = 2;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1) begin
                coeffs[i] <= 0;
                samples[i] <= 0;
            end
            data_coeff_o <= 0;
            result <= 0;
            state <= IDLE;
        end
        else begin
            // Đọc hệ số
            data_coeff_o <= coeffs[addr_coeff];
            
            // Ghi hệ số
            if (we_coeff) begin
                coeffs[addr_coeff] <= data_coeff_i;
            end
            
            // Điều khiển trạng thái
            case (state)
                IDLE: begin
                    if (valid) begin
                        state <= SHIFT;
                    end
                end
                
                SHIFT: begin
                    // Dịch thanh ghi mẫu
                    for (i = N-1; i > 0; i = i - 1) begin
                        samples[i] <= samples[i-1];
                    end
                    samples[0] <= sample;
                    state <= CALC;
                end
                
                CALC: begin
                    // Tính toán FIR
                    acc = 0;
                    for (i = 0; i < N; i = i + 1) begin
                        acc = acc + coeffs[i] * samples[i];
                    end
                    result <= acc[DATA_WIDTH-1:0];
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
