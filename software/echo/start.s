.section    .start
.global     _start

_start:
    li      $sp, 0xFF
    jal     main
