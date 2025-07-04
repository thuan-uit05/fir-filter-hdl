module fir_wishbone #(
    parameter N = 4,
    parameter DATA_WIDTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,
    // Wishbone interface
    input  wire [3:0]            adr_i,
    input  wire [DATA_WIDTH-1:0] dat_i,
    output wire [DATA_WIDTH-1:0] dat_o,
    input  wire                  we_i,
    input  wire                  stb_i,
    input  wire                  cyc_i,
    output wire                  ack_o
);

    // Internal signals
    wire we_coeff;
    wire [3:0] addr_coeff;
    wire [DATA_WIDTH-1:0] data_coeff_i, data_coeff_o;
    wire valid;
    wire [DATA_WIDTH-1:0] sample, result;

    // Wishbone instance
    wishbone wb_inst (
        .clk_i(clk),
        .rst_i(rst),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .we_i(we_i),
        .stb_i(stb_i),
        .cyc_i(cyc_i),
        .ack_o(ack_o),
        .we_coeff(we_coeff),
        .addr_coeff(addr_coeff),
        .data_coeff_i(data_coeff_i),
        .data_coeff_o(data_coeff_o),
        .valid(valid),
        .sample(sample),
        .result(result)
    );

    // FIR instance
    FIR fir_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .sample(sample),
        .result(result),
        .we_coeff(we_coeff),
        .addr_coeff(addr_coeff),
        .data_coeff_i(data_coeff_i),
        .data_coeff_o(data_coeff_o)
    );

endmodule