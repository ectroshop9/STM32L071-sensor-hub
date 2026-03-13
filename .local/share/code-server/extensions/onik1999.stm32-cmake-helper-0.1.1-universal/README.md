# 📦 STM32 CMake Helper

Initialize and configure STM32 CMake projects automatically inside VSCodium / VS Code.

This extension prepares your STM32 project for building and debugging with:

1. CMake Presets

2. Ninja or Make

3. Cortex-Debug

4. OpenOCD

5. clangd

## 🚀 Features

✅ Creates:

* build/Debug

* build/Release

✅ Generates:

* .vscode/tasks.json

* .vscode/launch.json

* .clangd

✅ Automatically detects:

* Project name from CMakeLists.txt

* MCU family from .ioc

* Correct OpenOCD target configuration

### GDB executable:

* arm-none-eabi-gdb

* or gdb-multiarch (Ubuntu/Debian)

✅ Runs:

* cmake --preset Debug

* cmake --preset Release

📋 Requirements

You must have:

1. 1️⃣ CMake (with presets support)

Check:

* cmake --version


CMake 3.21+ recommended.

2. 2️⃣ ARM Toolchain

Ubuntu / Debian

```
sudo apt install gcc-arm-none-eabi gdb-multiarch
```
Or STM32Cube Toolchain

Install STM32CubeCLT and ensure:

arm-none-eabi-gcc
arm-none-eabi-gdb


are available in your PATH.

3. 3️⃣ OpenOCD

Install OpenOCD:
```
sudo apt install openocd
```

Or use STM32Cube bundled version.

4. 4️⃣ Required VS Code Extensions

### Install:

* Cortex-Debug

* clangd

## 🛠 How To Use

Open your STM32 CMake project folder in VSCodium.

Open Command Palette:

Ctrl + Shift + P


Run:

STM32: Initialize Project


The extension will:

* Create build folders

* Generate configuration files

* Detect MCU and GDB

* Configure debugging

* Run CMake presets

## 🧠 How MCU Detection Works

The extension reads your .ioc file and detects:

Mcu.Family=STM32F3


It automatically sets the correct OpenOCD target:

target/stm32f3x.cfg


Supported families:

* STM32F0

* STM32F1

* STM32F2

* STM32F3

* STM32F4

* STM32F7

* STM32G0

* STM32G4

* STM32H7

* STM32L0

* STM32L1

* STM32L4

* STM32L5

* STM32WB

* STM32WL

## 🧩 GDB Auto-Detection

The extension automatically searches for:

arm-none-eabi-gdb

If not found → gdb-multiarch

On Ubuntu, gdb-multiarch is commonly used.

If no GDB is found, you will see an error message.

## 🐛 Troubleshooting

❌ Error: "GDB executable was not found"

Install:
```
sudo apt install gdb-multiarch
```

Or install STM32Cube Toolchain.

❌ Error: OpenOCD not found

Install:
```
sudo apt install openocd
```

Or add OpenOCD to PATH.

❌ CMake preset error

Make sure your project has:

CMakePresets.json


With Debug and Release presets defined.

## 🖥 Supported Platforms

* Linux

* Windows

* macOS

## 📦 Installation (VSCodium)

Search in Extensions tab:

STM32 CMake Helper


Or install manually:

```
codium --install-extension stm32-cmake-helper-x.x.x.vsix
```

## 🛣 Roadmap

* Automatic OpenOCD detection

* Toolchain auto-configuration

* Windows STM32Cube path detection

* Advanced multi-target support

# 📄 License

***MIT License***

# 👨‍💻 Author

Onik Babajanyan

Embedded Systems Engineer
FabLab Armenia
fablabarmenia.com

# Reporting Issue

Just go by this link and open issue in github [repo](https://github.com/Onik1999/STM32_helper_ext).
