`timescale 1ns / 1ps

module tb_fir_system();

    // Parameters
    parameter N = 4;
    parameter DATA_WIDTH = 16;
    parameter CLK_PERIOD = 10; // 100MHz
    
    // System Signals
    reg clk;
    reg rst;
    
    // Testbench Signals
    reg [DATA_WIDTH-1:0] data_in;
    reg data_in_valid;
    wire [DATA_WIDTH-1:0] data_out;
    wire data_out_valid;
    
    // Expected outputs for x = [1,2,3,4,5] (only first 5 outputs needed)
    reg [DATA_WIDTH-1:0] expected_outputs [0:4];
    
    // Output counter
    integer output_count;
    integer sample_count;
    
    // Instantiate DUT
    fir_system #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_in_valid(data_in_valid),
        .data_out(data_out),
        .data_out_valid(data_out_valid)
    );
    
    // Initialize expected outputs (only first 5)
    initial begin
        expected_outputs[0] = 16'd1;   // y[0] = 1*1
        expected_outputs[1] = 16'd4;   // y[1] = 1*2 + 2*1
        expected_outputs[2] = 16'd10;  // y[2] = 1*3 + 2*2 + 3*1
        expected_outputs[3] = 16'd20;  // y[3] = 1*4 + 2*3 + 3*2 + 4*1
        expected_outputs[4] = 16'd30;  // y[4] = 1*5 + 2*4 + 3*3 + 4*2
    end
    
    // Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Reset Generation
    initial begin
        rst = 1;
        output_count = 0;
        sample_count = 0;
        data_in = 0;
        data_in_valid = 0;
        #(CLK_PERIOD*10); // Extended reset period
        rst = 0;
    end
    
    // Test Stimulus
    initial begin
        // Wait for reset to complete
        wait(rst == 0);
        #(CLK_PERIOD*20); // Additional wait for coefficient loading
        
        // Send input sequence [1,2,3,4,5]
        fork
            begin
                send_sample(1);
                send_sample(2);
                send_sample(3);
                send_sample(4);
                send_sample(5);
            end
            begin
                // Wait until all 5 expected outputs are received
                wait(output_count == 5);
                #(CLK_PERIOD*10);
                $display("Simulation completed successfully with all 5 outputs received");
                $finish;
            end
        join
    end
    
    // Task to send one sample
    task send_sample;
        input [DATA_WIDTH-1:0] sample;
        begin
            data_in = sample;
            data_in_valid = 1;
            @(posedge clk);
            data_in_valid = 0;
            sample_count = sample_count + 1;
            
            // Wait 10 cycles between samples
            repeat(10) @(posedge clk);
        end
    endtask
    
    // Output Checker
    always @(posedge clk) begin
        if (data_out_valid) begin
            if (output_count < 5) begin
                if (data_out === expected_outputs[output_count]) begin
                    $display("[%0t] Output y[%0d]: %0d PASS", 
                            $time, output_count, data_out);
                end else begin
                    $display("[%0t] Output y[%0d]: %0d FAIL (Expected: %0d)", 
                            $time, output_count, data_out, expected_outputs[output_count]);
                end
                
                output_count <= output_count + 1;
            end else begin
                $display("[%0t] Warning: Received extra output: %0d", $time, data_out);
            end
        end
    end

endmodule