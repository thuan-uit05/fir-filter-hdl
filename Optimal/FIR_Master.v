module FIR_Master #(
    parameter N = 4,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] data_in,     // Input data from top
    input wire data_in_valid,                // Input data valid signal
    output reg [DATA_WIDTH-1:0] data_out,    // Output data to top
    output reg data_out_valid,               // Output data valid signal
    // Wishbone interface
    output reg [3:0] adr_o,
    output reg [DATA_WIDTH-1:0] dat_o,
    input wire [DATA_WIDTH-1:0] dat_i,
    output reg we_o,
    output reg stb_o,
    output reg cyc_o,
    input wire ack_i
);

    reg [2:0] state;
    localparam IDLE        = 3'd0,
               LOAD_COEFF  = 3'd1,
               WAIT_INPUT  = 3'd2,
               SEND_SAMPLE = 3'd3,
               WAIT_RESULT = 3'd4,
               READ_RESULT = 3'd5;

    integer i;
    reg [DATA_WIDTH-1:0] coeffs [0:N-1];
    reg [1:0] wait_count;
    reg has_coeffs_loaded;

    initial begin
        // Initialize coefficients
        coeffs[0] = 16'd1; coeffs[1] = 16'd2; 
        coeffs[2] = 16'd3; coeffs[3] = 16'd4;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= LOAD_COEFF;
            adr_o <= 0;
            dat_o <= 0;
            we_o <= 0;
            stb_o <= 0;
            cyc_o <= 0;
            data_out <= 0;
            data_out_valid <= 0;
            i <= 0;
            wait_count <= 0;
            has_coeffs_loaded <= 0;
        end else begin
            data_out_valid <= 0; // Default to 0
            
            case (state)
                LOAD_COEFF: begin
                    if (!has_coeffs_loaded) begin
                        if (i < N) begin
                            adr_o <= i;
                            dat_o <= coeffs[i];
                            we_o <= 1;
                            stb_o <= 1;
                            cyc_o <= 1;
                            
                            if (ack_i) begin
                                i <= i + 1;
                                stb_o <= 0;
                                cyc_o <= 0;
                                we_o <= 0;
                            end
                        end else begin
                            has_coeffs_loaded <= 1;
                            i <= 0;
                            state <= WAIT_INPUT;
                        end
                    end else begin
                        state <= WAIT_INPUT;
                    end
                end
                
                WAIT_INPUT: begin
                    if (data_in_valid) begin
                        dat_o <= data_in; // Lưu input data
                        state <= SEND_SAMPLE;
                    end
                end
                
                SEND_SAMPLE: begin
                    adr_o <= N; // Address for sample input
                    we_o <= 1;
                    stb_o <= 1;
                    cyc_o <= 1;
                    
                    if (ack_i) begin
                        stb_o <= 0;
                        cyc_o <= 0;
                        we_o <= 0;
                        wait_count <= 3; // Wait for FIR processing
                        state <= WAIT_RESULT;
                    end
                end
                
                WAIT_RESULT: begin
                    if (wait_count > 0) begin
                        wait_count <= wait_count - 1;
                    end else begin
								wait_count <= 10; // Đủ cho pipeline FIR
                        state <= READ_RESULT;
                    end
                end
                
                READ_RESULT: begin
                    adr_o <= N + 1; // Address for result
                    we_o <= 0;
                    stb_o <= 1;
                    cyc_o <= 1;
                    
                    if (ack_i) begin
                        data_out <= dat_i; // Nhận kết quả từ slave
                        data_out_valid <= 1;
                        stb_o <= 0;
                        cyc_o <= 0;
                        state <= WAIT_INPUT; // Ready for next input
                    end
                end
            endcase
        end
    end
endmodule