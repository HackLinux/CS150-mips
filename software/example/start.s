.section    .start
.global     _start

_start:
    li      $sp, 0x100
    jal     main
