`timescale 1ns / 1ps

module testbench;

    reg clk;
    reg rst;
    reg [3:0] adr_i;
    reg [15:0] dat_i;
    wire [15:0] dat_o;
    reg we_i;
    reg stb_i;
    reg cyc_i;
    wire ack_o;

    reg [15:0] read_data = 0;
    integer i;

    fir_wishbone #(.N(4), .DATA_WIDTH(16)) dut (
        .clk_i(clk),
        .rst_i(rst),
        .adr_i(adr_i),
        .dat_i(dat_i),
        .dat_o(dat_o),
        .we_i(we_i),
        .stb_i(stb_i),
        .cyc_i(cyc_i),
        .ack_o(ack_o)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    task wb_write(input [3:0] addr, input [15:0] data);
    begin
        @(posedge clk);
        adr_i <= addr;
        dat_i <= data;
        we_i <= 1;
        stb_i <= 1;
        cyc_i <= 1;

        @(posedge clk);
        while (!ack_o) @(posedge clk);

        stb_i <= 0;
        cyc_i <= 0;
        we_i <= 0;
        #10; // Thêm độ trễ
    end
    endtask

    task wb_read(input [3:0] addr);
    begin
        @(posedge clk);
        adr_i <= addr;
        we_i <= 0;
        stb_i <= 1;
        cyc_i <= 1;

        @(posedge clk);
        while (!ack_o) @(posedge clk);
        read_data = dat_o;
        
        @(posedge clk);
        stb_i <= 0;
        cyc_i <= 0;
        #10; // Thêm độ trễ
    end
    endtask

    task check_result(input [15:0] actual, input [15:0] expected);
    begin
        if (actual == expected)
            $display("PASS: expected = %d, actual = %d", expected, actual);
        else
            $display("FAIL: expected = %d, actual = %d", expected, actual);
    end
    endtask

    reg [15:0] expected_output[0:4];
    reg [15:0] input_samples[0:4];

    initial begin
        // Khởi tạo giá trị mảng
        input_samples[0] = 1;
        input_samples[1] = 2;
        input_samples[2] = 3;
        input_samples[3] = 4;
        input_samples[4] = 5;

        // Khởi tạo
        rst = 1;
        adr_i = 0;
        dat_i = 0;
        we_i = 0;
        stb_i = 0;
        cyc_i = 0;
        #100;
        rst = 0;
        #20;

        // Ghi hệ số FIR
        $display("Ghi hệ số FIR:");
        wb_write(0, 16'd1); wb_read(0); $display("Coeff[0] = %d", read_data);
        wb_write(1, 16'd2); wb_read(1); $display("Coeff[1] = %d", read_data);
        wb_write(2, 16'd3); wb_read(2); $display("Coeff[2] = %d", read_data);
        wb_write(3, 16'd4); wb_read(3); $display("Coeff[3] = %d", read_data);

        // Kết quả mong đợi (đã điều chỉnh theo chu kỳ)
        expected_output[0] = 1*1;   // 1
        expected_output[1] = 1*2 + 2*1; // 4
        expected_output[2] = 1*3 + 2*2 + 3*1; // 10
        expected_output[3] = 1*4 + 2*3 + 3*2 + 4*1; // 20
        expected_output[4] = 1*5 + 2*4 + 3*3 + 4*2; // 30

        // Kiểm tra kết quả FIR
        $display("\nKiểm tra FIR:");
        for (i = 0; i < 5; i = i + 1) begin
            wb_write(4, i+1); // Gửi mẫu
        
            // Đợi 3 chu kỳ để đảm bảo tính toán hoàn tất
            repeat(3) @(posedge clk);
        
            wb_read(5); // Đọc kết quả
        
            // Debug chi tiết
            $display("x[%0d] = %d, result = %d", i, i+1, read_data);
            check_result(read_data, expected_output[i]);
        end

        #100;
        $finish;
    end

endmodule
