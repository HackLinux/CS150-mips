#ifndef ENET_H_
#define ENET_H_

#include "types.h"

#define DEBUG

#define ERECV_CTRL (*((volatile uint32_t*)0xffff0010) & 0x01)
#define ERECV_DATA (*((volatile uint32_t*)0xffff0014) & 0x3FF)

#define ETRAN_CTRL (*((volatile uint32_t*)0xffff0018) & 0x01)
#define ETRAN_DATA (*((volatile uint32_t*)0xffff001c))

#define ENET_SOF (0x100)
#define ENET_EOF (0x200)

#define MAC_ADDR_LEN 6

#define IPV4_ADDR_LEN 4
#define IPV4_HEADER_LEN 20

#define UDP_HEADER_LEN 8

#define ENET_ARP_PACKET 1
#define ENET_IPV4_PACKET 2

typedef struct {
    uint8_t* destination;
    uint8_t* source;

    uint16_t ethertype;
} mac_header_t;

typedef struct {
    mac_header_t* mac_header;

    uint32_t length;

    uint8_t ttl;
    uint8_t protocol;

    uint8_t* source;
    uint8_t* destination;
} ipv4_header_t;

typedef struct {
    ipv4_header_t* ipv4_header;

    uint16_t source;
    uint16_t destination;

    uint16_t length;
} udp_header_t;

typedef struct {
    mac_header_t* mac_header;

    uint16_t htype;
    uint16_t ptype;

    uint8_t hlen;
    uint8_t plen;

    uint16_t oper;

    uint8_t* sha;
    uint8_t* spa;

    uint8_t* tha;
    uint8_t* tpa;
} arp_packet_t;

uint8_t eread_uint8(uint32_t* flags);
uint16_t eread_uint16(uint32_t* flags);
uint32_t eread_uint32(uint32_t* flags);

void eread_uint8v(uint8_t* s, uint32_t n, uint32_t* flags);

void eread_mac_header(mac_header_t* mac_header, uint32_t* flags);

void eread_ipv4_header(ipv4_header_t* ipv4, uint32_t* flags);
uint32_t eread_ipv4_header_arp(ipv4_header_t* ipv4, arp_packet_t* arp, uint32_t* flags);

void eread_udp_header(udp_header_t* udp, uint32_t* flags);
uint32_t eread_udp_header_arp(udp_header_t* udp, arp_packet_t* arp, uint32_t* flags);

void eread_arp_packet(arp_packet_t* arp, uint32_t* flags);

void ewrite_uint8(uint8_t x, uint32_t flags);
void ewrite_uint16(uint16_t x, uint32_t flags);
void ewrite_uint32(uint32_t x, uint32_t flags);

void ewrite_uint8v(const uint8_t* v, uint32_t n, uint32_t flags);

void ewrite_mac_header(const mac_header_t* mac);
void ewrite_ipv4_header(const ipv4_header_t* ipv4);
void ewrite_udp_header(const udp_header_t* udp);

void ewrite_arp_packet(arp_packet_t* arp);

#endif
