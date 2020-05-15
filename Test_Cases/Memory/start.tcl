vsim -gui work.main
add wave sim:/main/instruction_address
add wave -position 1 sim:/main/HDU_F_ID_Singals/*
add wave -position end sim:/main/hazards/*
force -freeze sim:/main/CLK 1 0, 0 {50 ns} -r 100
force -freeze sim:/main/RST 1 0
force -freeze sim:/main/INT 0 0
force -freeze sim:/main/input_port_data 1010 0
run 
force -freeze sim:/main/RST 0
run 6000