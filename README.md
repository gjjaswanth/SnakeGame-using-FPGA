# 🐍 FPGA Snake Game (Verilog + VGA)

## 📌 Overview
This project is a **hardware implementation** of the classic Snake Game using an **FPGA board**.  
The design is written in **Verilog HDL** and the game is shown on a **VGA monitor**.

Unlike normal computer games, this project does not run inside software.  
Instead, the FPGA handles everything directly in hardware. This makes the game:
- fast
- real-time
- smooth
- highly parallel

---

## 🎮 Final Output
<p align="center">
  <img src="https://github.com/user-attachments/assets/7c62b228-d10d-4945-a137-bce65f8c34b5" width="600"/>
  <br>
  <em>Figure: FPGA Snake Game Output on VGA Display</em>
</p>

---

## 🎯 Project Objective
The main purpose of this project is to:
- learn FPGA-based digital design
- understand VGA display timing
- implement a game using pure hardware logic
- practice modular Verilog coding
- study real-time input, output, and control systems

---

## 💡 Simple Idea of the Project
The FPGA performs three main tasks at the same time:

1. **Draws the screen** using VGA signals  
2. **Moves the snake** at a slow and playable speed  
3. **Checks inputs and collisions**  

Because these tasks happen in parallel, the game runs smoothly without delay.

---

## ⚙️ How the Project Works

### 1. Clock System
The FPGA board has a fast clock of **100 MHz**.  
This clock is too fast for the game directly, so it is divided into smaller clocks:

- **25 MHz clock** → used for VGA display
- **Slow update clock** → used for snake movement

This helps the screen update properly and keeps the snake movement human-friendly.

---

### 2. VGA Display System
The VGA module is responsible for showing the game on the monitor.

- Visible resolution: **640 × 480**
- Internal timing: **800 × 525**  
  (includes sync and blanking intervals)

The VGA logic continuously checks the current pixel position `(x, y)` and decides what color should be shown.

In this project:
- **Snake** is shown in green
- **Apple** is shown in red
- **Border** is shown in blue

So the display is created pixel by pixel in real time.

<p align="center">
  <img src="https://github.com/user-attachments/assets/53b4708f-cf7d-43de-a6ff-d781c99f03a4" width="650"/>
  <br>
  <em>Figure: Simulation waveform showing clock, input signals, and snake movement behavior</em>
</p>

---

### 3. Snake Movement
The snake moves on a grid, not freely pixel by pixel.

- Direction is controlled using push buttons:
  - UP
  - DOWN
  - LEFT
  - RIGHT

Each time the update clock gives a pulse:
- the body segments shift forward
- the head moves in the selected direction

This gives the snake a smooth and controlled movement.

---

### 4. Collision Detection
The game continuously checks for two types of collisions:

- **Wall collision** → when the snake hits the border
- **Self collision** → when the snake hits its own body

If any collision happens, the game stops and shows game over.

---

### 5. Apple Generation
The apple position is generated using an **LFSR (Linear Feedback Shift Register)**.

LFSR is used because true randomness is difficult to generate in digital hardware.  
It gives a pseudo-random sequence that works well for game applications.

Each time the snake eats the apple:
- the snake grows
- a new apple is placed at another position

---

### 6. Input Handling
The push buttons on FPGA boards do not give perfectly clean signals.  
They may bounce for a short time when pressed.

To solve this, the input is:
- synchronized with the clock
- filtered before being used

This prevents wrong movement and accidental multiple direction changes.

---

## 📊 Results

<p align="center">
  <img src="https://github.com/user-attachments/assets/0d45d8c0-5a25-4efa-a741-61a4c8fa719a" width="800"/>
  <br>
  <em>Figure: Post-synthesis resource utilization showing LUT and Flip-Flop usage</em>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/33f46cea-8b79-4a03-a8a1-d47c5b77f832" width="600"/>
  <br>
  <em>Figure: On-chip power analysis indicating low power consumption of the design</em>
</p>

### Observed Results
- Around **3450 LUTs** used
- Around **1481 Flip-Flops** used
- Power consumption around **0.12 W**
- No major timing issues
- Efficient design for a small FPGA game project

---

## 🔌 Hardware Used
- **FPGA Board:** Nexys 4 (Artix-7)
- **Display:** VGA Monitor
- **Inputs:** Push buttons for direction and reset

---

## ▶️ How to Run the Project
1. Open the project in **Xilinx Vivado**
2. Add all Verilog source files (`.v`)
3. Add the constraint file (`.xdc`)
4. Run **Synthesis**
5. Run **Implementation**
6. Generate the **Bitstream**
7. Program the FPGA board
8. Connect the VGA monitor and play the game

---

## ✨ Key Features
- Fully hardware-based game
- Real-time VGA display
- Simple and modular Verilog design
- Parallel execution of display and logic
- Low power usage
- Interactive gameplay using FPGA buttons

---

## 👨‍💻 Team Contributions
- Game logic design
- VGA display generation
- Clock divider and timing control
- Input handling and testing
- Debugging and documentation

---

## 🔗 GitHub Repository
https://github.com/gjjaswanth/SnakeGame-using-FPGA

---

## 🏁 Conclusion
This project shows how an FPGA can be used to build a complete real-time game using only hardware logic.

Instead of writing software code for a CPU, the design uses:
- parallel modules
- timing circuits
- display logic
- input control logic

