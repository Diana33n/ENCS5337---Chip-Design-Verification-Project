# ENCS5337---Chip-Design-Verification-Project
EDA playground link for this wrok: https://edaplayground.com/x/95eT

This repository contains the RTL design and UVM verification environment for a simplified **Substitution-Permutation Network Cryptographic Unit (SPN-CU)**, developed as part of **ENCS5337 – Chip Design Verification**.

## Overview

The SPN-CU supports encryption and decryption of 16-bit data using 32-bit keys with a 2-bit opcode control. It implements three rounds of substitution (S-Box), permutation, and key mixing, with inverse operations for decryption. Verification was performed using UVM with both randomized and directed tests.

---

## Features

* **Encryption & Decryption**: 16-bit data blocks with 32-bit symmetric keys.
* **Opcode Support**:

  * `01`: Encrypt
  * `10`: Decrypt
  * `00`: No operation
  * `11`: Invalid operation
* **Reset Logic**: Clears outputs and sets idle state.
* **Verification**:

  * Full UVM environment: driver, monitor, scoreboard, sequencer, and environment modules.
  * Randomized and directed stimulus for edge cases.
  * Functional coverage including opcode, S-box inputs, and bit transitions.

---


## Simulation Tools

* **Language**: SystemVerilog
* **Verification Methodology**: UVM
* **Simulator**: Synopsys VCS / Mentor Questa

---

## 

| Name         | Student ID |
| ------------ | ---------- |
| Diana Nasser | 1210363    |
| Hala Jebreel | 1210606    |
| Mayar Jafar  | 1210582    |

Instructor: Dr. Ayman Hroub
- Section: 1 | Date: 10 June 2025

---

