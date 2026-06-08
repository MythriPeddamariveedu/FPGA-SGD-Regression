// top.v
// Use this as the top module for FPGA synthesis.

module top (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output wire done,
    output wire valid,
    output wire [15:0] sample_index,
    output wire signed [15:0] y_pred
);

    predict_mem dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .valid(valid),
        .sample_index(sample_index),
        .y_pred(y_pred)
    );

endmodule
