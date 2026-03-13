##########################################################################################################################
# STM32Make.make - Final Professional Version for STM32L071CBT6
# Updated for Structured Directory: Core/Src and Drivers/
##########################################################################################################################

# ------------------------------------------------
# Generic Makefile (based on gcc)
# ------------------------------------------------

######################################
# Target
######################################
TARGET = SmartHive_L0

#######################################
# Build directories
#######################################
BUILD_DIR = build
OBJ_DIR = $(BUILD_DIR)/obj

######################################
# Optimization
######################################
OPT = -Og
DEBUG = 1

######################################
# Source Files
######################################
# تعديل المسارات لتطابق الهيكل الجديد Core/Src
C_SOURCES =  \
Core/Src/main.c \
$(wildcard Drivers/Sensors/*.c) \
$(wildcard Drivers/STM32L0xx_HAL_Driver/Src/*.c) \
$(wildcard Core/Src/*.c)

# تعديل مسار ملف البداية
ASM_SOURCES =  \
Core/Src/startup_stm32l071xx.s

#######################################
# Binaries (The Tools)
#######################################
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS (Processor Specific)
#######################################
CPU = -mcpu=cortex-m0plus
MCU = $(CPU) -mthumb -mfloat-abi=soft

# تعاريف الماكرو
C_DEFS =  \
-DUSE_HAL_DRIVER \
-DSTM32L071xx

# مسارات الـ Include (ملفات الـ .h)
C_INCLUDES =  \
-ICore/Inc \
-IDrivers/STM32L0xx_HAL_Driver/Inc \
-IDrivers/STM32L0xx_HAL_Driver/Inc/Legacy \
-IDrivers/CMSIS/Device/ST/STM32L0xx/Include \
-IDrivers/CMSIS/Include \
-I.

# تجميع الأعلام (Flags)
ASFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -g -gdwarf -ggdb

# توليد ملفات الاعتمادية
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS (Linker Settings)
#######################################
LDSCRIPT = STM32L071CBTX_FLASH.ld

LIBS = -lc -lm -lnosys 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections -Wl,--print-memory-usage

#######################################
# Build Rules
#######################################
# استخراج أسماء ملفات الـ Object وتوجيهها لمجلد build/obj
OBJECTS = $(addprefix $(OBJ_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(OBJ_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

# القاعدة الأساسية للبناء
all: $(BUILD_DIR)/$(TARGET).elf $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).bin

# ترجمة ملفات C
$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR)
	@echo "Compiling: $<"
	$(CC) -c $(CFLAGS) $< -o $@

# ترجمة ملفات Assembly
$(OBJ_DIR)/%.o: %.s | $(OBJ_DIR)
	@echo "Assembling: $<"
	$(AS) -c $(ASFLAGS) $< -o $@

# عملية الـ Linking النهائية
$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) | $(BUILD_DIR)
	@echo "Linking: $@"
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(BIN) $< $@

$(BUILD_DIR):
	mkdir -p $@

$(OBJ_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

-include $(wildcard $(OBJ_DIR)/*.d)

# *** EOF ***