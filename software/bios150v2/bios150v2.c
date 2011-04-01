#include "ascii.h"
#include "uart.h"
#include "enet.h"
#include "string.h"
#include "memory.h"

void get(const int8_t* filename, uint32_t address)
{
    int8_t tmp[9];
    uwrite_int8s(uint32_to_ascii_hex(address, tmp, 9));

    uint8_t dst_ip[] = {169, 254, 1, 1};

    uint8_t src_mac[] = {0xa0, 0x01, 0xa2, 0x03, 0xa4, 0x05};
    uint8_t src_ip[] = {169, 254, 1, 2};

    uint8_t broadcast_mac[] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
    uint8_t target_mac[] = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

    mac_header_t mac_arp_req_host =
    {
        .destination = broadcast_mac,
        .source = src_mac,
        .ethertype = 0x0806
    };
    arp_packet_t arp_req_host =
    {
        .mac_header = &mac_arp_req_host,

        .htype = 0x0001,
        .ptype = 0x0800,

        .hlen = 6,
        .plen = 4,

        .oper = 1,

        .sha = src_mac,
        .spa = src_ip,

        .tha = target_mac,
        .tpa = dst_ip
    };
    ewrite_arp_packet(&arp_req_host);

    uint8_t dst_mac_arp_rep_host[MAC_ADDR_LEN];
    uint8_t src_mac_arp_rep_host[MAC_ADDR_LEN];
    mac_header_t mac_arp_rep_host =
    {
        .destination = dst_mac_arp_rep_host,
        .source = src_mac_arp_rep_host
    };

    uint8_t sha_arp_rep_host[MAC_ADDR_LEN];
    uint8_t spa_arp_rep_host[IPV4_ADDR_LEN];
    uint8_t tha_arp_rep_host[MAC_ADDR_LEN];
    uint8_t tpa_arp_rep_host[IPV4_ADDR_LEN];
    arp_packet_t arp_rep_host =
    {
        .mac_header = &mac_arp_rep_host,

        .sha = sha_arp_rep_host,
        .spa = spa_arp_rep_host,

        .tha = tha_arp_rep_host,
        .tpa = tpa_arp_rep_host,
    };

    char buffer[5];

    uint32_t flags = 0;
    eread_arp_packet(&arp_rep_host, &flags);
    while (!(flags & ENET_EOF)) {
        eread_uint8(&flags);
    }

    mac_header_t rrq_mac_tftp = 
    {
        .destination = arp_rep_host.sha,
        .source = src_mac,
        .ethertype = 0x0800
    };
    ipv4_header_t rrq_tftp_ipv4 =
    {
        .mac_header = &rrq_mac_tftp,
        .length = 24,
        .ttl = 128,
        .protocol = 17,
        .source = src_ip,
        .destination = dst_ip
    };
    udp_header_t rrq_udp =
    {
        .ipv4_header = &rrq_tftp_ipv4,
        .source = 54075,
        .destination = 69,
        .length = 16
    };
    ewrite_udp_header(&rrq_udp);

    ewrite_uint16(0x0001, 0);
    ewrite_uint8v(filename, strlen(filename), 0);
    ewrite_uint8(0x00, 0);
    ewrite_uint8v("octet", 5, 0);
    ewrite_uint8(0x00, ENET_EOF);

    uint8_t dst_data_mac_tftp[MAC_ADDR_LEN];
    uint8_t src_data_mac_tftp[MAC_ADDR_LEN];
    mac_header_t data_mac_tftp =
    {
        .destination = dst_data_mac_tftp,
        .source = src_data_mac_tftp
    };

    uint8_t src_data_ipv4_tftp[IPV4_ADDR_LEN];
    uint8_t dst_data_ipv4_tftp[IPV4_ADDR_LEN];
    ipv4_header_t data_ipv4_tftp =
    {
        .mac_header = &data_mac_tftp,
        .source = src_data_ipv4_tftp,
        .destination = dst_data_ipv4_tftp
    };

    udp_header_t data_udp_tftp =
    {
        .ipv4_header = &data_ipv4_tftp
    };

    do {
        flags = 0;
        uint32_t packet_type = eread_udp_header_arp(&data_udp_tftp, &arp_rep_host, &flags);
        if (packet_type & ENET_ARP_PACKET) {

            mac_header_t resp_arp_mac =
            {
                .source = src_mac,
                .destination = arp_rep_host.mac_header->source,
                .ethertype = 0x0806
            };
            arp_packet_t resp_arp =
            {
                .mac_header = &resp_arp_mac,

                .htype = 0x0001,
                .ptype = 0x0800,

                .hlen = 6,
                .plen = 4,

                .oper = 2,

                .sha = src_mac,
                .spa = src_ip,

                .tha = arp_rep_host.mac_header->source,
                .tpa = dst_ip
            };
            ewrite_arp_packet(&resp_arp);
        }

        if (packet_type & ENET_IPV4_PACKET) {
            uint16_t opcode = eread_uint16(&flags);
            uint16_t block = eread_uint16(&flags);

            volatile uint8_t* mem = (volatile uint8_t*)(address);
            for (uint16_t i = 0; i < data_udp_tftp.length - 4; i++) {
                *mem++ = eread_uint8(&flags);
            }

            udp_header_t ack_udp_tftp =
            {
                .ipv4_header = &rrq_tftp_ipv4,
                .source = 54075,
                .destination = data_udp_tftp.source,
                .length = 4
            };
            ewrite_udp_header(&ack_udp_tftp);

            ewrite_uint16(0x0004, 0);
            ewrite_uint16(block, ENET_EOF);
        }
    } while(data_udp_tftp.length == 516);

    while (!(flags & ENET_EOF)) {
        eread_uint8(&flags);
    }
}

int8_t* read_token(int8_t* b, uint32_t n, int8_t* ds)
{
    for (uint32_t i = 0; i < n; i++) {
        int8_t ch = uread_int8();
        for (uint32_t j = 0; ds[j] != '\0'; j++) {
            if (ch == ds[j]) {
                b[i] = '\0';
                return b;
            }
        }
        b[i] = ch;
    }
}

#define BUFFER_LEN 64

typedef void (*entry_t)(void);

int main(void)
{
    for ( ; ; ) {
        uwrite_int8s("> ");

        int8_t buffer[BUFFER_LEN];
        memset(buffer, '\0', BUFFER_LEN);

        int8_t* input = read_token(buffer, BUFFER_LEN, " \x0d");

        if (strcmp(input, "get") == 0) {
            int8_t* file = read_token(buffer, BUFFER_LEN, " \x0d");

            int8_t addr_buffer[BUFFER_LEN];
            uint32_t address = ascii_hex_to_uint32(read_token(addr_buffer, BUFFER_LEN, " \x0d"));
            get(file, address);
        } else if (strcmp(input, "jal") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));

            entry_t start = (entry_t)(address);
            start();
        } else if (strcmp(input, "lw") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint32_t* p = (volatile uint32_t*)(address);

            int8_t buf[BUFFER_LEN];
            uwrite_int8s(uint32_to_ascii_hex(address, buf, BUFFER_LEN));
            uwrite_int8s(": ");
            uwrite_int8s(uint32_to_ascii_hex(*p, buf, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "lhu") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint16_t* p = (volatile uint16_t*)(address);

            int8_t buf[BUFFER_LEN];
            uwrite_int8s(uint32_to_ascii_hex(address, buf, BUFFER_LEN));
            uwrite_int8s(": ");
            uwrite_int8s(uint16_to_ascii_hex(*p, buf, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "lbu") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint8_t* p = (volatile uint8_t*)(address);

            int8_t buf[BUFFER_LEN];
            uwrite_int8s(uint32_to_ascii_hex(address, buf, BUFFER_LEN));
            uwrite_int8s(": ");
            uwrite_int8s(uint8_to_ascii_hex(*p, buf, BUFFER_LEN));
            uwrite_int8s("\r\n");
        } else if (strcmp(input, "sw") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint32_t* p = (volatile uint32_t*)(address);

            int8_t word_buf[BUFFER_LEN];
            uint32_t word = ascii_hex_to_uint32(read_token(word_buf, BUFFER_LEN, " \x0d"));
            *p = word;
        } else if (strcmp(input, "sh") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint16_t* p = (volatile uint16_t*)(address);

            int8_t word_buf[BUFFER_LEN];
            uint16_t half = ascii_hex_to_uint16(read_token(word_buf, BUFFER_LEN, " \x0d"));
            *p = half;
        } else if (strcmp(input, "sb") == 0) {
            uint32_t address = ascii_hex_to_uint32(read_token(buffer, BUFFER_LEN, " \x0d"));
            volatile uint8_t* p = (volatile uint8_t*)(address);

            int8_t word_buf[BUFFER_LEN];
            uint8_t byte = ascii_hex_to_uint8(read_token(word_buf, BUFFER_LEN, " \x0d"));
            *p = byte;
        }
    }

    return 0;
}
