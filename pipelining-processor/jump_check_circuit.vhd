Library ieee;
use ieee.std_logic_1164.all;

entity jump_check_circuit is
    port (      clk,rst: in std_logic;
		jz_opcode: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		zero_flag_bit: in std_logic;
           	output_state: out std_logic_vector(1 DOWNTO 0);
		not_taken_enable: out std_logic);
end entity;


ARCHITECTURE a_jump_check_circuit OF jump_check_circuit IS

component jump_fsm is
    port (      clk,rst: in std_logic;
		current_state: in std_logic_vector(1 DOWNTO 0);
		input: in std_logic;
           	output: out std_logic_vector(1 DOWNTO 0));
end component;

signal output : std_logic_vector(1 downto 0);
BEGIN

not_taken_enable <= (not zero_flag_bit)and(jz_opcode);
jfsm : jump_fsm port map (clk,rst,current_state,zero_flag_bit,output_state);

END a_jump_check_circuit;

