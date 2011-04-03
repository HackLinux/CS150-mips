#include "memory.h"

uint8_t* memset(uint8_t* ptr, uint8_t value, uint32_t num)
{
    for (uint32_t i = 0; i < num; i++) {
        ptr[i] = value;
    }
    return ptr;
}
