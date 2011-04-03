#ifndef UART_H_
#define UART_H_

#include "types.h"

#define URECV_CTRL (*((volatile uint32_t*)0xffff0000) & 0x01)
#define URECV_DATA (*((volatile uint32_t*)0xffff0004) & 0xFF)

#define UTRAN_CTRL (*((volatile uint32_t*)0xffff0008) & 0x01)
#define UTRAN_DATA (*((volatile uint32_t*)0xffff000c))

void uwrite_int8(int8_t c);

void uwrite_int8s(const int8_t* s);

int8_t uread_int8(void);

#endif
