VCOM_ARGS=-2008 -work work
VSIM_ARGS=-msgmode both

VHDL_FILES = \
	../src/core_pck.vhd\
	../src/pe_pck.vhd\
	../src/PE/fetch_unit_pck.vhd\
	../src/PE/fetch_unit.vhd\
	../src/PE/index_comp_unit.vhd\
	../src/PE/mult_unit.vhd\
	../src/PE/value_extract_unit.vhd\
	../src/PE/PE.vhd


TB_FILES = \
  ../tb/test_utils.vhd\
  ../tb/PE_tb.vhd

TIME_RESOLUTION = 1ps

TB = PE_tb
SIM_TIME = 10000 ns
WAVE = ./wave.do

compile:
	rm -f log
	vlib work | tee log
	for i in $(VHDL_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	for i in $(TB_FILES); do \
		vcom $(VCOM_ARGS) $$i | tee -a log;\
	done;
	@echo "--------------------------------------------------------------"
	@echo "--              Error and Warning Summary                   --"
	@echo "--------------------------------------------------------------"
	@cat log | grep 'Warning\|Error'

compile_post:
	vlib work | tee log
	vcom $(VCOM_ARGS) $(POST_SDO) | tee -a log;

list_sources:
	@for i in $(VHDL_FILES); do \
		echo $$i;\
	done;

sim:
	vsim -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); do $(WAVE); run $(SIM_TIME)"

sim_quit:
	vsim -c -do "vsim $(TB) -t $(TIME_RESOLUTION) $(VSIM_ARGS); run $(SIM_TIME); q" > /dev/null
	grep "failed" ./testdata/output.txt || true

clean:
	rm -f transcript
	rm -f vsim.wlf
	rm -f log
	rm -fr work

.PHONY: s
s: sim

.PHONY: sq
sq: sim_quit
