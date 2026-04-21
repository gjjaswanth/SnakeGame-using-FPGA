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

    localparam SCREEN_W  = 640;
    localparam SCREEN_H  = 480;
    localparam BORDER_W  = 10;
    localparam CELL_SIZE = 10;
    localparam MAX_LENGTH = 70;

    localparam LEFT  = 4'b0001;
    localparam RIGHT = 4'b0010;
    localparam UP    = 4'b0100;
    localparam DOWN  = 4'b1000;

    wire VGA_clk, update_clock, displayArea;
    wire [9:0] xCount;
    wire [9:0] yCount;
    wire [3:0] direction;
    wire [9:0] randX;
    wire [8:0] randY;

    reg gameOver = 0;

    // MOVE TICK
    reg update_prev;
    wire move_tick;

    always @(posedge clk)
        update_prev <= update_clock;

    assign move_tick = update_clock & ~update_prev;

    // SNAKE
    reg [9:0] snakeX [0:MAX_LENGTH-1];
    reg [8:0] snakeY [0:MAX_LENGTH-1];
    reg [6:0] snake_length = 5;

    reg [2:0] grow = 0;

    reg [9:0] appleX = 200;
    reg [8:0] appleY = 150;

    reg [9:0] nextSnakeX;
    reg [8:0] nextSnakeY;

    integer i, j;

    wire border, apple, eatApple, hitBorder;
    reg snakeBody;
    reg hitSelf;

    // MODULES
    ClockDivider divider(.clk(clk), .VGA_clk(VGA_clk));

    UpdateClock #(.COUNT_MAX(23'd3000000)) upd(
        .clk(clk),
        .update_clk(update_clock)
    );

    VGAgenerator vga(
        .VGA_clk(VGA_clk),
        .xCount(xCount),
        .yCount(yCount),
        .displayArea(displayArea),
        .VGA_hSync(h_sync),
        .VGA_vSync(v_sync)
    );

    Random ran(.VGA_clk(VGA_clk), .randX(randX), .randY(randY));

    ButtonInput but(
        .clk(clk), .reset(reset),
        .l(l), .r(r), .u(u), .d(d),
        .direction(direction)
    );

    // BORDER
    assign border = displayArea &&
        ((xCount < BORDER_W) || (xCount >= SCREEN_W - BORDER_W) ||
         (yCount < BORDER_W) || (yCount >= SCREEN_H - BORDER_W));

    // APPLE
    assign apple = displayArea &&
        (xCount >= appleX) && (xCount < appleX + CELL_SIZE) &&
        (yCount >= appleY) && (yCount < appleY + CELL_SIZE);

    assign eatApple =
    (nextSnakeX < appleX + CELL_SIZE) &&
    (nextSnakeX + CELL_SIZE > appleX) &&
    (nextSnakeY < appleY + CELL_SIZE) &&
    (nextSnakeY + CELL_SIZE > appleY);

    assign hitBorder =
        (nextSnakeX < BORDER_W) ||
        (nextSnakeX > SCREEN_W - BORDER_W - CELL_SIZE) ||
        (nextSnakeY < BORDER_W) ||
        (nextSnakeY > SCREEN_H - BORDER_W - CELL_SIZE);

    // NEXT POSITION
    always @* begin
        nextSnakeX = snakeX[0];
        nextSnakeY = snakeY[0];

        case(direction)
            LEFT:  nextSnakeX = snakeX[0] - CELL_SIZE;
            RIGHT: nextSnakeX = snakeX[0] + CELL_SIZE;
            UP:    nextSnakeY = snakeY[0] - CELL_SIZE;
            DOWN:  nextSnakeY = snakeY[0] + CELL_SIZE;
        endcase
    end

    // SELF COLLISION
    always @* begin
        hitSelf = 0;
        for (j = 1; j < MAX_LENGTH; j = j + 1) begin
            if (j < snake_length) begin
                if (nextSnakeX == snakeX[j] && nextSnakeY == snakeY[j])
                    hitSelf = 1;
            end
        end
    end

    // GAME UPDATE
    always @(posedge clk) begin
        if (reset) begin
            snake_length <= 5;
            grow <= 0;
            gameOver <= 0;

            for(i = 0; i < MAX_LENGTH; i = i + 1) begin
                snakeX[i] <= 320 - (i * CELL_SIZE); 
                snakeY[i] <= 240;
            end

            appleX <= ((randX % ((SCREEN_W - 2*BORDER_W)/CELL_SIZE)) * CELL_SIZE) + BORDER_W;
            appleY <= ((randY % ((SCREEN_H - 2*BORDER_W)/CELL_SIZE)) * CELL_SIZE) + BORDER_W;

            end 
        else if (move_tick && !gameOver) begin
            if (hitBorder || hitSelf) begin
                gameOver <= 1;
            end else begin

                // SHIFT BODY
                for(i = MAX_LENGTH-1; i > 0; i = i - 1) begin
                    if(i < snake_length) begin
                        snakeX[i] <= snakeX[i-1];
                        snakeY[i] <= snakeY[i-1];
                    end
                end

                // MOVE HEAD
                snakeX[0] <= nextSnakeX;
                snakeY[0] <= nextSnakeY;

                // SMOOTH GROWTH
                if (grow > 0) begin
                    snakeX[snake_length] <= snakeX[snake_length-1];
                    snakeY[snake_length] <= snakeY[snake_length-1];
                    snake_length <= snake_length + 1;
                    grow <= grow - 1;
                end

                // EAT APPLE
                if (eatApple) begin
                    grow <= grow + 3;
                    appleX <= ((randX % ((SCREEN_W - 2*BORDER_W)/CELL_SIZE)) * CELL_SIZE) + BORDER_W;
                    appleY <= ((randY % ((SCREEN_H - 2*BORDER_W)/CELL_SIZE)) * CELL_SIZE) + BORDER_W;
                end
            end
        end
    end

    // DRAW
    always @* begin
        snakeBody = 0;
        for(i = 0; i < MAX_LENGTH; i = i + 1) begin
            if (i < snake_length &&
                (xCount >= snakeX[i]) && (xCount < snakeX[i] + CELL_SIZE) &&
                (yCount >= snakeY[i]) && (yCount < snakeY[i] + CELL_SIZE))
                snakeBody = 1;
        end
    end

    // VGA OUTPUT
    always @(posedge VGA_clk) begin
        if (!displayArea) begin
            red <= 0; green <= 0; blue <= 0;
        end else if (gameOver) begin
            red <= 4'hF; green <= 0; blue <= 0;
        end else if (snakeBody) begin
            red <= 0; green <= 4'hF; blue <= 0;
        end else if (apple) begin
            red <= 4'hF; green <= 0; blue <= 0;
        end else if (border) begin
            red <= 0; green <= 0; blue <= 4'hF;
        end else begin
            red <= 0; green <= 0; blue <= 0;
        end
    end

endmodule

// ================= CLOCK DIVIDER =================
module ClockDivider(input clk, output VGA_clk);
    reg [1:0] div_cnt = 0;
    always @(posedge clk) div_cnt <= div_cnt + 1;
    assign VGA_clk = div_cnt[1];
endmodule

// ================= UPDATE CLOCK =================
module UpdateClock #(parameter COUNT_MAX = 3000000)(
    input clk,
    output reg update_clk = 0
);
    reg [22:0] count = 0;

    always @(posedge clk) begin
        if (count == COUNT_MAX) begin
            count <= 0;
            update_clk <= ~update_clk;
        end else count <= count + 1;
    end
endmodule

// ================= VGA =================
module VGAgenerator(
    input VGA_clk,
    output reg [9:0] xCount = 0,
    output reg [9:0] yCount = 0,
    output reg displayArea = 0,
    output VGA_hSync,
    output VGA_vSync
);
    localparam H_TOTAL = 800;
    localparam V_TOTAL = 525;

    reg hSync = 0, vSync = 0;

    always @(posedge VGA_clk) begin
        if (xCount == H_TOTAL-1) begin
            xCount <= 0;
            if (yCount == V_TOTAL-1) yCount <= 0;
            else yCount <= yCount + 1;
        end else xCount <= xCount + 1;

        displayArea <= (xCount < 640) && (yCount < 480);
        hSync <= (xCount >= 656 && xCount < 752);
        vSync <= (yCount >= 490 && yCount < 492);
    end

    assign VGA_hSync = ~hSync;
    assign VGA_vSync = ~vSync;
endmodule

// ================= RANDOM =================
module Random(input VGA_clk, output reg [9:0] randX=10'h155, output reg [8:0] randY=9'h0E7);
    always @(posedge VGA_clk) begin
        randX <= {randX[8:0], randX[9]^randX[6]};
        randY <= {randY[7:0], randY[8]^randY[4]};
    end
endmodule

// ================= BUTTON =================
module ButtonInput(
    input clk,
    input reset,
    input l, r, u, d,
    output reg [3:0] direction = 4'b0010
);
    localparam LEFT  = 4'b0001;
    localparam RIGHT = 4'b0010;
    localparam UP    = 4'b0100;
    localparam DOWN  = 4'b1000;

    reg [3:0] next_dir;

    always @(posedge clk) begin
        if (reset) begin
            direction <= RIGHT;
            next_dir <= RIGHT;
        end else begin
            case(direction)
                LEFT:  if (u) next_dir <= UP;
                       else if (d) next_dir <= DOWN;

                RIGHT: if (u) next_dir <= UP;
                       else if (d) next_dir <= DOWN;

                UP:    if (l) next_dir <= LEFT;
                       else if (r) next_dir <= RIGHT;

                DOWN:  if (l) next_dir <= LEFT;
                       else if (r) next_dir <= RIGHT;
            endcase

            direction <= next_dir;
        end
    end
endmodule
