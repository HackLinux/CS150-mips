.section    .start
.global     _start

_start:
    jal     main
    li      $sp, 0xFF
