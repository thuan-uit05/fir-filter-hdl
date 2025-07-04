`timescale 1ns / 1ps

module fir_system #(
    parameter N = 4,
    parameter DATA_WIDTH = 16
)(
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH-1:0] data_in,   // Input data to master
    input wire data_in_valid,              // Input data valid signal
    output wire [DATA_WIDTH-1:0] data_out, // Output data from master
    output wire data_out_valid             // Output data valid signal
);

    // Wishbone interconnect wires
    wire [3:0] adr;
    wire [DATA_WIDTH-1:0] dat_m2s;
    wire [DATA_WIDTH-1:0] dat_s2m;
    wire we;
    wire stb;
    wire cyc;
    wire ack;

	     // FIR system with Wishbone slave
    fir_wishbone #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) fir_inst (
        .clk(clk),
        .rst(rst),
        .adr_i(adr),
        .dat_i(dat_m2s),
        .dat_o(dat_s2m),
        .we_i(we),
        .stb_i(stb),
        .cyc_i(cyc),
        .ack_o(ack)
    );

    // Master controller
    FIR_Master #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) master_inst (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_out(data_out),
        .data_out_valid(data_out_valid),
        .adr_o(adr),
        .dat_o(dat_m2s),
        .dat_i(dat_s2m),
        .we_o(we),
        .stb_o(stb),
        .cyc_o(cyc),
        .ack_i(ack)
    );

endmodule