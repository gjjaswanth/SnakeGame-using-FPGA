`timescale 1ns / 1ps

module Snake(
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue,
    output h_sync,
    output v_sync,
    input clk,
    input reset,
    input l, r, u, d
);

parameter MAX_LENGTH = 100;
parameter CELL_SIZE  = 10;

// ---------------- SIGNALS ----------------
wire VGA_clk, update_clock, displayArea;
wire [9:0] xCount, yCount;
wire [3:0] direction;

reg [9:0] snakeX [0:MAX_LENGTH-1];
reg [9:0] snakeY [0:MAX_LENGTH-1];
reg [6:0] length;

reg [9:0] appleX, appleY;
reg [7:0] score;
reg gameOver;

reg [9:0] nextX, nextY;

reg eatApple;
reg hitBody;

integer i;

// ---------------- MODULE INSTANCES ----------------
ClockDivider div(clk, VGA_clk);
UpdateClock upd(clk, update_clock);
VGAgenerator vga(VGA_clk, xCount, yCount, displayArea, h_sync, v_sync);
ButtonInput btn(clk, reset, l, r, u, d, direction);

// ---------------- NEXT POSITION ----------------
always @(*) begin
    nextX = snakeX[0];
    nextY = snakeY[0];

    case(direction)
        4'b0001: nextX = snakeX[0] - CELL_SIZE;
        4'b0010: nextX = snakeX[0] + CELL_SIZE;
        4'b0100: nextY = snakeY[0] - CELL_SIZE;
        4'b1000: nextY = snakeY[0] + CELL_SIZE;
    endcase
end

// ---------------- RESET ----------------
always @(posedge clk or posedge reset) begin
    if(reset) begin
        length <= 3;
        score <= 0;
        gameOver <= 0;

        snakeX[0] <= 320;
        snakeY[0] <= 240;
        snakeX[1] <= 310;
        snakeY[1] <= 240;
        snakeX[2] <= 300;
        snakeY[2] <= 240;

        appleX <= 100;
        appleY <= 100;
    end
end

// ---------------- GAME LOGIC ----------------
always @(posedge clk) begin
    if(update_clock && !gameOver) begin

        eatApple <= (nextX == appleX) && (nextY == appleY);

        hitBody <= 0;
        for(i=1;i<MAX_LENGTH;i=i+1) begin
            if(i < length) begin
                if(nextX == snakeX[i] && nextY == snakeY[i])
                    hitBody <= 1;
            end
        end

        if(nextX <= 0 || nextX >= 630 || nextY <= 0 || nextY >= 470)
            gameOver <= 1;
        else if(hitBody)
            gameOver <= 1;
        else begin
            for(i=MAX_LENGTH-1;i>0;i=i-1) begin
                if(i < length) begin
                    snakeX[i] <= snakeX[i-1];
                    snakeY[i] <= snakeY[i-1];
                end
            end

            snakeX[0] <= nextX;
            snakeY[0] <= nextY;

            if(eatApple) begin
                if(length < MAX_LENGTH)
                    length <= length + 1;

                score <= score + 1;

                appleX <= ((appleX + 70) % 600) / 10 * 10;
appleY <= ((appleY + 50) % 440) / 10 * 10;
            end
        end
    end
end

// ---------------- DRAW ----------------
reg snakePixel;
reg applePixel;
reg borderPixel;
reg scorePixel;

always @(*) begin
    snakePixel = 0;

    for(i=0;i<MAX_LENGTH;i=i+1) begin
        if(i < length) begin
            if(xCount >= snakeX[i] && xCount < snakeX[i] + CELL_SIZE &&
               yCount >= snakeY[i] && yCount < snakeY[i] + CELL_SIZE)
                snakePixel = 1;
        end
    end

    applePixel =
        (xCount >= appleX && xCount < appleX + CELL_SIZE &&
         yCount >= appleY && yCount < appleY + CELL_SIZE);

    borderPixel =
        (xCount < 10 || xCount > 630 || yCount < 10 || yCount > 470);

    scorePixel = (yCount < 20 && xCount < score * 10);
end

// ---------------- COLOR ----------------
always @(posedge VGA_clk) begin
    if(!displayArea) begin
        red <= 0; green <= 0; blue <= 0;
    end
    else if(gameOver) begin
        red <= 4'hF; green <= 0; blue <= 0;
    end
    else begin
        if(scorePixel) begin
            red <= 4'hF; green <= 4'hF; blue <= 0;
        end
        else if(snakePixel) begin
            red <= 0; green <= 4'hF; blue <= 0;
        end
        else if(applePixel) begin
            red <= 4'hF; green <= 0; blue <= 0;
        end
        else if(borderPixel) begin
            red <= 0; green <= 0; blue <= 4'hF;
        end
        else begin
            red <= 0; green <= 0; blue <= 0;
        end
    end
end

endmodule

// ================= CLOCK DIVIDER =================
module ClockDivider(
    input clk,
    output VGA_clk
);
    reg [1:0] div_cnt = 2'b00;

    always @(posedge clk) begin
        div_cnt <= div_cnt + 2'b01;
    end

    assign VGA_clk = div_cnt[1];
endmodule
// ================= UPDATE CLOCK =================
module UpdateClock #(
    parameter [22:0] COUNT_MAX = 23'd5000000
) (
    input clk,
    output reg update_clk = 1'b0
);
    reg [22:0] count = 23'd0;

    always @(posedge clk) begin
        if (count == COUNT_MAX - 1'b1) begin
            count <= 23'd0;
            update_clk <= 1'b1;
        end else begin
            count <= count + 1'b1;
            update_clk <= 1'b0;
        end
    end
endmodule

// ================= VGA GENERATOR =================
module VGAgenerator(
    input clk,
    output reg [9:0] xCount = 0,
    output reg [9:0] yCount = 0,
    output displayArea,
    output h_sync,
    output v_sync
);

// 640x480 @60Hz timing
parameter H_VISIBLE = 640;
parameter H_FRONT   = 16;
parameter H_SYNC    = 96;
parameter H_BACK    = 48;
parameter H_TOTAL   = 800;

parameter V_VISIBLE = 480;
parameter V_FRONT   = 10;
parameter V_SYNC    = 2;
parameter V_BACK    = 33;
parameter V_TOTAL   = 525;

reg [9:0] hCount = 0;
reg [9:0] vCount = 0;

// Horizontal counter
always @(posedge clk) begin
    if (hCount == H_TOTAL - 1) begin
        hCount <= 0;

        if (vCount == V_TOTAL - 1)
            vCount <= 0;
        else
            vCount <= vCount + 1;
    end else begin
        hCount <= hCount + 1;
    end
end

// Assign outputs
always @(posedge clk) begin
    xCount <= hCount;
    yCount <= vCount;
end

// Display area
assign displayArea = (hCount < H_VISIBLE) && (vCount < V_VISIBLE);

// Sync signals (ACTIVE LOW)
assign h_sync = ~(hCount >= (H_VISIBLE + H_FRONT) &&
                  hCount <  (H_VISIBLE + H_FRONT + H_SYNC));

assign v_sync = ~(vCount >= (V_VISIBLE + V_FRONT) &&
                  vCount <  (V_VISIBLE + V_FRONT + V_SYNC));

endmodule
// ================= BUTTON INPUT =================
module ButtonInput(
    input clk,
    input reset,
    input l, r, u, d,
    output reg [3:0] direction
);

always @(posedge clk or posedge reset) begin
    if(reset)
        direction <= 4'b0010; // RIGHT
    else begin
        if(l && direction != 4'b0010)
            direction <= 4'b0001;
        else if(r && direction != 4'b0001)
            direction <= 4'b0010;
        else if(u && direction != 4'b1000)
            direction <= 4'b0100;
        else if(d && direction != 4'b0100)
            direction <= 4'b1000;
    end
end

endmodule