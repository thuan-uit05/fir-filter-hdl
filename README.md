# FIR Filter in Verilog HDL

🎯 **FIR Filter implemented in Verilog HDL**, with both optimal and non-optimal architectures.  
Includes Wishbone bus interface and testbenches.

---

## 📌 Table of Contents
- [Overview](#overview)
- [Project Structure](#project-structure)
- [Design Details](#design-details)
- [Simulation](#simulation)
- [License](#license)

---

## 🚀 Overview
This project implements a Finite Impulse Response (FIR) filter in Verilog HDL.
It includes:
- **Non-optimal design:** straightforward structure
- **Optimal design:** improved resource usage and performance
- Integration with **Wishbone bus** for easy SoC communication
- Testbenches to verify functionality

---

## 📂 Project Structure
```
.
├── Non-optimal/
│   ├── fir.v
│   ├── fir_wishbone.v
│   ├── wishbone.v
│   └── testbench.v
└── Optimal/
    ├── FIR.v
    ├── FIR_Master.v
    ├── fir_system.v
    ├── fir_wishbone.v
    ├── wishbone.v
    └── tb_fir_system.v
```

---

## ⚙️ Design Details

### Non-optimal
- Simple FIR structure for educational purposes.
- Uses direct multiply-accumulate.

### Optimal
- Optimized for hardware utilization.
- Includes FIR system controller and master module.
- Better suited for FPGA implementation.

### Wishbone interface
- Both designs integrate with a Wishbone bus module (`wishbone.v` / `fir_wishbone.v`).
- Allows easy integration in SoC systems.

---

## 🧪 Simulation
Each folder contains its own testbench file.

### Example:
```bash
# Using Icarus Verilog
cd Optimal
iverilog -o tb tb_fir_system.v FIR.v FIR_Master.v fir_system.v fir_wishbone.v wishbone.v
vvp tb
```

---

## 📜 License
MIT License.

---

🚀 **Enjoy & Star this repo if you like it!**
