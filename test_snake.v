`timescale 1ns / 1ps

module test_snake;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg l = 1'b0;
    reg r = 1'b0;
    reg u = 1'b0;
    reg d = 1'b0;

    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;
    wire h_sync;
    wire v_sync;

    Snake dut (
        .red(red),
        .green(green),
        .blue(blue),
        .h_sync(h_sync),
        .v_sync(v_sync),
        .clk(clk),
        .reset(reset),
        .l(l),
        .r(r),
        .u(u),
        .d(d)
    );

    // Speed up simulation
    defparam dut.upd.COUNT_MAX = 23'd4;

    always #5 clk = ~clk;

    task pulse_button;
        input which;
        begin
            case (which)
                0: l = 1'b1;
                1: r = 1'b1;
                2: u = 1'b1;
                3: d = 1'b1;
            endcase
            @(posedge clk);
            l = 1'b0;
            r = 1'b0;
            u = 1'b0;
            d = 1'b0;
        end
    endtask

    task wait_moves;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                repeat (6) @(posedge clk);
            end
        end
    endtask

    initial begin
        $display("Starting Snake test...");

        // Reset
        #30;
        reset = 1'b0;

        // -----------------------------------------
        // Test 1: basic movement to the right
        // -----------------------------------------
        wait_moves(2);
        if (dut.snakeX[0] <= 10'd320) begin
            $display("FAIL: snake did not move right after reset.");
            $fatal;
        end
        else begin
            $display("PASS: initial right movement works.");
        end

        // -----------------------------------------
        // Test 2: grow after apple
        // Put apple directly in front of the head
        // -----------------------------------------
        dut.appleX = dut.snakeX[0] + 10'd10;
        dut.appleY = dut.snakeY[0];

        wait_moves(2);

        if (dut.score != 8'd1) begin
            $display("FAIL: score did not increase after eating apple. score=%0d", dut.score);
            $fatal;
        end

        if (dut.length != 7'd4) begin
            $display("FAIL: snake length did not increase after eating apple. length=%0d", dut.length);
            $fatal;
        end

        $display("PASS: apple eating increases score and length.");

        // -----------------------------------------
        // Test 3: self-collision
        // Build a shape that makes the next DOWN move hit body
        // Head at (320,240), body at (310,240), (310,250), (320,250)
        // Then moving DOWN collides with (320,250)
        // -----------------------------------------
        dut.length = 7'd4;
        dut.snakeX[0] = 10'd320; dut.snakeY[0] = 9'd240;
        dut.snakeX[1] = 10'd310; dut.snakeY[1] = 9'd240;
        dut.snakeX[2] = 10'd310; dut.snakeY[2] = 9'd250;
        dut.snakeX[3] = 10'd320; dut.snakeY[3] = 9'd250;
        dut.appleX = 10'd100;
        dut.appleY = 9'd100;

        pulse_button(3); // DOWN
        wait_moves(2);

        if (dut.gameOver !== 1'b1) begin
            $display("FAIL: self-collision did not trigger game over.");
            $fatal;
        end

        $display("PASS: self-collision triggers game over.");
        $display("All tests passed.");
        $finish;
    end
endmodule