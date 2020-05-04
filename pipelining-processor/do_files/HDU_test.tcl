proc assert condition {
if {![uplevel 1 expr $condition]} {
    return -code error "assertion failed: $condition"
}
}
# WB_CU, WB_ID_E, WB_E_MEM, swap_F_ID, swap_ID_E, load_ID_E, load_E_MEM, Branch_MEM: in std_logic;
# Rsrc1_F_ID, Rsrc2_F_ID, Rdst1_F_ID, Rdst2_F_ID, Rdst1_ID_E, Rdst2_ID_E, Rdst_E_MEM, Rdst_MEM: in std_logic_vector(2 downto 0);

vsim -gui HDU
add wave -position insertpoint sim:/HDU/*
#--------------------------------- LOAD use test cases -------------------------------------
force -freeze sim:/HDU/load_ID_E 1 0
force -freeze sim:/HDU/Rsrc1_F_ID 3 0
force -freeze sim:/HDU/Rsrc2_F_ID 2 0
force -freeze sim:/HDU/Rdst1_F_ID 3 0
run 100
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 1 }
force -freeze sim:/HDU/Rdst1_F_ID 2 0
run 100
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 1 }
force -freeze sim:/HDU/Rdst1_F_ID 1 0
run 100
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 0 }
#--------------------------------- END LOAD use test cases ---------------------------------

# force -freeze sim:/HDU/Done_Row 0 0
# force -freeze sim:/HDU/CPU_Bus 02020202 0
# run 100
# force -freeze sim:/HDU/CPU_Bus 0a0a0a0a 0
# run 1200
# set decompressed [examine -binary sim:/IO_Receive/Memory_Data_Bus]
# set binary [string range $decompressed 4 67]
# # test case 1
# set expected 0011001100000000001111111111000000000011111111110000000000111111‬
# set expected [string range $expected 0 63]
# assert { $binary == $expected }
# run 900
# # test case 2
# set decompressed [examine -binary sim:/IO_Receive/Memory_Data_Bus]
# set binary [string range $decompressed 4 67]
# set expected 0000000000111111111100000000001111111111000000000011111111110000
# set expected [string range $expected 0 63]
# assert { $binary == $expected }
# # test case 3
# set decompressed [examine -binary sim:/IO_Receive/Memory_Data_Bus]
# set binary [string range $decompressed 4 67]
# set expected 0000000000111111111100000000001111111111000000000011111111110000
# set expected [string range $expected 0 63]
# assert { $binary == $expected }
# run 600
# # test case 4
# set decompressed [examine -binary sim:/IO_Receive/Memory_Data_Bus]
# set binary [string range $decompressed 4 67]
# set expected 0000001111111111000000000011111111110000000000111111111100000000
# set expected [string range $expected 0 63]
# assert { $binary == $expected }