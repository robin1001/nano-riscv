VXX = iverilog

nano_riscv_tb: clock_gen.v nano_riscv_tb.v ../rtl/nano_riscv.v
	$(VXX) -I ../rtl $^ -o $@
