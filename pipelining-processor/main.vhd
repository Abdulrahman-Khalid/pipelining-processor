LIBRARY IEEE;
USE work.constants.all;
USE IEEE.std_logic_1164.all;
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
-- Define ROM
COMPONENT ROM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 11; ROMSize: integer := 2048);
		PORT(	
		enable  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT ROM;
-- Define RAM
COMPONENT RAM IS
	GENERIC (wordSize : integer := 16; addressWidth: integer := 32; RAMSize: integer := 2**20-1);
	PORT(	
		W  : IN std_logic;
		R  : IN std_logic;
		address : IN  std_logic_vector(addressWidth - 1 DOWNTO 0);
		dataIn  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataOut  : OUT  std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT RAM;
-- Define data to RAM selector
COMPONENT RAM_datain is
GENERIC ( n : integer := 32);
 port(
     data,temp2,flags : in std_logic_vector(n-1 DOWNTO 0);
     temp2_enable,flags_enable: in STD_LOGIC;
     data_out: out std_logic_vector(n-1 DOWNTO 0)
  );
END COMPONENT;
-- Define Mux 2x1
COMPONENT mux_2X1 IS
	GENERIC ( n : integer := 32);
	PORT(
		input1,input2 : IN std_logic_vector(n-1 DOWNTO 0);
		output	      : OUT std_logic_vector(n-1 DOWNTO 0);
		selector      : IN std_logic
	);	
END COMPONENT;
-- Define mux 4X1
COMPONENT mux_4X1 is
GENERIC ( n : integer := 32);
 port(
 
     A,B,C,D : in std_logic_vector(n-1 DOWNTO 0);
     S0,S1: in STD_LOGIC;
     Z: out std_logic_vector(n-1 DOWNTO 0)
  );
END COMPONENT;
-- Define Register 
COMPONENT registerr IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst 	: IN std_logic;
	d	: IN std_logic_vector(n-1 DOWNTO 0);
	q 	: OUT std_logic_vector(n-1 DOWNTO 0);
 	enable: in std_logic
);
END COMPONENT;
-- Define Stack Pointer
COMPONENT stack_pointer IS
	GENERIC ( n : integer := 32);
	PORT( CLK,RST,push_pop,enable_stack
		      : IN std_logic;
		    sp_out
		      : OUT std_logic_vector(n-1 DOWNTO 0)
	);
END COMPONENT;
-- Define PC register
COMPONENT pc_register IS
GENERIC ( n : integer := 32;
	  codeSegmentStart: integer :=500);
PORT( Clk,Rst : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
	enable: in std_logic);
END COMPONENT;
-- Define one bit buffer
COMPONENT one_bit_buffer is
    port (      clk,rst,set,clr	: in std_logic;
		output	: out std_logic);
END COMPONENT;
-- Define Control Unit
COMPONENT control_unit is
    port (      rst: in std_logic;
		input: in std_logic_vector(4 DOWNTO 0);
		alu_operation: out std_logic_vector(3 DOWNTO 0);
		one_src, input_port,
		enable_temp2,
		cu_s0,cu_s1,			--aluops
		enable_mem, read_write,		--memory ops
		enable_stack, push_pop,
		mem_to_pc, clr_rbit,
		clr_int,
		write_back, swap,		--write back ops
		rti_pop_flags, int_push_flags, 
		output_port,load
			: out std_logic);
end COMPONENT;
-- Define incrementor 
COMPONENT incrementor IS
GENERIC ( n : integer := 32);
PORT( CLK,RST : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
		enable: in std_logic);
END COMPONENT;
-- Define Pc circuit 
COMPONENT pc_circuit IS
GENERIC ( n : integer := 32);
-- Takes 4 addresses as inputs and select one of them
PORT( 
	unchanged_pc, incremented_pc, not_taken_address,
	address_loaded_from_memory,jump_address : IN std_logic_vector(n-1 DOWNTO 0); 
	unchanged_pc_enable, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable : in std_logic;
	address_to_pc, not_taken_address_to_fetch_buffer : OUT std_logic_vector(n-1 DOWNTO 0));
END COMPONENT;
-- Define memory used with jump states
COMPONENT state_memory IS
	Generic(addressBits: integer :=8;
		wordSize: integer :=2);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address_write,address_read : IN  std_logic_vector(addressBits - 1 DOWNTO 0);
		datain  : IN  std_logic_vector(wordSize - 1 DOWNTO 0);
		dataout : OUT std_logic_vector(wordSize - 1 DOWNTO 0));
END COMPONENT;

-- Define dynamic jumo check prediction circuit
COMPONENT jump_check_circuit is
    port (      clk,rst: in std_logic;
		jz_opcode: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		zero_flag_bit: in std_logic;
           	output_state: out std_logic_vector(1 DOWNTO 0);
		not_taken_enable: out std_logic);
END COMPONENT;

-- Define register files that contain 3 read ports and 2 write ports
COMPONENT register_files IS
GENERIC ( n : integer := 32);
PORT( 		Clk,Rst,wb_signal,swap_signal : IN std_logic;
	    	write_port_data1,write_port_data2 : IN std_logic_vector(n-1 DOWNTO 0);
	    	write_port_address1,write_port_address2 : IN std_logic_vector(2 DOWNTO 0);
	    	read_port_data1,read_port_data2,read_port_data3 : OUT std_logic_vector(n-1 DOWNTO 0);
	    	read_port_address1,read_port_address2,read_port_address3 : IN std_logic_vector(2 DOWNTO 0)
);
END COMPONENT;

-- Define buffers

COMPONENT FD_buffer IS
PORT( Clk,Reset, Enable, Flush : IN std_logic;
	    d_instruction : IN std_logic_vector(15 DOWNTO 0);
	    q_instruction : OUT std_logic_vector(15 DOWNTO 0);

	    d_not_taken_address : IN std_logic_vector(31 DOWNTO 0);
	    q_not_taken_address : OUT std_logic_vector(31 DOWNTO 0);

	    d_predicted_state : IN std_logic_vector(1 DOWNTO 0);
	    q_predicted_state : OUT std_logic_vector(1 DOWNTO 0);

	    d_state_address : IN std_logic_vector(7 DOWNTO 0);
	    q_state_address : OUT std_logic_vector(7 DOWNTO 0)
);
	
END COMPONENT;

COMPONENT DE_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_memory_signals : IN std_logic_vector(7 DOWNTO 0);
	    q_memory_signals : OUT std_logic_vector(7 DOWNTO 0);

	    d_excute_signals : IN std_logic_vector(8 DOWNTO 0);
	    q_excute_signals : OUT std_logic_vector(8 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rsrc1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rsrc1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rsrc2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rsrc2 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

COMPONENT EM_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_memory_signals : IN std_logic_vector(7 DOWNTO 0);
	    q_memory_signals : OUT std_logic_vector(7 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

COMPONENT MW_buffer IS
PORT( Clk,Reset : IN std_logic;
	    d_WB_signals : IN std_logic_vector(4 DOWNTO 0);
	    q_WB_signals : OUT std_logic_vector(4 DOWNTO 0);

	    d_data1 : IN std_logic_vector(31 DOWNTO 0);
	    q_data1 : OUT std_logic_vector(31 DOWNTO 0);

	    d_data2 : IN std_logic_vector(31 DOWNTO 0);
	    q_data2 : OUT std_logic_vector(31 DOWNTO 0);

	    d_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst1 : OUT std_logic_vector(2 DOWNTO 0);

	    d_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	    q_Rdst2 : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

--Define forwarding unit

COMPONENT forwarding_unit IS
PORT( 
	EM_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	EM_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	EM_WB_signal: IN std_logic;
	EM_swap_signal: IN std_logic;
	EM_memory_signal : IN std_logic;

	MW_Rdst1 : IN std_logic_vector(2 DOWNTO 0);
	MW_Rdst2 : IN std_logic_vector(2 DOWNTO 0);
	MW_WB_signal : IN std_logic;
	MW_swap_signal : IN std_logic;

	memory_instruction : IN std_logic_vector(15 DOWNTO 0);

	DE_Rsrc1 : IN std_logic_vector(2 DOWNTO 0);
	DE_Rsrc2 : IN std_logic_vector(2 DOWNTO 0);
	DE_WB_signal : IN std_logic;
	DE_swap_signal : IN std_logic;
	DE_memory_signal : IN std_logic;
	DE_oneSrc_signal : IN std_logic;

	--OUTPUT SIGNALS FOR FORWARDING TO FETCH
	ALU_F_Rdst1 : OUT std_logic;
	ALU_F_Rdst2 : OUT std_logic;
	MEM_F_Rdst1 : OUT std_logic;
	MEM_F_Rdst2 : OUT std_logic;

	--OUTPUT SIGNALS FOR FORWARDING FROM ALU TO ALU
	ALU_ALU_Rdst1_Rsrc1 : OUT std_logic;
	ALU_ALU_Rdst1_Rsrc2 : OUT std_logic;
	ALU_ALU_Rdst2_Rsrc1 : OUT std_logic;
	ALU_ALU_Rdst2_Rsrc2 : OUT std_logic;

	--OUTPUT SIGNALS FOR FORWARDING FROM MEMORY TO ALU
	MEM_ALU_Rdst1_Rsrc1 : OUT std_logic;
	MEM_ALU_Rdst1_Rsrc2 : OUT std_logic;
	MEM_ALU_Rdst2_Rsrc1 : OUT std_logic;
	MEM_ALU_Rdst2_Rsrc2 : OUT std_logic
);
	
END COMPONENT;

--Define ALU input selectors

COMPONENT ALU_in1_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    DE_data1 : IN std_logic_vector(31 DOWNTO 0);

	    ALU_ALU_Rdst1_Rsrc1 : IN std_logic;
	    ALU_ALU_Rdst2_Rsrc1 : IN std_logic;
	    MEM_ALU_Rdst1_Rsrc1 : IN std_logic;
	    MEM_ALU_Rdst2_Rsrc1 : IN std_logic;

	    ALU_in1 : OUT std_logic_vector(31 DOWNTO 0)

);
	
END COMPONENT;

COMPONENT ALU_in2_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    DE_data2 : IN std_logic_vector(31 DOWNTO 0);

	    ALU_ALU_Rdst1_Rsrc2 : IN std_logic;
	    ALU_ALU_Rdst2_Rsrc2 : IN std_logic;
	    MEM_ALU_Rdst1_Rsrc2 : IN std_logic;
	    MEM_ALU_Rdst2_Rsrc2 : IN std_logic;

	    ALU_in2 : OUT std_logic_vector(31 DOWNTO 0)

);
	
END COMPONENT;

--Define fetch Rdst selector

COMPONENT fetch_Rdst_selector IS
PORT( 
	    EM_data1 : IN std_logic_vector(31 DOWNTO 0);
	    EM_data2 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data1 : IN std_logic_vector(31 DOWNTO 0);
	    MW_data2 : IN std_logic_vector(31 DOWNTO 0);

	    REG_data : IN std_logic_vector(31 DOWNTO 0);

	    ALU_F_Rdst1 : IN std_logic;
	    ALU_F_Rdst2 : IN std_logic;
	    MEM_F_Rdst1 : IN std_logic;
	    MEM_F_Rdst2 : IN std_logic;

	    data : OUT std_logic_vector(31 DOWNTO 0)

);
	
END COMPONENT;

--Define flag register
COMPONENT flag_reg IS
PORT( Clk,Reset, Enable : IN std_logic;

	    d_flags : IN std_logic_vector(2 DOWNTO 0);
	    q_flags : OUT std_logic_vector(2 DOWNTO 0)
);
	
END COMPONENT;

-- Define ALU 
COMPONENT ALU is
    generic(n: integer := 32; m: integer := 4);
    port(operationControl: in std_logic_vector(m-1 downto 0);
        A, B: in std_logic_vector(n-1 downto 0);
        F: out std_logic_vector(n-1 downto 0);
        flagIn: in std_logic_vector(flagsCount-1 downto 0);
        flagOut: out std_logic_vector(flagsCount-1 downto 0));
END COMPONENT;
-- Define Hazard Detection Unit
COMPONENT HDU is
    generic(n: integer := 3);
    port(WB_CU, WB_ID_E, WB_E_MEM, swap_CU, swap_ID_E, load_ID_E, load_E_MEM, Branch_MEM: in std_logic;
        Rsrc1_F_ID, Rsrc2_F_ID, Rdst1_F_ID, Rdst2_F_ID, Rdst1_ID_E, Rdst2_ID_E, Rdst_E_MEM, Rdst_MEM: in std_logic_vector(n-1 downto 0);
        insert_bubble, flush: out std_logic);
END COMPONENT;

COMPONENT data2_selector is
	GENERIC ( n : integer := 32);
 	port(
     		RF_data2,temp_pc, shift_data,effective_address
		,immediate_data: in std_logic_vector(n-1 DOWNTO 0);
     		opcode: in std_logic_vector(4 downto 0);
     		Z: out std_logic_vector(n-1 DOWNTO 0));
END COMPONENT;
-- =====================================================================================
-- SIGNALS USED ========================================================================
-- =====================================================================================
signal  instruction_address, incremented_pc, address_loaded_from_memory,
	address_to_pc, write_port_data1,write_port_data2,
	read_port_data1,read_port_data2,read_port_data3,temp2_dataout,
	output_port_data, alu_output, temp_pc_data, temp :std_logic_vector(31 downto 0);
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
signal m_sel : std_logic;
signal flag_in,flag_out: std_logic_vector(flagsCount-1 downto 0);
---------------------------------------------------------------------------------------
signal  jump_enable, not_taken_address_enable,jz_opcode,call_opcode,jmp_opcode, 
        connect_memory_pc, stall, address_loaded_from_memory_enable,flag_enable, jz_FD_opcode,
	insert_bubble, flush,branch,
---------------------------------------------------------------------------------------
--interrupt and return one bit buffers output signals
	int_bit_out,int_push_bit_out,rbit_out,
	ret_opcode,rti_opcode,rti_or_ret,
	clr_int_EM,clr_rbit_EM,
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
INT_BIT: one_bit_buffer
PORT MAP(	CLK,RST,INT,clr_int_EM,int_bit_out);
RBIT: one_bit_buffer
PORT MAP(	CLK,RST,rti_or_ret, clr_rbit_EM,rbit_out);
--TODO change int_push_flags to take from WB stage
--INT_PUSH_BIT: one_bit_buffer 
--PORT MAP(	CLK,RST,int_push_flags,int_push_bit_out_WB,int_push_bit_out);

-- Hazard detection unit
branch <= jz_opcode or jmp_opcode or call_opcode;
hazards: HDU 
    generic map(3)
    -- Branch_MEM is '1' if jmp or jz or call from memory
    port map(write_back, DE_q_WB_signals(4), EM_q_WB_signals(4), swap, DE_q_WB_signals(3), DE_q_memory_signals(7),
	 EM_q_memory_signals(7), branch, FD_q_instruction(5 downto 3), FD_q_instruction(8 downto 6),
	 FD_q_instruction(2 downto 0),FD_q_instruction(8 downto 6), DE_q_Rdst1, DE_q_Rdst2, EM_q_Rdst1, rom_data_out(2 downto 0),
         insert_bubble, flush);
stall <= flush or insert_bubble or int_bit_out or rbit_out;

FU: forwarding_unit 
PORT MAP( 
	EM_q_Rdst1, EM_q_Rdst2, EM_q_WB_signals(4), EM_q_WB_signals(3), EM_q_memory_signals(6),
	MW_q_Rdst1, MW_q_Rdst2, MW_q_WB_signals(4), MW_q_WB_signals(3),
	rom_data_out,
	DE_q_Rsrc1,
	DE_q_Rsrc2,
	DE_q_WB_signals(4),
	DE_q_WB_signals(3),
	DE_q_memory_signals(6),
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
jz_opcode and (
(FD_d_predicted_state(1) and FD_d_predicted_state(0)) or  
(FD_d_predicted_state(1) and (not FD_d_predicted_state(0)))    
)));
rom_read<='1';
rom_address<=instruction_address(10 downto 0);
read_port_address3 <= rom_data_out(2 downto 0);

-- ROM  ===============================
ROM1: ROM PORT MAP(rom_read, rom_address,rom_data_out);

-- ROM connections ====================
mux_rom_fd_int: mux_2X1
GENERIC MAP(16)
PORT MAP(rom_data_out,"1011100000000000",FD_d_instruction,int_bit_out);
instr_opcode<=FD_d_instruction(15 downto 11);

-- PC ADDRESS HANDLING  ===============
FSEL: fetch_Rdst_selector
PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2,read_port_data3 ,ALU_F_Rdst1, ALU_F_Rdst2, MEM_F_Rdst1,
	MEM_F_Rdst2, FSEL_out
);
-- Used to choose the appropiate address of next instruction depend on certain enables.
PC_ADDRESS_CIRCUIT: pc_circuit PORT MAP( 
	instruction_address, incremented_pc, FD_q_not_taken_address,
	address_loaded_from_memory,FSEL_out ,
	stall, jump_enable, not_taken_address_enable,
	address_loaded_from_memory_enable,
	address_to_pc, FD_d_not_taken_address );
address_loaded_from_memory_enable <= (connect_memory_pc or RST);
-- PC register used to get the instruction address to fetch it
PC : pc_register PORT MAP(CLK,RST,address_to_pc,instruction_address,'1');
-- Enabled when call instruction is fetched to push the next pc value
TEMP_PC : pc_register PORT MAP(CLK,RST,incremented_pc,temp_pc_data,call_opcode);
-- IncrementPC by one
INC: incrementor PORT MAP(CLK,RST,instruction_address,incremented_pc,'1');

--FETCH DECODE BUFFER==============================
FD_d_state_address <= instruction_address(7 downto 0);

--TODO set enable to fetch buffer
FD_Enable <= '1';
fdbuff : FD_buffer PORT MAP(CLK, RST, FD_Enable, flush, FD_d_instruction, FD_q_instruction,
 	FD_d_not_taken_address, FD_q_not_taken_address, FD_d_predicted_state, FD_q_predicted_state,
	FD_d_state_address, FD_q_state_address);

--========================================================================================
--DECODE STAGE ===========================================================================
--========================================================================================
opcode <= FD_q_instruction(15 downto 11);
jz_FD_opcode<= (opcode(4)and (not opcode(3)) and (not opcode(2)) and opcode(1) and (not opcode(0)) );
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

shift_data <= std_logic_vector("0000000000000000"&"00000000000"&FD_q_instruction(10 downto 6));
effective_address <= std_logic_vector("000000000000"&FD_q_instruction(9 downto 6)&rom_data_out);
immediate_data <= std_logic_vector("0000000000000000"&rom_data_out);
-- DYNAMIC PREDICTION FOR JUMP INSTRUCTION =======================

JCC: jump_check_circuit PORT MAP (CLK,RST,jz_FD_opcode,FD_q_predicted_state, flag_out(zFlag), output_state,
		not_taken_address_enable);

SM: state_memory PORT MAP(CLK ,not_taken_address_enable,FD_q_state_address,FD_d_state_address ,
		output_state , FD_d_predicted_state);

-- Control Unit  ===================================
cu_rst <= DE_q_excute_signals(0) or insert_bubble or RST;
CU: control_unit
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
RF: register_files 
PORT MAP(	CLK,RST,MW_q_WB_signals(4),MW_q_WB_signals(3),write_port_data1,write_port_data2,
	    	write_port_address1,write_port_address2, 
	    	read_port_data1,read_port_data2,read_port_data3,
	    	read_port_address1,read_port_address2,read_port_address3);

-- Select data 2 input to the buffer
select_data2: data2_selector 
 	port map(
     		read_port_data2,temp_pc_data,
		shift_data,effective_address
		,immediate_data,
     		opcode,DE_d_data2);

--DECODE EXECUTE BUFFER ==============================
debuff : DE_buffer PORT MAP(CLK, RST,DE_d_WB_signals,DE_q_WB_signals,
	DE_d_memory_signals , DE_q_memory_signals,
	DE_d_excute_signals , DE_q_excute_signals, DE_d_data1, DE_q_data1, DE_d_data2, DE_q_data2,
	DE_d_Rsrc1, DE_q_Rsrc1, DE_d_Rsrc2, DE_q_Rsrc2, DE_d_Rdst1, DE_q_Rdst1, DE_d_Rdst2, DE_q_Rdst2);


--===========================================================================================
--EXECUTE STAGE =============================================================================
--===========================================================================================
EM_d_Rdst1 <= DE_q_Rdst1;
EM_d_Rdst2 <= DE_q_Rdst2;
ALUSEL1: ALU_in1_selector -- First operand selector
	PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2, DE_q_data1, ALU_ALU_Rdst1_Rsrc1, ALU_ALU_Rdst2_Rsrc1,
		MEM_ALU_Rdst1_Rsrc1,MEM_ALU_Rdst2_Rsrc1, ALU_in1);

ALUSEL2: ALU_in2_selector -- Second operand selector
	PORT MAP(EM_q_data1, EM_q_data2, MW_q_data1, MW_q_data2, DE_q_data2, ALU_ALU_Rdst1_Rsrc2, ALU_ALU_Rdst2_Rsrc2,
		MEM_ALU_Rdst1_Rsrc2,MEM_ALU_Rdst2_Rsrc2, ALU_in2);
ALU1: ALU
    	port map(
		DE_q_excute_signals(8 downto 5),
        	ALU_in1, ALU_in2,
		alu_output,
	        flag_out,flag_in);

data1_to_EMB_mux_4X1: mux_4X1 
 	port map(
     		alu_output,ALU_in1,input_port_data,ALU_in2,
     		DE_q_excute_signals(1),DE_q_excute_signals(2), -- Mux selectors 
     		EM_d_data1);

data2_to_EMB_mux: mux_2X1
	GENERIC MAP(32)
	PORT MAP(ALU_in2,ALU_in1,EM_d_data2,DE_q_WB_signals(3));

--EXECUTE MEMORY BUFFER =============================
embuff : EM_buffer
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
ram_read <= (EM_q_memory_signals(6) and not EM_q_memory_signals(5)) or RST;
ram_write <= EM_q_memory_signals(6) and EM_q_memory_signals(5);
address_loaded_from_memory<=ram_data_out;
clr_int_EM <= EM_q_memory_signals(0);
clr_rbit_EM <= EM_q_memory_signals(1);
MW_d_WB_signals <= EM_q_WB_signals;
MW_d_Rdst1 <= EM_q_Rdst1;
MW_d_Rdst2 <= EM_q_Rdst2;
MW_d_data2 <= EM_q_data2;
-- NOT TESTED
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
-- RAM  ============================================
RAM1: RAM
PORT MAP(ram_write,ram_read, ram_address,ram_data_in,ram_data_out);

connect_memory_pc <= EM_q_memory_signals(2);
sp: stack_pointer
	PORT MAP( CLK,RST,EM_q_memory_signals(3),EM_q_memory_signals(4),sp_out
	);
-- RAM Address handling
m_sel<=EM_q_memory_signals(6);
ram_in_mux2x1_1: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		EM_q_data2,sp_out,
		m_mux1_out,
		m_sel
	);	
ram_in_mux2x1_2: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux1_out,"00000000000000000000000000000010",
		m_mux2_out,
		clr_int
	);
ram_in_mux2x1_3: mux_2X1
	GENERIC MAP(32)
	PORT MAP(
		m_mux2_out,"00000000000000000000000000000000",
		ram_address,
		RST
	);

ram_out_mux2x1_1: mux_2X1
 	GENERIC MAP(32)
 	PORT MAP(
 		EM_q_data1,ram_data_out,
 		MW_d_data1,
 		EM_q_memory_signals(6)
 	);
-- RAM Data in handling
flags: flag_reg 
	PORT MAP(
	 	CLK,RST, flag_enable,
		flag_in,flag_out
);
temp2_register : registerr 
	GENERIC MAP (32)
	PORT MAP( 	
		CLK,RST,
		instruction_address, --REVIEW: input data correct ?
		temp2_dataout,	
	 	DE_q_excute_signals(0)
);
--datain_ram: RAM_datain 
--	GENERIC (32);
-- 	port(
--     		EM_q_data1,temp2_dataout,flag_out, -- Select one of these to put in the ram
     		--enable1,enable2: TODO put enables to temp2 and flag
--     		ram_data_in
--  	);
-- TODO remove it and uncomment previous module
ram_data_in <= EM_q_data1;
--MEMORY WRITE BACK BUFFER===========================
mwbuff : MW_buffer
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
write_port_data1 <= MW_q_data1;
write_port_address1 <= MW_q_Rdst1;
write_port_data2 <= MW_q_data2;
write_port_address2 <= MW_q_Rdst2;

output_port_register : registerr 
	GENERIC MAP (32)
	PORT MAP( 	
		CLK,RST,
		MW_q_data1, 
		output_port_data,	
	 	MW_q_WB_signals(2)
);

END a_main;