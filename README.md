# UART RTL Design and Functional Verification

An 8-bit UART (Universal Asynchronous Receiver-Transmitter) implemented using Verilog HDL, featuring baud-rate generation, 16× oversampling, internal loopback testing, and self-checking testbench verification.

## Overview

This project implements a UART transmitter and receiver with an integrated top-level module. The transmitter serializes parallel data into UART frames, while the receiver detects incoming serial data and reconstructs the original 8-bit parallel data.

The design uses an internal loopback connection, allowing transmitted data to be received and verified within the same system.

## Features

- 8-bit UART data transmission and reception.
- Baud-rate generation for UART timing.
- 16× oversampling for receiver operation.
- Serial transmission with start and stop bits.
- Internal TX-to-RX loopback.
- Busy and ready status flag handling.
- Reset support.
- Self-checking Verilog testbench.

## Design Architecture

The design consists of four main RTL modules:

| Module | Description |
|---|---|
| `baud_rate_generator.v` | Generates timing enables for UART transmission and reception. |
| `transmitter.v` | Converts parallel data into serial UART frames. |
| `receiver.v` | Samples incoming serial data and reconstructs the original byte. |
| `uart_top.v` | Integrates the transmitter, receiver, and baud-rate generator. |

The testbench is implemented separately in `uart_tb.v`.

## System Configuration

| Parameter | Value |
|---|---|
| Clock frequency | 50 MHz |
| Baud rate | 9600 bps |
| Data width | 8 bits |
| Receiver oversampling | 16× |
| Simulation tool | Xilinx Vivado / XSim |
| HDL | Verilog |

## Verification

A self-checking Verilog testbench was developed to verify the functionality of the UART design.

The testbench covers the following scenarios:

1. **Basic functional testing:** Transmission and reception of different data patterns, including `8'h41`, `8'h55`, `8'hAA`, `8'hFF`, and other values.
2. **Ready flag verification:** Checks whether the ready flag remains asserted until explicitly cleared.
3. **Busy condition testing:** Verifies that a new write request is ignored while the transmitter is busy.
4. **Reset during transmission:** Checks whether the UART returns to its idle state after a reset during transmission.
5. **Random data testing:** Tests the design with randomly generated 8-bit data values.

### Simulation Results

| Metric | Result |
|---|---:|
| Total verification checks | 25 |
| Passed | 25 |
| Failed | 0 |

**All testbench checks passed successfully in Vivado simulation.**

## Repository Structure

```text
UART-RTL-Design-and-Verification/
│
├── baud_rate_generator.v
├── transmitter.v
├── receiver.v
├── uart_top.v
├── uart_tb.v
├── README.md
│
└── Simulation_Results/
    ├── UART_Waveform.png
    └── UART_Test_Summary.png
```

## Running the Simulation

1. Open Xilinx Vivado.
2. Create a new RTL project.
3. Add the four design files as Design Sources.
4. Add `uart_tb.v` under Simulation Sources.
5. Set `uart_tb` as the simulation top module.
6. Run Behavioral Simulation.
7. Run the simulation for approximately 25 ms to observe the complete verification sequence.
8. Check the Tcl Console for the test summary and the waveform window for signal transitions.

## Tools and Technologies

- Verilog HDL
- Xilinx Vivado
- XSim Behavioral Simulator

## Future Improvements

The following enhancements are planned to extend the verification capabilities of the project:

- **SystemVerilog-based verification:** Develop a structured testbench using SystemVerilog.
- **Driver, Monitor and Scoreboard:** Implement modular verification components for stimulus generation, signal monitoring and automated output checking.
- **Functional Coverage:** Introduce coverage-driven verification to track the scenarios exercised during simulation.
- **SystemVerilog Assertions (SVA):** Add assertions to check UART protocol behavior and important design conditions.

## Key Learning Outcomes

- RTL design and modular hardware development.
- UART serial communication protocol.
- Baud-rate generation and clock-enable techniques.
- Receiver oversampling and serial data sampling.
- Functional verification using self-checking testbenches.
- Debugging and waveform analysis.

---

**Project Focus:** RTL Design | Digital Design | UART Communication | Functional Verification
