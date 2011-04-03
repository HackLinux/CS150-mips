#include "enet.h"

#if defined(DEBUG)
#include "uart.h"
#include "ascii.h"
#endif

uint8_t eread_uint8(uint32_t* flags)
{
    while (!ERECV_CTRL) ;

    uint32_t word = ERECV_DATA;
    if (flags != NULL) {
        *flags |= word & 0xffffff00;
    }

    return word & 0xff;
}

void eread_uint8v(uint8_t* s, uint32_t n, uint32_t* flags)
{
    for (uint32_t i = 0; i < n; i++) {
        s[i] = eread_uint8(flags);
    }
}

uint16_t eread_uint16(uint32_t* flags)
{
    return HILO8(eread_uint8(flags), eread_uint8(flags));
}

uint32_t eread_uint32(uint32_t* flags)
{
    return HILO16(eread_uint16(flags), eread_uint16(flags));
}

void eread_mac_header(mac_header_t* mac_header, uint32_t* flags)
{
#if defined(DEBUG)
    uwrite_int8s("Reading MAC header.....\r\n");
#endif
    eread_uint8v(mac_header->destination, MAC_ADDR_LEN, flags);
    eread_uint8v(mac_header->source, MAC_ADDR_LEN, flags);
    mac_header->ethertype = eread_uint16(flags);
#if defined(DEBUG)
    uwrite_int8s("MAC Header\r\n");

    int8_t buffer[5];

    uwrite_int8s("Destination: ");
    for (uint32_t i = 0; i < MAC_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(mac_header->destination[i], buffer, 3));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Source: ");
    for (uint32_t i = 0; i < MAC_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(mac_header->source[i], buffer, 3));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Ethertype: ");
    uwrite_int8s(uint16_to_ascii_hex(mac_header->ethertype, buffer, 5));
    uwrite_int8s("\r\n");
#endif
}

static void eread_ipv4_header_body(ipv4_header_t* ipv4, uint32_t* flags)
{
#if defined(DEBUG)
    uwrite_int8s("Reading IPv4 header.....\r\n");
#endif
    uint16_t header_length = LO4(eread_uint8(flags)) << 2;

    eread_uint8(flags);

    uint16_t total_length = eread_uint16(flags);

    ipv4->length = total_length - header_length;

    eread_uint32(flags);

    ipv4->ttl = eread_uint8(flags);
    ipv4->protocol = eread_uint8(flags);

    eread_uint16(flags);

    eread_uint8v(ipv4->source, IPV4_ADDR_LEN, flags);
    eread_uint8v(ipv4->destination, IPV4_ADDR_LEN, flags);
#if defined(DEBUG)
    uwrite_int8s("IPv4 Header\r\n");

    int8_t buffer[5];
    uwrite_int8s("Length: ");
    uwrite_int8s(uint16_to_ascii_hex(ipv4->length, buffer, 5));
    uwrite_int8s("\r\n");

    uwrite_int8s("Protocol: ");
    uwrite_int8s(uint8_to_ascii_hex(ipv4->protocol, buffer, 5));
    uwrite_int8s("\r\n");

    uwrite_int8s("Source IP: ");
    for (uint32_t i = 0; i < IPV4_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(ipv4->source[i], buffer, 5));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Destination IP: ");
    for (uint32_t i = 0; i < IPV4_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(ipv4->source[i], buffer, 5));
    }
    uwrite_int8s("\r\n");
#endif
}

void eread_ipv4_header(ipv4_header_t* ipv4, uint32_t* flags)
{
    eread_mac_header(ipv4->mac_header, flags);
    eread_ipv4_header_body(ipv4, flags);
}

static void eread_arp_packet_body(arp_packet_t* arp, uint32_t* flags);

uint32_t eread_ipv4_header_arp(ipv4_header_t* ipv4, arp_packet_t* arp, uint32_t* flags)
{
    eread_mac_header(ipv4->mac_header, flags);

    uint32_t ret = 0;

    if (ipv4->mac_header->ethertype == 0x0806) {
        eread_arp_packet_body(arp, flags);
        ret |= ENET_ARP_PACKET;
    }
    if (ipv4->mac_header->ethertype == 0x0800) {
        eread_ipv4_header_body(ipv4, flags);
        ret |= ENET_IPV4_PACKET;
    }
    return ret;
}

static void eread_udp_header_body(udp_header_t* udp, uint32_t* flags)
{
#if defined(DEBUG)
    uwrite_int8s("Reading UDP header.....\r\n");
#endif
    udp->source = eread_uint16(flags);
    udp->destination = eread_uint16(flags);
    udp->length = eread_uint16(flags) - UDP_HEADER_LEN;
    eread_uint16(flags);
#if defined(DEBUG)
    uwrite_int8s("UDP Header\r\n");

    int8_t buffer[5];
    uwrite_int8s("Length: ");
    uwrite_int8s(uint16_to_ascii_hex(udp->length, buffer, 5));
    uwrite_int8s("\r\n");

    uwrite_int8s("Source port: ");
    uwrite_int8s(uint16_to_ascii_hex(udp->source, buffer, 5));
    uwrite_int8s("\r\n");

    uwrite_int8s("Destination port: ");
    uwrite_int8s(uint16_to_ascii_hex(udp->destination, buffer, 5));
    uwrite_int8s("\r\n");
#endif
}

void eread_udp_header(udp_header_t* udp, uint32_t* flags)
{
    eread_ipv4_header(udp->ipv4_header, flags);
    eread_udp_header_body(udp, flags);
}

uint32_t eread_udp_header_arp(udp_header_t* udp, arp_packet_t* arp, uint32_t* flags)
{
    uint32_t ret = eread_ipv4_header_arp(udp->ipv4_header, arp, flags);
    if (ret & ENET_IPV4_PACKET) {
        eread_udp_header_body(udp, flags);
    }
    return ret;
}

static void eread_arp_packet_body(arp_packet_t* arp, uint32_t* flags)
{
#if defined(DEBUG)
    uwrite_int8s("Reading ARP packet.....\r\n");
#endif
    arp->htype = eread_uint16(flags);
    arp->ptype = eread_uint16(flags);

    arp->hlen = eread_uint8(flags);
    arp->plen = eread_uint8(flags);

    arp->oper = eread_uint16(flags);

    eread_uint8v(arp->sha, MAC_ADDR_LEN, flags);
    eread_uint8v(arp->spa, IPV4_ADDR_LEN, flags);

    eread_uint8v(arp->tha, MAC_ADDR_LEN, flags);
    eread_uint8v(arp->tpa, IPV4_ADDR_LEN, flags);
#if defined(DEBUG)
    uwrite_int8s("ARP Packet\r\n");

    int8_t buffer[5];

    uwrite_int8s("Sender IP: ");
    for (uint32_t i = 0; i < IPV4_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(arp->spa[i], buffer, 5));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Sender MAC: ");
    for (uint32_t i = 0; i < MAC_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(arp->sha[i], buffer, 5));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Target IP: ");
    for (uint32_t i = 0; i < IPV4_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(arp->tpa[i], buffer, 5));
    }
    uwrite_int8s("\r\n");

    uwrite_int8s("Target MAC: ");
    for (uint32_t i = 0; i < MAC_ADDR_LEN; i++) {
        uwrite_int8s(uint8_to_ascii_hex(arp->tha[i], buffer, 5));
    }
    uwrite_int8s("\r\n");
#endif
}

void eread_arp_packet(arp_packet_t* arp, uint32_t* flags)
{
    eread_mac_header(arp->mac_header, flags);
    eread_arp_packet_body(arp, flags);
}

void ewrite_uint8(uint8_t x, uint32_t flags)
{
    while (!ETRAN_CTRL) ;
    ETRAN_DATA = x | flags;
}

void ewrite_uint8v(const uint8_t* v, uint32_t n, uint32_t flags)
{
    uint32_t i = 0, m = n;
    if (flags & ENET_SOF) {
        ewrite_uint8(v[0], ENET_SOF);
        i = 1;
    }
    if (flags & ENET_EOF) {
        m -= 1;
    }
    for ( ; i < m; i++) {
        ewrite_uint8(v[i], 0);
    }
    if (flags & ENET_EOF) {
        ewrite_uint8(v[m], ENET_EOF);
    }
}

void ewrite_uint16(uint16_t x, uint32_t flags)
{
    ewrite_uint8(HI8(x), flags &  ENET_SOF & ~ENET_EOF);
    ewrite_uint8(LO8(x), flags & ~ENET_SOF &  ENET_EOF);
}

void ewrite_uint32(uint32_t x, uint32_t flags)
{
    ewrite_uint16(HI16(x), flags &  ENET_SOF & ~ENET_EOF);
    ewrite_uint16(LO16(x), flags & ~ENET_SOF &  ENET_EOF);
}

void ewrite_mac_header(const mac_header_t* mac)
{
    ewrite_uint8v(mac->destination, MAC_ADDR_LEN, ENET_SOF);
    ewrite_uint8v(mac->source, MAC_ADDR_LEN, 0);
    ewrite_uint16(mac->ethertype, 0);
}

void ewrite_arp_packet(arp_packet_t* arp)
{
    ewrite_mac_header(arp->mac_header);

    ewrite_uint16(arp->htype, 0);
    ewrite_uint16(arp->ptype, 0);

    ewrite_uint8(arp->hlen, 0);
    ewrite_uint8(arp->plen, 0);

    ewrite_uint16(arp->oper, 0);

    ewrite_uint8v(arp->sha, MAC_ADDR_LEN, 0);
    ewrite_uint8v(arp->spa, IPV4_ADDR_LEN, 0);

    ewrite_uint8v(arp->tha, MAC_ADDR_LEN, 0);
    ewrite_uint8v(arp->tpa, IPV4_ADDR_LEN, ENET_EOF);
}

void ewrite_ipv4_header(const ipv4_header_t* ipv4)
{
    ewrite_mac_header(ipv4->mac_header);

    uint16_t checksum_parts[] =
    {
        0x4500,
        IPV4_HEADER_LEN + ipv4->length,
        0x4000,
        HILO8(ipv4->ttl, ipv4->protocol),
        HILO8(ipv4->source[0], ipv4->source[1]),
        HILO8(ipv4->source[2], ipv4->source[3]),
        HILO8(ipv4->destination[0], ipv4->destination[1]),
        HILO8(ipv4->destination[2], ipv4->destination[3])
    };  

    uint32_t prechecksum = 0;

    for(uint32_t i = 0; i < sizeof(checksum_parts) / sizeof(checksum_parts[0]); i++) {
        prechecksum += checksum_parts[i];
    }   

    uint16_t checksum = ~(((prechecksum >> 16) & 0xFFFF) + (prechecksum & 0xFFFF));

    ewrite_uint16(0x4500, 0); 
    ewrite_uint16(IPV4_HEADER_LEN + ipv4->length, 0); 
    ewrite_uint32(0x00004000, 0); 
    ewrite_uint8(ipv4->ttl, 0); 
    ewrite_uint8(ipv4->protocol, 0); 
    ewrite_uint16(checksum, 0); 
    ewrite_uint8v(ipv4->source, IPV4_ADDR_LEN, 0); 
    ewrite_uint8v(ipv4->destination, IPV4_ADDR_LEN, 0); 
}

void ewrite_udp_header(const udp_header_t* udp)
{
    ewrite_ipv4_header(udp->ipv4_header);

    ewrite_uint16(udp->source, 0);
    ewrite_uint16(udp->destination, 0);
    ewrite_uint16(UDP_HEADER_LEN + udp->length, 0);
    ewrite_uint16(0x0000, 0);
}
