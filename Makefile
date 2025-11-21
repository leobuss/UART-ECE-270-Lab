export PATH := /home/shay/a/ece270/bin:$(PATH)
export LD_LIBRARY_PATH := /home/shay/a/ece270/lib:$(LD_LIBRARY_PATH)

YOSYS=yosys
NEXTPNR=nextpnr-ice40
SHELL=bash

PROJ	= ECE-270-Exp-Lab-Clock-Project
PINMAP 	= pinmap.pcf
TCLPREF = addwave.gtkw
SRC	    = top.sv
ICE   	= ice40hx8k.sv
CHK 	= check.bin
DEM 	= demo.bin
UART	= uart/uart.v uart/uart_tx.v uart/uart_rx.v
FILES   = $(ICE) $(SRC) $(UART)
TRACE	= $(PROJ).vcd
BUILD   = ./build

DEVICE  = 8k
TIMEDEV = hx8k
FOOTPRINT = ct256

all: cram

#########################
# Flash to FPGA
$(BUILD)/$(PROJ).json : $(ICE) $(SRC) $(PINMAP) Makefile
	# lint with Verilator
	verilator --lint-only --top-module top $(SRC)
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	#$(YOSYS) -p "read_verilog -sv -noblackbox $(FILES); synth_ice40 -top ice40hx8k -json $(BUILD)/$(PROJ).json"
	$(YOSYS) -p "read_verilog -sv -noblackbox $(FILES); \
                hierarchy -top ice40hx8k; \
                synth_ice40 -top ice40hx8k; \
                opt_clean -purge; clean -purge; \
                write_json $(BUILD)/$(PROJ).json"

$(BUILD)/$(PROJ).asc : $(BUILD)/$(PROJ).json
	# Place and route using nextpnr
	$(NEXTPNR) --hx8k --package ct256 --pcf $(PINMAP) --asc $(BUILD)/$(PROJ).asc --json $(BUILD)/$(PROJ).json 2> >(sed -e 's/^.* 0 errors$$//' -e '/^Info:/d' -e '/^[ ]*$$/d' 1>&2)

$(BUILD)/$(PROJ).bin : $(BUILD)/$(PROJ).asc
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

#########################
# Verification Suite
VFLAGS = --build --cc --exe --trace-fst --Mdir build

verify_keysync: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	@echo ========================================
	@echo Compiling and verifying keysync...
	@rm -rf build
	verilator $(VFLAGS) --top-module keysync -CFLAGS -DKEYSYNC top.sv tb.cpp 1>/dev/null
	./build/Vkeysync

verify_clock_psc: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	@echo ========================================
	@echo Compiling and verifying clock_psc...
	@rm -rf build
	verilator $(VFLAGS) --top-module clock_psc -CFLAGS -DCLOCK_PSC top.sv tb.cpp 1>/dev/null
	./build/Vclock_psc

verify_prelab: verify_keysync verify_clock_psc
	@echo ========================================
	@echo To pull up the waveforms for the prelab modules in order to debug, run:
	@echo gtkwave gtkw/keysync.gtkw or gtkwave gtkw/clock_psc.gtkw
	
verify_step1: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	
	@echo ========================================
	@echo Compiling and verifying sequence_sr...
	@rm -rf build
	verilator $(VFLAGS) --top-module sequence_sr -CFLAGS -DSEQUENCE_SR top.sv tb.cpp 1>/dev/null
	./build/Vsequence_sr

	@echo ========================================
	@echo To pull up the waveforms for step 1 in order to debug, run:
	@echo gtkwave gtkw/sequence_sr.gtkw

verify_step2: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	
	@echo ========================================
	@echo Compiling and verifying fsm...
	@rm -rf build
	verilator $(VFLAGS) --top-module fsm -CFLAGS -DFSM top.sv tb.cpp 1>/dev/null
	./build/Vfsm

	@echo ========================================
	@echo To pull up the waveforms for step 2 in order to debug, run:
	@echo gtkwave gtkw/fsm.gtkw

verify_step3: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	
	@echo ========================================
	@echo Compiling and verifying display...
	@rm -rf build
	verilator $(VFLAGS) --top-module display -CFLAGS -DDISPLAY top.sv tb.cpp
	./build/Vdisplay

	@echo ========================================
	@echo To pull up the waveforms for step 3 in order to debug, run:
	@echo gtkwave gtkw/display.gtkw

verify_lab: top.sv tb.cpp
	verilator --lint-only -Wno-MULTITOP top.sv
	
	@echo ========================================
	@echo Compiling and verifying top...
	@rm -rf build
	verilator $(VFLAGS) --top-module top -CFLAGS -DTOPMOD top.sv tb.cpp 1>/dev/null
	./build/Vtop

	@echo ========================================
	@echo To pull up the waveforms in order to debug the lock, run:
	@echo gtkwave gtkw/top.gtkw

#########################
# ice40 Specific Targets
check: $(CHK)
	iceprog -S $(CHK)
	
demo:  $(DEM)
	iceprog -S $(DEM)

flash: $(BUILD)/$(PROJ).bin
	iceprog $(BUILD)/$(PROJ).bin

cram: $(BUILD)/$(PROJ).bin
	iceprog -S $(BUILD)/$(PROJ).bin

time: $(BUILD)/$(PROJ).asc
	icetime -p $(PINMAP) -P $(FOOTPRINT) -d $(TIMEDEV) $<

#########################
# Clean Up
clean:
	rm -rf build/ *.fst verilog.log
