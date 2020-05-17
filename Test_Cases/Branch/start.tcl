vsim -gui work.main
add wave sim:/main/INT
add wave sim:/main/input_port_data
add wave sim:/main/output_port_data
add wave sim:/main/instruction_address
add wave sim:/main/opcode
add wave -position end sim:/main/sp/sp_out
add wave -position end sim:/main/RF/regiTri
add wave -position end sim:/main/flags/q_flags
add wave -position end sim:/main/hazards/flush

force -freeze sim:/main/CLK 1 0, 0 {50 ns} -r 100
force -freeze sim:/main/RST 1 0
force -freeze sim:/main/INT 0 0
force -freeze sim:/main/input_port_data 32'h30 0
run 100
force -freeze sim:/main/RST 0
run 300
force -freeze sim:/main/input_port_data 32'h50 0
run 100
force -freeze sim:/main/input_port_data 32'h100 0
run 100
force -freeze sim:/main/input_port_data 32'h300 0
run 100
force -freeze sim:/main/input_port_data 32'hFFFFFFFF 0
run 400
force -freeze sim:/main/input_port_data 32'h200 0
run 2700
