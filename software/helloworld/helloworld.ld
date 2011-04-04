SECTIONS
{
    . = 0x0;
    .text : {
        * (.start);
        * (.text);
    }
}
