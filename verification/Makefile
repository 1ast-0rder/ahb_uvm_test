DUT_FILES = dut.f
TB_FILES =  tb.f
DUT_TOP = ahb_bus#modify here
TB_TOP = tb_${DUT_TOP}
seed ?= $(shell date +%N)

wave ?= off
dump_array ?= off
debug_cell ?= off
ifeq ($(wave),on)
	FSDB_OPTS = +define+FSDB
	WAVE_OPT = -ssf test.vf
ifeq ($(dump_array),on)
	FSDB_OPTS += +define+DUMP_MDA
endif
endif

test_cmd_num ?= 
ifeq ($(test_cmd_num),)
	MODE_OPTS += +define+TEST_CMD_NUM=31
else
	MODE_OPTS += +define+TEST_CMD_NUM=${test_cmd_num}
endif

#MODE_OPTS += +define+BHV

list_tc:
	@ls -F cases/  | grep -v "\." | grep -v "common" | sed 's/\///'

vcs_design:
	vlogan -kdb -full64 -v2005 +systemverilogext+sv -timescale=1ns/1ps ${MODE_OPTS} -f ${DUT_FILES}	|tee compile_design.log
	vcs -full64 -kdb -debug_acc+all -top ${DUT_TOP} |tee vcs_design.log

verdi_design:
	vericom -sv ${MODE_OPTS} -f ${DUT_FILES}
	verdi -lib work -top ${DUT_TOP} |tee verdi_design.log &

vcs_testbench:
	echo ${MODE_OPTS}
	cp cases/${tc}/${tc}.sv testcase.sv
	vlogan -kdb -full64 -v2005 +systemverilogext+sv -sverilog -timescale=1ns/1ps ${MODE_OPTS} -f ${DUT_FILES}	|tee compile_design.log
	vlogan -kdb -full64 -v2005 +systemverilogext+sv -ntb_opts uvm-1.1 -sverilog -timescale=1ns/1ps ${FSDB_OPTS} ${MODE_OPTS} +define+TB_TOP=${TB_TOP} -f ${TB_FILES} |tee compile_testbench.log
	vcs -full64 -kdb -lca -debug_access+all +error+10000 -error=noZMMCM $(VCS_HOME)/etc/uvm-1.1/dpi/uvm_dpi.cc -timescale=1ns/1ps ${VCS_OPTS} -top ${TB_TOP} |tee vcs_testbench.log

verdi_testbench:
	cp cases/${tc}/${tc}.sv testcase.sv
	vericom -sv ${MODE_OPTS} -f ${DUT_FILES}
	vericom -sv ${FSDB_OPTS} ${MODE_OPTS} +define+TB_TOP=${TB_TOP} -f ${TB_FILES}
	verdi -lib work -top ${TB_TOP} |tee verdi_testbench.log &

verdi:
	verdi -dbdir simv.daidir ${WAVE_OPT} -top ${TB_TOP} -ssf ./test.fsdb &

run:
	##./simv +UVM_TESTNAME=$(tc) |tee sim.log
	./simv +UVM_TESTNAME=$(tc) +ntb_random_seed=$(seed) |tee sim.log

clean:
	@rm -rf csrc DVEfiles simv simv.daidir ucli.key pd novas* verdiLog *.log *.vpd *.h verdi_config_file test.* *.fsdb testcase.sv sequence.sv build vhdlcomLog/ work.lib++/ 64/ vericomLog AN.DB
