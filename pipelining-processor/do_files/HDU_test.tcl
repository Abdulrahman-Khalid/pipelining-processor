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
run 50
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 1 }
force -freeze sim:/HDU/Rdst1_F_ID 2 0
run 50
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 1 }
force -freeze sim:/HDU/Rdst1_F_ID 1 0
run 50
set insert_bubble [examine -binary sim:/HDU/insert_bubble]
assert { $insert_bubble == 0 }
#--------------------------------- END LOAD use test cases ---------------------------------
#--------------------------------- Flush1 signal test cases --------------------------------
force -freeze sim:/HDU/swap_F_ID 1 0
force -freeze sim:/HDU/WB_CU 0 0
force -freeze sim:/HDU/Branch_MEM 1 0
force -freeze sim:/HDU/Rdst1_F_ID 7 0
force -freeze sim:/HDU/Rdst2_F_ID 5 0
force -freeze sim:/HDU/Rdst_MEM 7 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 1 }

force -freeze sim:/HDU/WB_CU 1 0
force -freeze sim:/HDU/swap_F_ID 0 0
force -freeze sim:/HDU/Rdst_MEM 5 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 1 }

force -freeze sim:/HDU/Rdst1_F_ID 5 0
force -freeze sim:/HDU/swap_F_ID 1 0
force -freeze sim:/HDU/Branch_MEM 0 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 0 }

force -freeze sim:/HDU/Branch_MEM 1 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 0 }

force -freeze sim:/HDU/Rdst_MEM 2 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 0 }

force -freeze sim:/HDU/swap_F_ID 0 0
force -freeze sim:/HDU/WB_CU 0 0
force -freeze sim:/HDU/Rdst_MEM 5 0
run 50
set flush1 [examine -binary sim:/HDU/flush1]
assert { $flush1 == 0 }
#--------------------------------- END Flush1 signal test cases ------------------------------
#--------------------------------- Flush2 signal test cases --------------------------------
force -freeze sim:/HDU/swap_ID_E 1 0
force -freeze sim:/HDU/WB_ID_E 0 0
force -freeze sim:/HDU/Branch_MEM 1 0
force -freeze sim:/HDU/Rdst1_ID_E 7 0
force -freeze sim:/HDU/Rdst2_ID_E 5 0
force -freeze sim:/HDU/Rdst_MEM 7 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 1 }

force -freeze sim:/HDU/WB_ID_E 1 0
force -freeze sim:/HDU/swap_ID_E 0 0
force -freeze sim:/HDU/Rdst_MEM 5 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 1 }

force -freeze sim:/HDU/Rdst1_ID_E 5 0
force -freeze sim:/HDU/swap_ID_E 1 0
force -freeze sim:/HDU/Branch_MEM 0 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 0 }

force -freeze sim:/HDU/Branch_MEM 1 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 0 }

force -freeze sim:/HDU/Rdst_MEM 2 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 0 }

force -freeze sim:/HDU/swap_ID_E 0 0
force -freeze sim:/HDU/WB_ID_E 0 0
force -freeze sim:/HDU/Rdst_MEM 5 0
run 50
set flush2 [examine -binary sim:/HDU/flush2]
assert { $flush2 == 0 }
#--------------------------------- END Flush2 signal test cases ------------------------------
#--------------------------------- Flush3 signal test cases --------------------------------
force -freeze sim:/HDU/load_E_MEM 1 0
force -freeze sim:/HDU/Branch_MEM 1 0
force -freeze sim:/HDU/WB_E_MEM 1 0
force -freeze sim:/HDU/Rdst_E_MEM 7 0
force -freeze sim:/HDU/Rdst_MEM 7 0
run 50
set flush3 [examine -binary sim:/HDU/flush3]
assert { $flush3 == 1 }

force -freeze sim:/HDU/Rdst_MEM 5 0
run 50
set flush3 [examine -binary sim:/HDU/flush3]
assert { $flush3 == 0 }

force -freeze sim:/HDU/Rdst_MEM 7 0
force -freeze sim:/HDU/WB_E_MEM 0 0
run 50
set flush3 [examine -binary sim:/HDU/flush3]
assert { $flush3 == 0 }
#--------------------------------- END Flush3 signal test cases ------------------------------
#--------------------------------- Flush test cases --------------------------------
force -freeze sim:/HDU/flush1 0 0
force -freeze sim:/HDU/flush2 0 0
force -freeze sim:/HDU/flush3 0 0
run 50
set flush [examine -binary sim:/HDU/flush]
assert { $flush == 0 }

force -freeze sim:/HDU/flush1 1 0
force -freeze sim:/HDU/flush2 0 0
force -freeze sim:/HDU/flush3 0 0
run 50
set flush [examine -binary sim:/HDU/flush]
assert { $flush == 1 }

force -freeze sim:/HDU/flush1 0 0
force -freeze sim:/HDU/flush2 1 0
force -freeze sim:/HDU/flush3 0 0
run 50
set flush [examine -binary sim:/HDU/flush]
assert { $flush == 1 }

force -freeze sim:/HDU/flush1 0 0
force -freeze sim:/HDU/flush2 0 0
force -freeze sim:/HDU/flush3 1 0
run 50
set flush [examine -binary sim:/HDU/flush]
assert { $flush == 1 }

force -freeze sim:/HDU/flush1 1 0
force -freeze sim:/HDU/flush2 1 0
force -freeze sim:/HDU/flush3 1 0
run 50
set flush [examine -binary sim:/HDU/flush]
assert { $flush == 1 }
#--------------------------------- END Flush test cases ------------------------------
#--------------------------------- Hazard_Detected test cases ------------------------
force -freeze sim:/HDU/flush 0 0
force -freeze sim:/HDU/insert_bubble 0 0
run 50
set hazard_detected [examine -binary sim:/HDU/hazard_detected]
assert { $hazard_detected == 0 }

force -freeze sim:/HDU/flush 1 0
force -freeze sim:/HDU/insert_bubble 0 0
run 50
set hazard_detected [examine -binary sim:/HDU/hazard_detected]
assert { $hazard_detected == 1 }

force -freeze sim:/HDU/flush 0 0
force -freeze sim:/HDU/insert_bubble 1 0
run 50
set hazard_detected [examine -binary sim:/HDU/hazard_detected]
assert { $hazard_detected == 1 }

force -freeze sim:/HDU/flush 1 0
force -freeze sim:/HDU/insert_bubble 1 0
run 50
set hazard_detected [examine -binary sim:/HDU/hazard_detected]
assert { $hazard_detected == 1 }
#--------------------------------- Hazard_Detected test cases -------------------------
