# 🐍 FPGA Snake Game (Verilog + VGA)

## 📌 Overview
This project implements the classic **Snake Game** using an FPGA. The entire system is designed in **Verilog HDL** and displayed on a **VGA monitor**.

Unlike software-based games, this runs **completely on hardware**, meaning:
- No operating system
- No software execution delays
- Fully **real-time and parallel execution**

---

## 🎮 Final Output

![Game Output](images/game_output.png)

---

## 🎯 Objective
The main goals of this project are:
- Learn FPGA-based system design
- Understand VGA signal generation
- Build a real-time interactive system
- Apply digital logic concepts in a practical way

---

## 🧠 Basic Idea (Simple Explanation)

The FPGA does three things at the same time:
1. Continuously draws pixels on the screen  
2. Updates the snake’s position  
3. Checks user input and collisions  

This parallel execution makes the game smooth and fast.

---

## ⚙️ How the System Works

### 1. Clock System
- FPGA clock: **100 MHz**
- Divided into:
  - **25 MHz → VGA display**
  - **Slow clock → Snake movement**

This ensures the snake moves at a playable speed.

---

### 2. VGA Display

![VGA Output](images/vga.png)

- Resolution: **640 × 480**
- Internally uses **800 × 525 timing** (includes sync and blanking)

The VGA module:
- Tracks pixel position (x, y)
- Assigns colors:
  - Snake → Green  
  - Apple → Red  
  - Border → Blue  

---

### 3. Snake Movement
- Moves in fixed grid steps
- Controlled using buttons (UP, DOWN, LEFT, RIGHT)

Working:
- Snake body stored in arrays
- Each step:
  - Body shifts forward
  - Head moves in chosen direction

---

### 4. Collision Detection
The system checks:
- Wall collision → Game Over  
- Self collision → Game Over  

This is done using coordinate comparison.

---

### 5. Apple Generation (LFSR)
- Uses **Linear Feedback Shift Register**
- Generates pseudo-random positions

Reason:
- True randomness is not possible in digital hardware

---

### 6. Input Handling
- Buttons produce noisy signals (bounce)
- Inputs are synchronized and filtered

This prevents wrong or multiple inputs.

---

## 🧪 Simulation

![Simulation](images/simulation.png)

Simulation verifies:
- Snake movement  
- Direction control  
- Reset functionality  

Clock is sped up during simulation to test quickly.

---

## 📊 Results

![Resource Utilization](images/resource.png)

![Power Analysis](images/power.png)

### Observations:
- ~3450 LUTs used  
- ~1481 Flip-Flops used  
- Power consumption ~0.12 W  
- No timing violations  

---

## 🔌 Hardware Used
- FPGA Board: **Nexys 4 (Artix-7)**
- VGA Monitor
- Push Buttons for input

---

## ▶️ How to Run

1. Open project in **Xilinx Vivado**
2. Add:
   - Verilog files (`.v`)
   - Constraint file (`.xdc`)
3. Run:
   - Synthesis  
   - Implementation  
   - Generate Bitstream  
4. Program FPGA
5. Connect VGA monitor

Game will start on screen 🎮

---

## ✨ Key Features
- Fully hardware-based game  
- Real-time performance  
- Parallel execution  
- Modular design  
- Low power consumption  

---

## 👨‍💻 Team Contributions
- Game logic implementation  
- VGA signal generation  
- Clock and timing design  
- Testing and debugging  

---

## 🔗 GitHub Repository
https://github.com/gjjaswanth/SnakeGame-using-FPGA

---

## 🏁 Conclusion
This project demonstrates how FPGA can be used to design a **complete real-time system**.

Instead of writing software, we designed:
- Data flow
- Signal timing
- Parallel execution

This highlights the power of FPGA in hardware-based applications.

---

## 💡 Presentation Tip
You can explain the project in one line:

"The FPGA continuously draws the screen, updates the snake at a slower rate, and checks inputs in parallel, enabling smooth real-time gameplay."
