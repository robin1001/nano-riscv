VXX = iverilog
if: clock_gen.v if_tb.v ../rtl/if.v
	$(VXX) $^ -o $@

nano: clock_gen.v nano_riscv_tb.v ../rtl/nano_riscv.v
	$(VXX) -I ../rtl $^ -o $@
