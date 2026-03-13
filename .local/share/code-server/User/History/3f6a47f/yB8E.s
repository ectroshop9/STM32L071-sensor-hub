/* startup_stm32l071xx.s */
.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb

.global g_pfnVectors
.global Default_Handler

/* تحديد نهاية الـ RAM لبداية الـ Stack */
.word _estack
.word Reset_Handler

.section .isr_vector,"a",%progbits
g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  /* الفراغات المتبقية لجدول المتجهات */
  .rept 28
  .word Default_Handler
  .endr

.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
  ldr r0, =_estack
  mov sp, r0          /* تعيين مؤشر المكدس */
  bl main             /* القفز للدالة main في ملفك */
  bx lr

.section .text.Default_Handler,"ax",%progbits
Default_Handler:
LoopForever:
  b LoopForever