library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.constants.all;
-- main entity of the processor
ENTITY main IS
PORT(	
	CLK,RST,INT : IN std_logic;
	input_port_data: IN std_logic_vector(31 downto 0)
);
END main;

-- =====================================================================================
-- MAIN ARCHITECTURE ===================================================================
-- ===================================================================================== 

ARCHITECTURE a_main OF main IS
-- =====================================================================================
-- COMPONENTS USED =====================================================================
-- =====================================================================================  
-- =====================================================================================
-- SIGNALS USED ========================================================================
-- =====================================================================================
signal  instruction_address, incremented_pc, address_loaded_from_memory,
	address_to_pc, write_port_data1,write_port_data2,
	read_port_data1,read_port_data2,read_port_data3,temp2_dataout,
	output_port_data, alu_output, temp_pc_data :std_logic_vector(31 downto 0);
signal 	shift_data: std_logic_vector(31 downto 0):=(OTHERS=>'0');
signal 	effective_address: std_logic_vector(31 downto 0):=(OTHERS=>'0');
signal	immediate_data: std_logic_vector(31 downto 0):=(OTHERS=>'0');
---------------------------------------------------------------------------------------
signal ram_read,ram_write,rom_read :std_logic;
signal ram_address : std_logic_vector(RAM_ADDRESS_WIDTH-1 DOWNTO 0);
signal rom_address :  std_logic_vector(ROM_ADDRESS_WIDTH - 1 DOWNTO 0);
signal ram_data_in,ram_data_out : std_logic_vector( 2*WORD_SIZE - 1 DOWNTO 0);
signal rom_data_out : std_logic_vector(WORD_SIZE - 1 DOWNTO 0);
---------------------------------------------------------------------------------------
signal sp_out,m_mux1_out,m_mux2_out : std_logic_vector(2*WORD_SIZE-1 DOWNTO 0);
signal m_sel,push_pop_sp_in,enable_sp_in,read_ram_in,write_ram_in,enable_ram_in,flag_enable_final : std_logic;
signal flag_memory_in,flag_temp_in,flag_data,alu_to_flag,flag_jz_data: std_logic_vector(flagsCount-1 downto 0);
---------------------------------------------------------------------------------------
signal  jump_enable, not_taken_address_enable,jz_opcode,call_opcode,jmp_opcode, 
		connect_memory_pc, stall, address_loaded_from_memory_enable,flag_enable, jz_FD_opcode, 
		flush,branch, flush_FD, disable_fetch_buffer, enable_state_memory,
		second_time_fetch_flush,FD_Flush,flag_enable_jz,state_memory_enable,
---------------------------------------------------------------------------------------
--interrupt and return one bit buffers output signals
	int_bit_out,int_push_bit_out,rbit_out,
	ret_opcode,rti_opcode,rti_or_ret,
	clr_int_EM,clr_rbit_EM,
	int_push_flags_wb,rti_pop_flags_wb,
---------------------------------------------------------------------------------------
--CONTOL UNIT OUTPUT SIGNALS
	cu_rst,		--Resets control unit
	one_src, 	--One source signal
	input_port, 	--Input port used signal
	enable_temp2, 	--Enable temp2 signal
--Execution Stage mux input
	cu_s0,		--Selector for the mux  S0
	cu_s1,		--Selector for the mux  S1
--memory ops
	enable_mem,	--Enables ROM Memory module
	read_write,	--1 for write, 0 for read
	enable_stack,	--Enables stack
 	push_pop,	--1 for push, 0 for pop
	mem_to_pc,	--Connects memory output to pc input
	clr_rbit,	--Clears rbit buffer
	clr_int,	--Clears interrupt buffer
--write back ops
	write_back,	--Writes back to register file
	swap,		--Swap operation
	rti_pop_flags, 	--Pops flags due to rti
	int_push_flags, --Pushs flags due to int
	output_port,	--Output port used signal
	load		--Load signal used with LDD
	: std_logic;
signal alu_operation: std_logic_vector(3 DOWNTO 0); -- alu operation used
---------------------------------------------------------------------------------------

signal output_state: std_logic_vector(1 downto 0);
signal write_port_address1,write_port_address2,read_port_address1,read_port_address2,read_port_address3 : std_logic_vector(2 DOWNTO 0);
signal opcode,instr_opcode: std_logic_vector(4 downto 0);

---------------------------------------------------------------------------------------
--FETCH DECODE BUFFER SIGNALS

SIGNAL FD_Enable : std_logic;
SIGNAL FD_d_instruction, FD_q_instruction : std_logic_vector(15 DOWNTO 0);
SIGNAL FD_d_not_taken_address, FD_q_not_taken_address : std_logic_vector(31 DOWNTO 0);
SIGNAL FD_d_predicted_state, FD_q_predicted_state : std_logic_vector(1 DOWNTO 0);
SIGNAL FD_d_state_address, FD_q_state_address : std_logic_vector(7 DOWNTO 0);
----------------------------------------------------------------------------------------
--DECODE EXCUTE BUFFER SIGNALS

SIGNAL DE_d_WB_signals, DE_q_WB_signals : std_logic_vector(4 DOWNTO 0);
SIGNAL DE_d_excute_signals, DE_q_excute_signals : std_logic_vector(8 DOWNTO 0);
SIGNAL DE_d_memory_signals, DE_q_memory_signals : std_logic_vector(7 DOWNTO 0); 
SIGNAL DE_d_data1, DE_q_data1 : std_logic_vector(31 DOWNTO 0);
SIGNAL DE_d_data2, DE_q_data2 : std_logic_vector(31 DOWNTO 0);
SIGNAL DE_d_Rsrc1, DE_q_Rsrc1 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rsrc2, DE_q_Rsrc2 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rdst1, DE_q_Rdst1 : std_logic_vector(2 DOWNTO 0);
SIGNAL DE_d_Rdst2, DE_q_Rdst2 : std_logic_vector(2 DOWNTO 0);
----------------------------------------------------------------------------------------
--EXECUTE MEMORY BUFFER SIGNALS
SIGNAL EM_q_WB_signals : std_logic_vector(4 DOWNTO 0);
SIGNAL EM_q_memory_signals : std_logic_vector(7 DOWNTO 0); 
SIGNAL EM_d_data1, EM_q_data1 : std_logic_vector(31 DOWNTO 0);
SIGNAL EM_d_data2, EM_q_data2 : std_logic_vector(31 DOWNTO 0);
SIGNAL EM_d_Rdst1, EM_q_Rdst1 : std_logic_vector(2 DOWNTO 0);
SIGNAL EM_d_Rdst2, EM_q_Rdst2 : std_logic_vector(2 DOWNTO 0);
----------------------------------------------------------------------------------------
--MEMORY WRITEBACK BUFFER SIGNALS
SIGNAL MW_d_WB_signals, MW_q_WB_signals : std_logic_vector(4 DOWNTO 0);
SIGNAL MW_d_data1, MW_q_data1 : std_logic_vector(31 DOWNTO 0);
SIGNAL MW_d_data2, MW_q_data2 : std_logic_vector(31 DOWNTO 0);
SIGNAL MW_d_Rdst1, MW_q_Rdst1 : std_logic_vector(2 DOWNTO 0);
SIGNAL MW_d_Rdst2, MW_q_Rdst2 : std_logic_vector(2 DOWNTO 0);
----------------------------------------------------------------------------------------
--FORWARDING UNIT SIGNALS

SIGNAL ALU_F_Rdst1 : std_logic;
SIGNAL ALU_F_Rdst2 : std_logic;
SIGNAL MEM_F_Rdst1 : std_logic;
SIGNAL MEM_F_Rdst2 : std_logic;

--OUTPUT SIGNALS FOR FORWARDING FROM ALU TO ALU
SIGNAL ALU_ALU_Rdst1_Rsrc1 : std_logic;
SIGNAL ALU_ALU_Rdst1_Rsrc2 : std_logic;
SIGNAL ALU_ALU_Rdst2_Rsrc1 : std_logic;
SIGNAL ALU_ALU_Rdst2_Rsrc2 : std_logic;

--OUTPUT SIGNALS FOR FORWARDING FROM MEMORY TO ALU
SIGNAL MEM_ALU_Rdst1_Rsrc1 : std_logic;
SIGNAL MEM_ALU_Rdst1_Rsrc2 : std_logic;
SIGNAL MEM_ALU_Rdst2_Rsrc1 : std_logic;
SIGNAL MEM_ALU_Rdst2_Rsrc2 : std_logic;

SIGNAL ALU_in1, ALU_in2, FSEL_out : std_logic_vector(31 DOWNTO 0);
-- =====================================================================================
-- BEGINING of the progrom  ============================================================
-- =====================================================================================
BEGIN

-- =====================================================================================
-- General Components ==================================================================
-- =====================================================================================

-- 3 one bit buffers  ==================================================================
rti_opcode<= (instr_opcode(4)and (not instr_opcode(3)) and  instr_opcode(2) and instr_opcode(1) and (not instr_opcode(0)) );
ret_opcode<= (instr_opcode(4)and (not instr_opcode(3)) and  instr_opcode(2) and (not instr_opcode(1)) and instr_opcode(0) );
rti_or_ret<= ret_opcode or rti_opcode;
----------------------------------------------------------------------------------------
INT_BIT: entity work.one_bit_buffer
PORT MAP(	CLK,RST,INT,clr_int_EM,int_bit_out);
RBIT: entity work.one_bit_buffer
PORT MAP(	CLK,RST,rti_or_ret, clr_rbit_EM,rbit_out);
--TODO change int_push_flags to take from WB stage
INT_PUSH_BIT: entity work.one_bit_buffer 
PORT MAP(	CLK,RST,MW_q_WB_signals(0),int_push_bit_out,int_push_bit_out);

-- Hazard detection unit
branch <= jz_opcode or jmp_opcode or call_opcode;
hazards: entity work.HDU 
    generic map(3)
    -- Branch_MEM is '1' if jmp or jz or call from memory
    port map(write_back, DE_q_WB_signals(4), EM_q_WB_signals(4), swap, DE_q_WB_signals(3), DE_q_memory_signals(7),
	 EM_q_memory_signals(7), branch, FD_q_instruction(5 downto 3), FD_q_instruction(8 downto 6),
	 FD_q_instruction(2 downto 0),FD_q_instruction(8 downto 6), DE_q_Rdst1, DE_q_Rdst2, EM_q_Rdst1, MW_q_Rdst1, rom_data_out(2 downto 0), 
	 flush);
	 -- load_MEM_WB, Rdst_MEM_WB
	
stall <=  int_bit_out or rbit_out or disable_fetch_buffer or flush or DE_q_excute_signals(0);

FU: entity work.forwarding_unit 
PORT MAP( 
	EM_q_Rdst1, EM_q_Rdst2, EM_q_WB_signals(4), EM_q_WB_signals(3), EM_q_memory_signals(6),
	MW_q_Rdst1, MW_q_Rdst2, MW_q_WB_signals(4), MW_q_WB_signals(3),
	rom_data_out,
	DE_q_Rsrc1,
	DE_q_Rsrc2,
	DE_q_WB_signals(4),
	DE_q_WB_signals(3),
	DE_q_excute_signals(2),
	DE_q_excute_signals(1),
	DE_q_excute_signals(3),

	ALU_F_Rdst1,
	ALU_F_Rdst2,
	MEM_F_Rdst1,
	MEM_F_Rdst2,

	ALU_ALU_Rdst1_Rsrc1,
	ALU_ALU_Rdst1_Rsrc2,
	ALU_ALU_Rdst2_Rsrc1,
	ALU_ALU_Rdst2_Rsrc2,

	MEM_ALU_Rdst1_Rsrc1,
	MEM_ALU_Rdst1_Rsrc2,
	MEM_ALU_Rdst2_Rsrc1,
	MEM_ALU_Rdst2_Rsrc2
);

-- =====================================================================================
-- FETCH STAGE  ========================================================================
-- =====================================================================================
-- instr_opcode is the opcode coming from instruction memory directly
jz_opcode<= (instr_opcode(4)and (not instr_opcode(3)) and (not instr_opcode(2)) and instr_opcode(1) and (not instr_opcode(0)) );
jmp_opcode<= (instr_opcode(4)and (not instr_opcode(3)) and (not instr_opcode(2)) and instr_opcode(1) and  instr_opcode(0) );
call_opcode<= (instr_opcode(4)and (not instr_opcode(3)) and instr_opcode(2)and (not instr_opcode(1)) and (not instr_opcode(0)));
jump_enable <= ( 
jmp_opcode or call_opcode or (
jz_opcode and FD_d_predicted_state(1))    );
rom_read<='1';
rom_address<=instruction_address(10 downto 0);
read_port_address3 <= rom_data_out(2 downto 0);

-- ROM  ===============================
ROM1: entity work.ROM PORT MAP(rom_read, rom_address,rom_data_out);

-- ROM connections ====================
mux_rom_fd_int: entity work.mux_2X1
GENERIC MAP(16)
PORT MAP(rom_data_out,"1011100000000000",FD_d_instruction,int_bit_out);
instr_opcode<=FD_d_instruction(15 downto 11);

-- PC ADDRESS HANDLING  ===============
FSEL: entity work.fetch_Rdst_selector
PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2,read_port_data3 ,ALU_F_Rdst1, ALU_F_Rdst2, MEM_F_Rdst1,
	MEM_F_Rdst2, FSEL_out
);
-- Used to choose the appropiate address of next instruction depend on certain enables.
PC_ADDRESS_CIRCUIT: entity work.pc_circuit PORT MAP( 
	instruction_address, incremented_pc, FD_q_not_taken_address,
	address_loaded_from_memory,FSEL_out ,
	stall, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable,
	address_to_pc, FD_d_not_taken_address );
address_loaded_from_memory_enable <= (connect_memory_pc or RST);
-- PC register used to get the instruction address to fetch it
PC : entity work.pc_register PORT MAP(CLK,RST,address_to_pc,instruction_address,'1');
-- Enabled when call instruction is fetched to push the next pc value
TEMP_PC : entity work.pc_register PORT MAP(CLK,RST,incremented_pc,temp_pc_data,call_opcode);
-- IncrementPC by one
INC: entity work.incrementor PORT MAP(CLK,RST,instruction_address,incremented_pc,'1');

--FETCH DECODE BUFFER==============================
FD_d_state_address <= instruction_address(7 downto 0);
flush_FD <= flush or clr_int_EM or DE_q_excute_signals(0);
-- fetch buffer enable andflush signal
FD_Enable <= not disable_fetch_buffer;
FD_Flush <= flush_FD or second_time_fetch_flush or not_taken_address_enable;
fdbuff : entity work.FD_buffer PORT MAP(CLK, RST, FD_Enable, FD_Flush, FD_d_instruction, FD_q_instruction,
 	FD_d_not_taken_address, FD_q_not_taken_address, FD_d_predicted_state, FD_q_predicted_state,
	FD_d_state_address, FD_q_state_address);

--========================================================================================
--DECODE STAGE ===========================================================================
--========================================================================================
opcode <= FD_q_instruction(15 downto 11);
jz_FD_opcode <= (opcode(4)and (not opcode(3)) and (not opcode(2)) and opcode(1) and (not opcode(0)) );
read_port_address1 <= FD_q_instruction(5 downto 3);
read_port_address2 <= FD_q_instruction(8 downto 6);
DE_d_data1 <= read_port_data1;
DE_d_Rdst1 <= FD_q_instruction(2 downto 0);
DE_d_Rdst2 <= FD_q_instruction(8 downto 6);
DE_d_Rsrc1 <= FD_q_instruction(5 downto 3);
DE_d_Rsrc2 <= FD_q_instruction(8 downto 6);
DE_d_WB_signals <= write_back&swap&output_port&rti_pop_flags&int_push_flags;
DE_d_memory_signals <= load&enable_mem&read_write&enable_stack&push_pop&mem_to_pc&clr_rbit&clr_int;
DE_d_excute_signals <= alu_operation&input_port&one_src&cu_s1&cu_s0&enable_temp2;
-- Structural hazard, disable fetch buffer when finding (alu operation followed by jz instruction)
disable_fetch_buffer <= (flag_enable and jz_FD_opcode); 
flag_enable_jz <= (DE_q_excute_signals(8) and DE_q_excute_signals(7) and DE_q_excute_signals(6) and DE_q_excute_signals(5));

shift_data <= std_logic_vector("0000000000000000"&"00000000000"&FD_q_instruction(10 downto 6));
effective_address <= std_logic_vector("000000000000"&FD_q_instruction(9 downto 6)&rom_data_out);
immediate_data <= std_logic_vector("0000000000000000"&rom_data_out);
-- DYNAMIC PREDICTION FOR JUMP INSTRUCTION =======================

JCC: entity work.jump_check_circuit PORT MAP (CLK,RST,jz_FD_opcode,FD_q_predicted_state, flag_data(zFlag), output_state,
		not_taken_address_enable,disable_fetch_buffer);

state_memory_enable <= jz_FD_opcode and (not disable_fetch_buffer);
SM: entity work.state_memory PORT MAP(CLK ,state_memory_enable,FD_q_state_address,FD_d_state_address ,
		output_state , FD_d_predicted_state);

-- Control Unit  ===================================
cu_rst <= DE_q_excute_signals(0) or RST or clr_int_EM or disable_fetch_buffer;
CU: entity work.control_unit
port MAP (      cu_rst, opcode,
		alu_operation,
		one_src, input_port,
		enable_temp2,
		cu_s0,cu_s1,			--alu ops
		enable_mem, read_write,		--memory ops
		enable_stack, push_pop,
		mem_to_pc, clr_rbit,
		clr_int,
		write_back, swap,		--write back ops
		rti_pop_flags, int_push_flags, 
		output_port,load);

-- Register Files  ==================================
RF: entity work.register_files 
PORT MAP(	CLK,RST,MW_q_WB_signals(4),MW_q_WB_signals(3),write_port_data1,write_port_data2,
	    	write_port_address1,write_port_address2, 
	    	read_port_data1,read_port_data2,read_port_data3,
	    	read_port_address1,read_port_address2,read_port_address3);

-- Select data 2 input to the buffer
select_data2: entity work.data2_selector 
 	port map(
     		read_port_data2,temp_pc_data,
		shift_data,effective_address
		,immediate_data,
     		opcode,DE_d_data2,second_time_fetch_flush);

--DECODE EXECUTE BUFFER ==============================
debuff : entity work.DE_buffer PORT MAP(CLK, RST,DE_d_WB_signals,DE_q_WB_signals,
	DE_d_memory_signals , DE_q_memory_signals,
	DE_d_excute_signals , DE_q_excute_signals, DE_d_data1, DE_q_data1, DE_d_data2, DE_q_data2,
	DE_d_Rsrc1, DE_q_Rsrc1, DE_d_Rsrc2, DE_q_Rsrc2, DE_d_Rdst1, DE_q_Rdst1, DE_d_Rdst2, DE_q_Rdst2);


--===========================================================================================
--EXECUTE STAGE =============================================================================
--===========================================================================================
EM_d_Rdst1 <= DE_q_Rdst1;
EM_d_Rdst2 <= DE_q_Rdst2;
-- First operand selectors
ALUSEL1: entity work.ALU_in1_selector 
	PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2, DE_q_data1, ALU_ALU_Rdst1_Rsrc1, ALU_ALU_Rdst2_Rsrc1,
		MEM_ALU_Rdst1_Rsrc1,MEM_ALU_Rdst2_Rsrc1, ALU_in1);

-- Second operand selector
ALUSEL2: entity work.ALU_in2_selector 
	PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2, DE_q_data2, ALU_ALU_Rdst1_Rsrc2, ALU_ALU_Rdst2_Rsrc2,
		MEM_ALU_Rdst1_Rsrc2,MEM_ALU_Rdst2_Rsrc2, ALU_in2);
ALU1: entity work.ALU
    	port map(
		DE_q_excute_signals(8 downto 5),
        	ALU_in1, ALU_in2,
		alu_output,
	        flag_data,alu_to_flag);

data1_to_EMB_mux_4X1: entity work.mux_4X1 
 	port map(
     		alu_output,ALU_in1,input_port_data, ALU_in2, 
     		DE_q_excute_signals(1),DE_q_excute_signals(2), -- Mux selectors 
     		EM_d_data1);

data2_to_EMB_mux: entity work.mux_2X1
	GENERIC MAP(32)
	PORT MAP(ALU_in2,ALU_in1,EM_d_data2,DE_q_WB_signals(3));

--EXECUTE MEMORY BUFFER =============================
embuff : entity work.EM_buffer
PORT MAP(
	Clk,RST,DE_q_WB_signals, EM_q_WB_signals,DE_q_memory_signals,EM_q_memory_signals,
	EM_d_data1,EM_q_data1,EM_d_data2,EM_q_data2,EM_d_Rdst1,EM_q_Rdst1,EM_d_Rdst2,EM_q_Rdst2
	);
--===================================================
-- Memory Signals Order
-- clr_int 0
-- clr_rbit 1
-- mem_to_pc 2
-- push_pop 3
-- enable_stack 4
-- read_write 5
-- enable_mem 6

--========================================================================================
--MEMORY STAGE ===========================================================================
--========================================================================================
write_ram_in <= (EM_q_memory_signals(5) or int_push_bit_out or int_push_flags_wb);
read_ram_in <= not write_ram_in or rti_pop_flags_wb;
enable_ram_in<= EM_q_memory_signals(6) or int_push_bit_out or int_push_flags_wb or rti_pop_flags_wb;
ram_read <= (enable_ram_in and read_ram_in) or RST;
ram_write <= enable_ram_in and write_ram_in;
address_loaded_from_memory<=ram_data_out;
clr_int_EM <= EM_q_memory_signals(0);
clr_rbit_EM <= EM_q_memory_signals(1);
MW_d_WB_signals <= EM_q_WB_signals;
MW_d_Rdst1 <= EM_q_Rdst1;
MW_d_Rdst2 <= EM_q_Rdst2;
MW_d_data2 <= EM_q_data2;

flag_enable <= 	(
		(not DE_q_excute_signals(1)) 	and 	-- ALU
	       	(not DE_q_excute_signals(2)) 	and	-- Selectors
		(					-- Not NOP
		 DE_q_excute_signals(8) or	
		 DE_q_excute_signals(7) or
	  	 DE_q_excute_signals(6)	or 
		 DE_q_excute_signals(5)
		)
		); 
connect_memory_pc <= EM_q_memory_signals(2);
push_pop_sp_in <=(int_push_bit_out or EM_q_memory_signals(3) or int_push_flags_wb) and not rti_pop_flags_wb;
enable_sp_in <=   int_push_bit_out or EM_q_memory_signals(4) or int_push_flags_wb  or	   rti_pop_flags_wb;
flag_enable_final <= flag_enable or rti_pop_flags_wb or flag_enable_jz;
m_sel<=enable_sp_in;

-- RAM  ============================================
RAM1: entity work.RAM
PORT MAP(clk,ram_write,ram_read, ram_address,ram_data_in,ram_data_out);

-- STACK POINTER ===================================
sp: entity work.stack_pointer
	PORT MAP( CLK,RST,push_pop_sp_in,enable_sp_in,sp_out
	);

-- RAM Address handling
ram_in_mux2x1_1: entity work.mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		EM_q_data2,sp_out,
		m_mux1_out,
		m_sel
	);	
ram_in_mux2x1_2: entity work.mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux1_out,"00000000000000000000000000000010",
		m_mux2_out,
		clr_int_EM
	);
ram_in_mux2x1_3: entity work.mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux2_out,"00000000000000000000000000000000",
		ram_address,
		RST
	);

ram_out_mux2x1_1: entity work.mux_2X1
 	GENERIC MAP(32)
 	PORT MAP(
 		EM_q_data1,ram_data_out,
 		MW_d_data1,
 		EM_q_memory_signals(6)
 	);
-- RAM Data in handling

flags_mux: entity work.mux_2X1
GENERIC MAP (flagsCount)
PORT MAP(	alu_to_flag,ram_data_out(flagsCount-1 downto 0),
		flag_temp_in, rti_pop_flags_wb
);
flag_jz_data <= flag_data(flagsCount-1 downto 1) & '0';
JZ_flags_mux: entity work.mux_2X1
GENERIC MAP (flagsCount)
PORT MAP(	flag_temp_in,flag_jz_data,
		flag_memory_in, flag_enable_jz
);

flags: entity work.flag_reg 
	PORT MAP(
	 	CLK,RST, flag_enable_final,
		flag_memory_in,flag_data
);
temp2_register : entity work.registerr 
	GENERIC MAP (32)
	PORT MAP( 	
		CLK,RST,
		instruction_address, 
		temp2_dataout,	
	 	DE_q_excute_signals(0)
);
datain_ram: entity work.RAM_datain 
	GENERIC map(32)
 	port map(
     		EM_q_data1,temp2_dataout,flag_data, -- Select one of these to put in the ram
     		int_push_bit_out,int_push_flags_wb,
    		ram_data_in
  	);

--MEMORY WRITE BACK BUFFER===========================
mwbuff : entity work.MW_buffer
PORT MAP(
	Clk,RST,MW_d_WB_signals, MW_q_WB_signals,
	MW_d_data1,MW_q_data1,MW_d_data2,MW_q_data2,MW_d_Rdst1,MW_q_Rdst1,MW_d_Rdst2,MW_q_Rdst2
	);
--===================================================
-- Write Back Signals Order
-- int_push_flags 0
-- rti_pop_flags 1
-- output_port 2
-- swap 3
-- write_back 4
--===================================================

--===========================================================================================
--WRITE BACK STAGE===========================================================================
--===========================================================================================
int_push_flags_wb <= MW_q_WB_signals(0);
rti_pop_flags_wb <= MW_q_WB_signals(1);
write_port_data1 <= MW_q_data1;
write_port_address1 <= MW_q_Rdst1;
write_port_data2 <= MW_q_data2;
write_port_address2 <= MW_q_Rdst2;

output_port_register : entity work.registerr 
	GENERIC MAP (32)
	PORT MAP( 	
		CLK,RST,
		MW_q_data1, 
		output_port_data,	
	 	MW_q_WB_signals(2)
);

END a_main;