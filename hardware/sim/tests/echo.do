start testbench
file copy -force ../../../software/echo/echo.mif blk_mem_gen_v4_3.mif
add wave testbench/*
add wave testbench/dummy/uatransmit/*
add wave testbench/dummy/uareceive/*
add wave testbench/DUT/*
add wave testbench/DUT/uart/*
add wave testbench/DUT/uart/uatransmit/*
add wave testbench/DUT/uart/uareceive/*
add wave testbench/DUT/imem/*
add wave testbench/DUT/dmem/*
add wave testbench/DUT/mmap/*
add wave testbench/DUT/proc/ctrl/*
add wave testbench/DUT/proc/dpath/*
add wave testbench/DUT/proc/dpath/regfile/*
add wave testbench/DUT/proc/dpath/alu/*
run 1000us
