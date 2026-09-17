# 🏨 SystemHotelReservation

## ANSWER ASSIGNMENT:
**Project Name:** Hotel Reservation System using Assembly Language.

### AS A FULFILLMENT OF CAO COURSE PROJECT
* **Supervised by:** Dr. Abdulwasea Alazani & Eng. Bakeel Azman
* **Student Name:** [اكتب اسمك هنا]
* **Academic Year:** 2026-2025

---

## 1. INTRODUCTION

### 1.1. About Assignment
This documentation explains the significant fundamentals of Assembly Language applied to a **Hotel Reservation System**. The application manages room availability, guest check-ins, and checkout calculations. The project demonstrates low-level hardware control, memory utilization, and software architecture using the **NASM Assembler** and GNU linker on Linux (or your specific tools).

### 1.2. What Is NASM Assembler?
NASM (Netwide Assembler) is an open-source x86 and x86_64 assembler designed for portability and modularity. It supports various object file formats like ELF and Win32/Win64, utilizing a clean, simple syntax that distinguishes data sections clearly.

---

## 2. DOWNLOADING AND INSTALLING THE ENVIRONMENT

### 2.1. Setting Up NASM and Tools
To build and verify the development platform on your system:
* Check architecture alignment using: `lscpu`
* Install the assembler package via: `sudo apt-get update && sudo apt-get install nasm`
* Verify installation state using: `nasm -v`

---

## 3. WRITING "SystemHotelReservation" PROGRAM

### 3.1. Setting up Project
Create a dedicated project tree to isolate object files and executable binaries:
```bash
mkdir Desktop/HotelReservation
cd Desktop/HotelReservation
touch HotelReservation.asm
nano HotelReservation.asm
```

### 3.2. Comments
Single-line annotations within the implementation use the `;` symbol. These lines are completely ignored by the assembler during compilation and serve to clarify data records and logic flags.

### 3.3. Sections
The source architecture partitions memory layout into distinct system frames:
* **`section .bss`**: Allocates uninitialized runtime variables (e.g., buffer reservations for input names).
* **`section .data`**: Stores initialized constants, operational status strings, and UI menu layouts.
* **`section .text`**: Houses the logical execution path and standard operations.

### 3.4. Variables and Constants
Data blocks utilize explicit directive definitions like `db` (declare byte) and constants declared via `equ` to manage hotel pricing structures, room numbers, and input array parameters.

### 3.5. Procedures and Entry Points
Logical execution uses standard procedural frames tagged with `global _start`. Modular tasks (such as processing room choices or computing bills) terminate cleanly using the `ret` opcode instruction.

### 3.6. Macros
Inline processing logic parameters rely on custom programmatic macros (such as custom string printing or keyboard input handlers) to minimize repetitive terminal code blocks.

### 3.7. Conclusion
Code structure completion saves state and safely closes input files via the `Ctrl + X` sequence inside the compiler terminal shell.

---

## 4. ASSEMBLING PROCESS

### 4.1. Assembling Process
The assembler software processes source `.asm` strings to output compiled system machine object files (`.o`).

### 4.2. Compiling the Reservation System Code
```bash
nasm -f elf64 HotelReservation.asm -l HotelReservation.lst -o HotelReservation.o
```

---

## 5. LINKING PROCESS

### 5.1. Linking Process
The linker program combines low-level machine code files together with active system libraries into a final executable application.

### 5.2. Linking Object Files
```bash
ld HotelReservation.o -o HotelReservation
```

---

## 6. EXECUTING PROCESS

### 6.1. Running the System Terminal
```bash
./HotelReservation
```

### 6.2. Execution Machine Cycle Overview
Once executed, the instruction pointers cycle through the standard CPU operational phases:
1. **Fetch**: Retrieves reservation operations from RAM storage.
2. **Decode**: Resolves instruction syntax structures inside the internal decoder.
3. **Execute**: Operates logic instructions across register gates to update records.

---

## 7. REFERENCES
* [1] Assembly Language Step-by-Step, Jeff Duntemann.
* [2] PC Assembly Language, Paul A. Carter.
* [3] The NASM Manual Documentation.
# SystemHotelReservation
مشروع لمادة معمارية وتنظيم الحاسوب بلغة الاسمبلي
