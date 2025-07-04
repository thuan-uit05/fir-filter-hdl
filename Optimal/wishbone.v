module wishbone #(parameter N=4, DATA_WIDTH=16) (
    input wire clk_i,
    input wire rst_i,
    input wire [3:0] adr_i,
    input wire [DATA_WIDTH-1:0] dat_i,
    output reg [DATA_WIDTH-1:0] dat_o,
    input wire we_i,
    input wire stb_i,
    input wire cyc_i,
    output reg ack_o,

    output reg we_coeff,
    output reg [3:0] addr_coeff,
    output reg [DATA_WIDTH-1:0] data_coeff_i,
    input wire [DATA_WIDTH-1:0] data_coeff_o,

    output reg valid,
    output reg [DATA_WIDTH-1:0] sample,
    input wire [DATA_WIDTH-1:0] result
);

always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        ack_o <= 0;
        we_coeff <= 0;
        valid <= 0;
        addr_coeff <= 0;
        dat_o <= 0;
        sample <= 0;
    end else begin
        // Mặc định reset các tín hiệu
        ack_o <= 0;
        we_coeff <= 0;
        valid <= 0;

        if (cyc_i && stb_i && !ack_o) begin
            ack_o <= 1;  // Báo nhận giao dịch
            addr_coeff <= adr_i;

            if (we_i) begin
                if (adr_i < N) begin
                    we_coeff <= 1;          // Ghi hệ số
                    data_coeff_i <= dat_i;
                end else if (adr_i == N) begin
                    sample <= dat_i;        // Ghi mẫu mới
                    valid <= 1;             // Báo hiệu mẫu hợp lệ
                end
            end else begin
                if (adr_i < N) begin
                    dat_o <= data_coeff_o;  // Đọc hệ số
                end else if (adr_i == N + 1) begin
                    dat_o <= result;       // Đọc kết quả FIR
                end else begin
                    dat_o <= 0;             // Địa chỉ không hợp lệ
                end
            end
        end
    end
end
endmodule
