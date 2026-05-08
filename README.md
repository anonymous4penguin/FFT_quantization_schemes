# Quantization-Aware 1024-Point Radix-2² SDF FFT Optimization
This repository contains the complete implementation of a quantization-aware 1024-point radix-2² Single-Path Delay Feedback (SDF) FFT architecture optimized using multi-objective evolutionary optimization.

The work combines:
* Stage-wise wordlength optimization
* Mixed quantization strategies
* SQNR-aware hardware exploration
* FPGA implementation using Vivado
* ASIC area estimation using OpenROAD
* NSGA-II based Pareto optimization


# Features
* 1024-point radix-2² SDF FFT architecture
* Independent stage-wise quantization control
* Support for:
  * BT (Bit Truncation)
  * BR (Bit Rounding)
  * HUB (Half Unit Biased)
  * THUB (Truncation + HUB)
* SQNR estimation framework
* OpenROAD-based ASIC area characterization
* FPGA resource estimation using Vivado
* Pareto-front optimization using NSGA-II


# Optimization Objectives
The optimization framework simultaneously minimizes:
* ASIC area
* FPGA resources
* SQNR degradation

using NSGA-II based multi-objective evolutionary search.


# FPGA Evaluation Metrics
The following FPGA metrics are evaluated using Vivado:
* LUTs
* FFs
* DSP slices
* BRAM
* Slices
* fMAX
* Power
* Latency


# ASIC Evaluation Metrics
ASIC area estimation is performed using:
* OpenROAD
* Nangate45 PDK


# Example Pareto Optimization Output
The framework generates Pareto-optimal FFT configurations with varying:
* stage-wise wordlengths
* stage-wise quantization modes
* SQNR-area tradeoffs


# Tools Used
* Python
* NumPy
* Matplotlib
* Vivado
* OpenROAD
* NSGA-II


# Research Contribution
This work proposes a hardware-aware quantization optimization framework for radix-2² SDF FFT architectures using joint FPGA and ASIC evaluation.
