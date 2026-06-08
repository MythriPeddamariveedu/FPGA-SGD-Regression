// tb_top.v
`timescale 1ns / 1ps

module tb_top;

    reg clk;
    reg rst;
    reg start;

    wire done;
    wire valid_out;
    wire signed [15:0] y_pred;
    wire [6:0] pred_index;

    reg signed [15:0] y_actual_mem [0:99];

    integer pred_rs;
    integer actual_rs;
    integer error_rs;
    integer abs_error;
    integer total_abs_error;
    integer count;

    top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .valid_out(valid_out),
        .y_pred(y_pred),
        .pred_index(pred_index)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $readmemb("y_actual.mem", y_actual_mem);
    end

    initial begin
        rst = 1;
        start = 0;
        total_abs_error = 0;
        count = 0;

        #20 rst = 0;
        #10 start = 1;
    end

    always @(posedge clk) begin
        if (valid_out && !done && pred_index != 0) begin
            pred_rs   = $signed(y_pred) * 10000;
            actual_rs = $signed(y_actual_mem[pred_index]) * 10000;
            error_rs  = pred_rs - actual_rs;

            if (error_rs < 0)
                abs_error = -error_rs;
            else
                abs_error = error_rs;

            total_abs_error = total_abs_error + abs_error;
            count = count + 1;

            $display("Sample=%0d | y_pred=%0d | Predicted=Rs.%0d | Actual=Rs.%0d | Error=Rs.%0d",
                     pred_index, $signed(y_pred), pred_rs, actual_rs, error_rs);
        end

        if (done) begin
            $display("==============================================");
            $display("Simulation completed.");
            $display("Samples checked = %0d", count);
            $display("Average Absolute Error = Rs.%0d", total_abs_error / count);
            $display("==============================================");
            $finish;
        end
    end

endmodule