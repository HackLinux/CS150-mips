start testbench
file copy -force ../../../software/testbench/blk_mem_gen_v4_3.mif blk_mem_gen_v4_3.mif
file copy -force ../../../software/testbench/instr_blk_ram.mif instr_blk_ram.mif
add wave testbench/DUT/*
add wave testbench/DUT/imem/*
add wave testbench/DUT/dmem/*
add wave testbench/DUT/proc/ctrl/*
add wave testbench/DUT/proc/ctrl/mnd/*
add wave testbench/DUT/proc/dpath/*
add wave testbench/DUT/proc/dpath/regfile/*
add wave testbench/DUT/proc/dpath/alu/*
run 10us
