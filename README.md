# PingPongFasm

**PingPongFasm** is a basic yet fully functional ping pong game developed in [FASM2](https://flatassembler.net/) using assembly language. This project showcases how to build a simple game with minimalistic code and efficient design while leveraging [raylib](https://www.raylib.com/) for graphics and input handling.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation and Build](#installation-and-build)
- [Usage](#usage)
- [Contributors](#contributors)
- [License](#license)
- [Acknowledgements](#acknowledgements)

---

## Overview

PingPongFasm is a classic ping pong game implemented in assembly language with FASM2. It demonstrates the possibilities of low-level programming while providing a hands-on example of integrating a graphics library (raylib) into your assembly projects. The project is ideal for enthusiasts who wish to explore game development in assembly, understand hardware-level control, or simply enjoy a retro gaming experience.

---

## Prerequisites

Before building and running PingPongFasm, ensure you have the following installed:

- **FASM2 (Flat Assembler):** [Download FASM2](https://flatassembler.net/)
- **raylib 5.5:** The project includes the required raylib files in the `raylib-5.5` directory.
- **Make:** For Unix-based systems, or an equivalent build system on Windows.

*Note: Depending on your platform, you might need to adjust the Makefile or build scripts accordingly.*

---

## Installation and Build

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/Atduyar/PingPongFasm.git
   cd PingPongFasm
   ```

2. **Build the Project:**

   On Unix-based systems, simply run:

   ```bash
   make
   ```

   This command will compile the assembly source (`main.asm`) and link the raylib dependencies accordingly.

3. **Running the Game:**

   After successful compilation, run the generated executable:

   ```bash
   ./PingPongFasm
   ```

*For Windows users, adjust the build commands based on your environment or use a suitable IDE that supports FASM.*

---

## Usage

- **Game Controls:**
  - Use the keyboard to control the paddles.
  - N/A

---

## Contributors

- [**Atduyar (Ahmet Tarık Duyar)**](https://github.com/Atduyar)
- [**VenomTS**](https://github.com/VenomTS)
- [**AStalinist**](https://github.com/AStalinist)

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- **FASM2:** The Flat Assembler is an incredible tool that allows low-level programming with ease. [Learn more about FASM2](https://flatassembler.net/).
- **raylib:** Thanks to the raylib community for providing a simple and easy-to-use graphics library that made this project possible. [Visit raylib](https://www.raylib.com/).

