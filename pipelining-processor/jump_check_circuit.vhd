Library ieee;
use ieee.std_logic_1164.all;

entity jump_check_circuit is
    port (      clk,rst: in std_logic;
		jz_opcode: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		zero_flag_bit: in std_logic;
           	output_state: out std_logic_vector(1 DOWNTO 0);
		not_taken_enable: out std_logic;
		disable: in std_logic);
end entity;


ARCHITECTURE a_jump_check_circuit OF jump_check_circuit IS

component jump_fsm is
    port (      clk,rst: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		input: in std_logic;
           	output: out std_logic_vector(1 DOWNTO 0));
end component;
signal predicted_taken_but_not_taken,predicted_not_taken_but_taken,taken : std_logic;
BEGIN
	predicted_taken_but_not_taken <= (not zero_flag_bit) and current_state(1);
	predicted_not_taken_but_taken <= zero_flag_bit and (not current_state(1));
	not_taken_enable <= 	jz_opcode 		-- If jz detected
				and(predicted_taken_but_not_taken or predicted_not_taken_but_taken)
				and(not disable);
	taken <= (zero_flag_bit and jz_opcode);
jfsm : jump_fsm port map (clk,rst,current_state,taken,output_state);

END a_jump_check_circuit;

