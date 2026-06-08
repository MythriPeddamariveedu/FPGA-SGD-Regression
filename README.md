# FPGA Implementation of Stochastic Gradient Descent (SGD) for Regression Algorithms

FPGA implementation of Stochastic Gradient Descent (SGD) for regression algorithms using Verilog HDL, including RTL design, simulation, and hardware validation.

## Overview

This project implements a machine learning regression model on FPGA using Verilog HDL. A Stochastic Gradient Descent (SGD) Regression model is trained in Python using a car price dataset, and the trained parameters are converted into fixed-point representation for FPGA deployment.

The FPGA reads input features from memory files, performs hardware-based prediction, and generates estimated car prices in real time.

---

## Project Objective

The objective of this project is to explore hardware acceleration of machine learning algorithms by implementing an SGD-based regression predictor on FPGA using fixed-point arithmetic.

---

## Design Flow

```text
Dataset (Car Details CSV)
        ↓
Python Training (SGDRegressor)
        ↓
Fixed-Point Conversion (Q10)
        ↓
Generate Parameters & MEM Files
        ↓
Verilog RTL Implementation
        ↓
Vivado Simulation & Synthesis
        ↓
FPGA Prediction Output
```
---

## Architecture

The system consists of:

- Feature memories (x1.mem – x6.mem)
- Fixed-point weights and bias
- Multiply-Accumulate (MAC) datapath
- Prediction output generation
- Control logic for sample processing

### Top-Level Block Diagram

![RTL Schematic](Results/RTL_Schematic.png)

---

## Repository Structure

```text
FPGA-SGD-Regression/
│
├── RTL/
│   ├── top.v
│   ├── predict_mem.v
│   └── sgd_params.vh
│   └── weights.text
│
├── Testbench/
│   └── tb_top.v
│
├── Dataset/
│   ├── Car details v3.csv
│   ├── x1.mem
│   ├── x2.mem
│   ├── x3.mem
│   ├── x4.mem
│   ├── x5.mem
│   ├── x6.mem
│   └── y_actual.mem
│
├── Python/
│   └── prepare_data.py
│
├── Results/
│   ├── RTL_Schematic.png
│   ├── Prediction_vs_Actual.png
│   ├── Post_Synthesis_Utilization.png
│   └── Post_Implementation_Utilization.png
│
└── README.md
```

---

## Files Description

### Python

#### prepare_data.py

- Reads the car price dataset
- Trains SGDRegressor
- Converts floating-point weights to Q10 fixed-point format
- Generates memory initialization files
- Creates FPGA parameter file (`sgd_params.vh`)

### RTL Design

#### predict_mem.v

- Hardware prediction engine
- Reads feature values from ROM memories
- Performs fixed-point multiply-accumulate operations
- Generates predicted output

#### top.v

- Top-level FPGA module
- Integrates datapath and control logic

#### sgd_params.vh

- Fixed-point weights
- Bias value
- Design parameters

### Verification

#### tb_top.v

- Vivado simulation testbench
- Compares predicted values with actual dataset values

---

## Fixed-Point Representation

The trained model parameters are converted to Q10 fixed-point format before FPGA deployment.

This approach:

- Reduces hardware complexity
- Eliminates floating-point units
- Improves FPGA resource efficiency

---

## Simulation Results

Prediction results obtained from Vivado simulation:

![Prediction Results](Results/Prediction_vs_Actual.png)

Example Output:

| Sample | Predicted Price | Actual Price |
|----------|----------------|-------------|
| 1 | Rs. 10,10,000 | Rs. 7,00,000 |
| 2 | Rs. 5,90,000 | Rs. 5,20,000 |
| 3 | Rs. 4,60,000 | Rs. 4,20,000 |

---

## FPGA Resource Utilization

### Post-Synthesis

![Post Synthesis](Results/Post_Synthesis_Utilization.png)

### Post-Implementation

![Post Implementation](Results/Post_Implementation_Utilization.png)

Observed Utilization:

| Resource | Utilization |
|-----------|------------|
| LUTs | 3% |
| FFs | 1% |
| BRAM | 5% |
| DSP | 30% |

The design achieves low logic utilization while leveraging DSP blocks for efficient arithmetic computation.

---

## Vivado Flow

### Step 1

Place:

- Car details v3.csv
- prepare_data.py

in the same folder.

Run:

```bash
python prepare_data.py
```

### Step 2

Add RTL files:

```text
top.v
predict_mem.v
sgd_params.vh
```

### Step 3

Add memory files:

```text
x1.mem
x2.mem
x3.mem
x4.mem
x5.mem
x6.mem
y_actual.mem
```

### Step 4

Add simulation sources:

```text
tb_top.v

```

### Step 5

Run:

- Behavioral Simulation
- Synthesis
- Implementation

---

## Output Format

The FPGA generates a 16-bit signed prediction output.

```text
Predicted Price = y_pred × 10000
```
Example:

```text
y_pred = 45
```

Predicted Price:

```text
Rs. 4,50,000
```

---

## Tools Used

- Verilog HDL
- Python
- Scikit-learn
- NumPy
- Vivado Design Suite
- FPGA Development Board

---

## Applications

- FPGA-based Machine Learning Acceleration
- Edge AI Systems
- Real-Time Prediction Engines
- Hardware Accelerators for Regression Models

---

## Key Achievements

- Implemented regression prediction on FPGA using Verilog HDL
- Converted trained SGD model parameters to fixed-point format
- Verified functionality through Vivado simulation
- Achieved successful synthesis and implementation
- Evaluated FPGA resource utilization

---

## Future Improvements

- Online hardware training support
- Higher precision fixed-point formats
- Support for additional regression algorithms
- Multi-feature scalable architecture
- Real-time streaming inputs

---

