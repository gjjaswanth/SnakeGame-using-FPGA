`timescale 1ns / 1ps

module test_snake;

    reg clk = 0;
    reg reset = 1;
    reg l = 0, r = 0, u = 0, d = 0;

    wire [3:0] red, green, blue;
    wire h_sync, v_sync;

    integer start_x;
    integer start_y;

    Snake dut (
        .red(red),
        .green(green),
        .blue(blue),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .clk(clk),
        .reset(reset),
        .l(l), .r(r), .u(u), .d(d)
    );

    // Faster simulation
    defparam dut.upd.COUNT_MAX = 23'd4;

    always #5 clk = ~clk;

    task wait_for_move;
        begin
            repeat (8) @(posedge clk);
        end
    endtask

    initial begin
        $display("Starting Snake control test...");

        #30;
        reset = 0;

        // --- Test default RIGHT movement ---
        start_x = dut.snakeX[0];
        wait_for_move();
        if (dut.snakeX[0] <= start_x) begin
            $display("FAIL: default/right movement did not increase X");
            $fatal;
        end

        // --- Test DOWN movement ---
        d = 1;
        @(posedge clk);
        d = 0;

        start_y = dut.snakeY[0];
        wait_for_move();
        if (dut.snakeY[0] <= start_y) begin
            $display("FAIL: down movement did not increase Y");
            $fatal;
        end

        // --- Test RIGHT again ---
        r = 1;
        @(posedge clk);
        r = 0;

        start_x = dut.snakeX[0];
        wait_for_move();
        if (dut.snakeX[0] <= start_x) begin
            $display("FAIL: right movement did not increase X");
            $fatal;
        end

        $display("PASS: snake moves correctly.");
        $finish;
    end

endmodule
