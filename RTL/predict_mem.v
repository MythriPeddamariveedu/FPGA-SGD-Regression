// predict_mem.v
// FPGA-friendly SGD regression predictor.
// Inputs come from internal ROM memories loaded using .mem files.
// Output y_pred is 16-bit signed, in units of Rs.10,000.

`include "sgd_params.vh"

module predict_mem #(
    parameter integer NUM_SAMPLES = `NUM_SAMPLES
)(
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  done,
    output reg  valid,
    output reg  [15:0] sample_index,
    output reg  signed [15:0] y_pred
);

    localparam ADDR_W = 16;

    reg signed [15:0] x1_mem [0:NUM_SAMPLES-1];
    reg signed [15:0] x2_mem [0:NUM_SAMPLES-1];
    reg signed [15:0] x3_mem [0:NUM_SAMPLES-1];
    reg signed [15:0] x4_mem [0:NUM_SAMPLES-1];

    initial begin
        $readmemb("x1.mem", x1_mem);
        $readmemb("x2.mem", x2_mem);
        $readmemb("x3.mem", x3_mem);
        $readmemb("x4.mem", x4_mem);
    end

    reg [1:0] state;
    localparam IDLE = 2'd0, CALC = 2'd1, OUT = 2'd2, FINISH = 2'd3;

    reg signed [15:0] x1, x2, x3, x4;
    reg signed [63:0] acc;
    reg signed [31:0] shifted;

    always @(posedge clk) begin
        if (rst) begin
            state        <= IDLE;
            done         <= 1'b0;
            valid        <= 1'b0;
            sample_index <= 16'd0;
            y_pred       <= 16'sd0;
            acc          <= 64'sd0;
            shifted      <= 32'sd0;
            x1 <= 16'sd0; x2 <= 16'sd0; x3 <= 16'sd0; x4 <= 16'sd0;
        end else begin
            valid <= 1'b0;

            case (state)
                IDLE: begin
                    done <= 1'b0;
                    sample_index <= 16'd0;
                    if (start) begin
                        x1 <= x1_mem[0];
                        x2 <= x2_mem[0];
                        x3 <= x3_mem[0];
                        x4 <= x4_mem[0];
                        state <= CALC;
                    end
                end

                CALC: begin
                    // Q10 weights * integer features
                    acc <= ($signed(`W1) * $signed(x1)) +
                           ($signed(`W2) * $signed(x2)) +
                           ($signed(`W3) * $signed(x3)) +
                           ($signed(`W4) * $signed(x4)) +
                           $signed(`B);
                    state <= OUT;
                end

                OUT: begin
                    shifted = acc >>> `SCALE_SHIFT;

                    // Saturate to 16-bit signed range
                    if (shifted > 32'sd32767)
                        y_pred <= 16'sd32767;
                    else if (shifted < -32'sd32768)
                        y_pred <= -16'sd32768;
                    else
                        y_pred <= shifted[15:0];

                    valid <= 1'b1;

                    if (sample_index == NUM_SAMPLES-1) begin
                        state <= FINISH;
                    end else begin
                        sample_index <= sample_index + 16'd1;
                        x1 <= x1_mem[sample_index + 16'd1];
                        x2 <= x2_mem[sample_index + 16'd1];
                        x3 <= x3_mem[sample_index + 16'd1];
                        x4 <= x4_mem[sample_index + 16'd1];
                        state <= CALC;
                    end
                end

                FINISH: begin
                    done <= 1'b1;
                    state <= FINISH;
                end
            endcase
        end
    end

endmodule
