# STM32L071 Sensor Hub 🐝

A professional, RTOS-based firmware for monitoring smart beehives using **STM32L071CBT6**.

## 🚀 Project Architecture
- **Core:** Main application logic and system initialization.
- **Drivers/Sensors:** Modular drivers for external peripherals (MCP3008, Bluetooth, EEPROM).
- **Power Islands:** Optimized power management for long-term battery operation.

## 🛠️ Tech Stack
- **RTOS:** FreeRTOS for task management.
- **Compiler:** arm-none-eabi-gcc.
- **Build System:** Custom Makefile.
- **Hardware Design:** EasyEDA.

## 📂 Folder Structure
- `Core/Inc`: Header files.
- `Core/Src`: Application source code.
- `Drivers/Sensors`: Custom drivers for sensors.
