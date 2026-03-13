##########################################################################################################################
# File: STM32Make.make (Custom Cloud Edition for STM32L071CBT6)
##########################################################################################################################

# ------------------------------------------------
# Generic Makefile (based on gcc)
# Optimized for Arm-none-eabi-gcc in Linux Cloud
# ------------------------------------------------

######################################
# Target
######################################
TARGET = SmartHive_L0

#######################################
# Build directories
#######################################
BUILD_DIRECTORY = build
RELEASE_DIRECTORY = $(BUILD_DIRECTORY)/debug

######################################
# Optimization
######################################
DEBUG = 1
OPT = -Og

######################################
# source
######################################
# C sources - أضف هنا أي ملفات .c جديدة تنشئها
C_SOURCES =  \
main.c \
$(wildcard Core/Src/*.c) \
$(wildcard Drivers/STM32L0xx_HAL_Driver/Src/*.c)

# ASM sources
ASM_SOURCES =  \
startup_stm32l071xx.s

#######################################
# Tools
#######################################
# تحديد المترجم بشكل مباشر لإنهاء مشكلة "cc"
ARM_PREFIX = arm-none-eabi-
CC = $(ARM_PREFIX)gcc
AS = $(ARM_PREFIX)gcc -x assembler-with-cpp
CP = $(ARM_PREFIX)objcopy
SZ = $(ARM_PREFIX)size
DP = $(ARM_PREFIX)objdump

HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# cpu - مواصفات STM32L071CBT6
CPU = -mcpu=cortex-m0plus

# fpu - معالجات M0+ لا تدعم FPU هاردوير
FPU = 

# float-abi
FLOAT-ABI = -mfloat-abi=soft

# mcu
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
C_DEFS =  \
-DUSE_HAL_DRIVER \
-DSTM32L071xx

# C includes
C_INCLUDES =  \
-ICore/Inc \
-IDrivers/STM32L0xx_HAL_Driver/Inc \
-IDrivers/STM32L0xx_HAL_Driver/Inc/Legacy \
-IDrivers/CMSIS/Device/ST/STM32L0xx/Include \
-IDrivers/CMSIS/Include \
-I.

# compile gcc flags
ASFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) -Og -Wall -fdata-sections -ffunction-sections
CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections -g -gdwarf -ggdb

# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS
#######################################
# تأكد من وجود هذا الملف في مجلد المشروع
LDSCRIPT = STM32L071CBTX_FLASH.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIRECTORY)/$(TARGET).map,--cref -Wl,--gc-sections -Wl,--print-memory-usage

#######################################
# build the application
#######################################
OBJECTS = $(addprefix $(RELEASE_DIRECTORY)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))

OBJECTS += $(addprefix $(RELEASE_DIRECTORY)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))

all: $(RELEASE_DIRECTORY)/$(TARGET).elf $(RELEASE_DIRECTORY)/$(TARGET).hex $(RELEASE_DIRECTORY)/$(TARGET).bin

$(RELEASE_DIRECTORY)/%.o: %.c STM32Make.make | $(RELEASE_DIRECTORY)
	@echo "Compiling $<"
	@$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(@:.o=.lst) $< -o $@

$(RELEASE_DIRECTORY)/%.o: %.s STM32Make.make | $(RELEASE_DIRECTORY)
	@echo "Assembling $<"
	@$(AS) -c $(ASFLAGS) $< -o $@

$(RELEASE_DIRECTORY)/$(TARGET).elf: $(OBJECTS) STM32Make.make | $(RELEASE_DIRECTORY)
	@echo "Linking $@"
	@$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@$(SZ) $@

$(RELEASE_DIRECTORY)/%.hex: $(RELEASE_DIRECTORY)/%.elf | $(RELEASE_DIRECTORY)
	@$(HEX) $< $@

$(RELEASE_DIRECTORY)/%.bin: $(RELEASE_DIRECTORY)/%.elf | $(RELEASE_DIRECTORY)
	@$(BIN) $< $@

$(RELEASE_DIRECTORY):
	mkdir -p $@

clean:
	rm -fR $(BUILD_DIRECTORY)

#######################################
# dependencies
#######################################
-include $(wildcard $(RELEASE_DIRECTORY)/*.d)