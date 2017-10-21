.PHONY: all test clean prog run

all: grom.bin

test: grom.out
	vvp grom.out

grom.bin: grom_top.v hex_to_7seg.v grom_computer.v ram_memory.v grom_cpu.v alu.v Go_Board_Constraints.pcf 
	yosys -q -p "synth_ice40 -abc2 -top grom_top -blif grom.blif" hex_to_7seg.v grom_computer.v ram_memory.v alu.v grom_cpu.v grom_top.v
	arachne-pnr -d 1k -P vq100 -p Go_Board_Constraints.pcf grom.blif -o grom.txt
	icepack grom.txt grom.bin
	icetime -d hx1k -P vq100 grom.txt

grom.out: test.v ram_memory.v alu.v grom_cpu.v grom_computer.v 
	iverilog -D DISASSEMBLY -o grom.out test.v ram_memory.v alu.v grom_cpu.v grom_computer.v

prog: grom.bin
	iceprog grom.bin

clean:
	$(RM) -f grom.blif grom.txt grom.bin grom.out rotor.out abc.history grom.vcd
	$(RM) -f -r obj_dir

run: obj_dir/Vgrom_computer
	obj_dir/Vgrom_computer

obj_dir/Vgrom_computer: grom8.vlt grom_computer.v ram_memory.v grom_cpu.v alu.v main.cpp
	verilator_bin -Wall --top-module grom_computer --cc grom8.vlt grom_computer.v ram_memory.v grom_cpu.v alu.v --exe main.cpp
	make -C obj_dir -j -f Vgrom_computer.mk Vgrom_computer VERILATOR_ROOT=C:/msys64/opt/share/verilator CXXFLAGS=-Wno-attributes
