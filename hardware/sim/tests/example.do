start testbench
file copy -force ../../../software/example/example.mif blk_mem_gen_v4_3.mif
add wave testbench/DUT/*
add wave testbench/DUT/imem/*
add wave testbench/DUT/dmem/*
add wave testbench/DUT/proc/ctrl/*
add wave testbench/DUT/proc/dpath/*
add wave testbench/DUT/proc/dpath/regfile/*
add wave testbench/DUT/proc/dpath/alu/*
run 10us
