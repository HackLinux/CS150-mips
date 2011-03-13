#define RECV_CTRL (*((volatile unsigned int*)0xffff0000) & 0x01)
#define RECV_DATA (*((volatile unsigned int*)0xffff0004) & 0xFF)

#define TRAN_CTRL (*((volatile unsigned int*)0xffff0008) & 0x01)
#define TRAN_DATA (*((volatile unsigned int*)0xffff000c))

int main(void)
{
    for ( ; ; )
    {
        while (!RECV_CTRL) ;
        char byte = RECV_DATA;
        while (!TRAN_CTRL) ;
        TRAN_DATA = byte;
    }

    return 0;
}
