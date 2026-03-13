##########################################################################################################################
# STM32Make.make - Final Professional Version for STM32L071CBT6
# Designed for Cloud Environment (ARM-NONE-EABI GCC)
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
# إضافة ملفاتك هنا يدوياً أو عبر البحث التلقائي
C_SOURCES =  \
main.c \
$(wildcard Core/Src/*.c) \
$(wildcard Drivers/STM32L0xx_HAL_Driver/Src/*.c)

# ملف الـ Startup ضروري جداً لتشغيل المعالج
ASM_SOURCES =  \
startup_stm32l071xx.s

#######################################
# Binaries (The Tools)
#######################################
# هذا الجزء هو الحل النهائي لخطأ "cc: error"
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
# مواصفات المعالج STM32L0 (Cortex-M0+)
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

# توليد ملفات الاعتمادية (Dependency files)
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS (Linker Settings)
#######################################
# يجب أن يتوافق اسم الملف مع الملف الموجود في مجلدك
LDSCRIPT = STM32L071CBTX_FLASH.ld

# المكتبات المستخدمة
LIBS = -lc -lm -lnosys 
LDFLAGS = $(MCU) -T$(LDSCRIPT) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections -Wl,--print-memory-usage

#######################################
# Build Rules
#######################################
# تحويل المسارات لملفات الـ Object
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

# تحويل الملف إلى صيغ أخرى
$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(HEX) $< $@

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf
	$(BIN) $< $@

# إنشاء المجلدات إذا لم تكن موجودة
$(BUILD_DIR):
	mkdir -p $@

$(OBJ_DIR):
	mkdir -p $@

# تنظيف المشروع
clean:
	rm -rf $(BUILD_DIR)

#######################################
# Dependencies
#######################################
-include $(wildcard $(OBJ_DIR)/*.d)

# *** EOF ***