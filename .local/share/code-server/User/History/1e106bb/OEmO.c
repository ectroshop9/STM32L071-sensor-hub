#include <stdint.h>

// تعريف سجلات التحكم في الـ GPIO (كمثال بسيط)
#define RCC_IOPENR   (*(volatile uint32_t*)(0x40021000 + 0x2C))
#define GPIOA_MODER  (*(volatile uint32_t*)(0x40020000 + 0x00))
#define GPIOA_ODR    (*(volatile uint32_t*)(0x40020000 + 0x14))

void delay(void) {
    for (volatile int i = 0; i < 100000; i++);
}

int main(void) {
    // 1. تفعيل الساعة لـ GPIOA
    RCC_IOPENR |= (1 << 0);
    
    // 2. ضبط PA5 كمخرج (Output) - الليد المدمج غالباً في Nucleo
    GPIOA_MODER &= ~(3 << (5 * 2));
    GPIOA_MODER |= (1 << (5 * 2));

    while (1) {
        GPIOA_ODR ^= (1 << 5); // عكس حالة الليد
        delay();
    }
}