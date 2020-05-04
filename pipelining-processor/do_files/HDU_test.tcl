proc assert condition {
if {![uplevel 1 expr $condition]} {
    return -code error "assertion failed: $condition"
}
}

vsim -gui alu
add wave -position insertpoint sim:/alu/*

# force -freeze sim:/alu/CPU_Bus 8 0
# force -freeze sim:/alu/Enable_Receiving_IO 1 0
# force -freeze sim:/alu/Done_Row 1 0

# force -freeze sim:/alu/Done_Row 0 0
# force -freeze sim:/alu/CPU_Bus 02020202 0
# run 100
# force -freeze sim:/alu/CPU_Bus 0a0a0a0a 0
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