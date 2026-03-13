.syntax unified
.cpu cortex-m0plus
.fpu softvfp
.thumb

.global g_pfnVectors
.global Default_Handler

/* تحديد المتجهات الأساسية */
.section .isr_vector,"a",%progbits
g_pfnVectors:
  .word _estack
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  /* تكرار المعالج الافتراضي لبقية المقاطعات */
  .rept 28
  .word Default_Handler
  .endr

.section .text.Reset_Handler
.weak Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
  ldr r0, =_estack
  mov sp, r0          /* تعيين مؤشر المكدس */
  bl main             /* القفز إلى دالة main */
  bx lr

/* المعالج الافتراضي في حالة حدوث مقاطعة غير معرفة */
.section .text.Default_Handler,"ax",%progbits
Default_Handler:
LoopForever:
  b LoopForever

/* تعريف الدوال الضعيفة لتجنب أخطاء اللينكر */
.weak NMI_Handler
.thumb_set NMI_Handler,Default_Handler

.weak HardFault_Handler
.thumb_set HardFault_Handler,Default_Handler