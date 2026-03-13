/* Entry Point */
ENTRY(Reset_Handler)

/* Memory Definition for STM32L071CBT6 */
MEMORY
{
  RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 20K
  FLASH (rx)      : ORIGIN = 0x08000000, LENGTH = 128K
}

/* Sections */
SECTIONS
{
  .text :
  {
    KEEP(*(.isr_vector))
    *(.text*)
    *(.rodata*)
    _etext = .;
  } > FLASH

  .data : 
  {
    _sdata = .;
    *(.data*)
    _edata = .;
  } > RAM AT > FLASH

  .bss :
  {
    _sbss = .;
    *(.bss*)
    _ebss = .;
  } > RAM
}