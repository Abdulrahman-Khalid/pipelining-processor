vsim -gui work.main
add wave sim:/main/input_port_data
add wave sim:/main/output_port_data
add wave sim:/main/instruction_address
add wave sim:/main/opcode
add wave -position end sim:/main/RF/regiTri
add wave -position end sim:/main/flags/q_flags
add wave -position end sim:/main/hazards/flush
add wave -position end sim:/main/hazards/flush

force -freeze sim:/main/CLK 1 0, 0 {50 ns} -r 100
force -freeze sim:/main/RST 1 0
force -freeze sim:/main/INT 0 0
force -freeze sim:/main/input_port_data 32'h5 0
run 100
force -freeze sim:/main/RST 0
run 300
force -freeze sim:/main/input_port_data 32'h19 0
run 100
force -freeze sim:/main/input_port_data 32'hFFFD 0
run 100
force -freeze sim:/main/input_port_data 32'hF320 0
run 1300