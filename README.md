# 🧠 Computer Architecture Projects

A collection of CPU architecture projects implemented in **C++** and **Verilog**.

This repository documents a step-by-step implementation of simple MIPS-like CPU designs, starting from a single-cycle datapath and gradually extending it into a pipelined processor with hazard handling, data forwarding, and branch prediction.

## ✨ Highlights

- Implemented CPU behavior in both **C++ simulator** and **Verilog hardware description**
- Built multiple CPU designs with increasing architectural complexity
- Used hexadecimal test programs to validate instruction execution
- Compared simulation results across C++, Verilog, and reference MIPS execution tools
- Practiced datapath/control design, pipeline registers, hazard handling, and branch control

## 📁 Projects

| Project | Description |
|---|---|
| [`single_cycle_cpu_ComputerArchitecture`](./single_cycle_cpu_ComputerArchitecture) | Basic single-cycle CPU implementation |
| [`multicycle_cpu_ComputerArchitecture`](./multicycle_cpu_ComputerArchitecture) | Multi-cycle CPU implementation with staged instruction execution |
| [`pipelined_cpu_ComputerArchitecture`](./pipelined_cpu_ComputerArchitecture) | 5-stage pipelined CPU with stall-based hazard handling |
| [`pipelined_cpu_w_forwarding_bp_ComputerArchitecture`](./pipelined_cpu_w_forwarding_bp_ComputerArchitecture) | Pipelined CPU extended with data forwarding and branch prediction |

## 🛠️ Tech Stack

- **C++**
- **Verilog**
- **Vivado**
- **Makefile**
- **MIPS-style instruction execution**
- **Hex / memory initialization test cases**

## 🚀 Running the C++ Simulator

Each project contains a C++ implementation.

```bash
cd <project>/cpp
make
./cpu testcaseN.hex
```

`testcaseN.hex` is a hexadecimal input program used to test CPU execution.

## 🔬 Running the Verilog Simulation

Each project also contains a Verilog implementation.

1. Generate or prepare the memory initialization file.
2. Load the memory file into the Verilog testbench.
3. Run the simulation in Vivado.
4. Compare the output with the C++ simulator or a reference MIPS execution result.

## 📌 Project Progression

```text
Single-Cycle CPU
      ↓
Multi-Cycle CPU
      ↓
Pipelined CPU
      ↓
Pipelined CPU + Forwarding + Branch Prediction
```

The repository is organized to show how CPU design evolves as performance techniques are introduced step by step.

## 📚 What I Practiced

- CPU datapath and control signal design
- Instruction fetch/decode/execute/memory/write-back flow
- Pipeline stage separation
- Data hazard detection
- Stall and forwarding logic
- Basic branch prediction strategy
- Consistency checking between software simulation and hardware simulation
