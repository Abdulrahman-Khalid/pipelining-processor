LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY sp_register IS
GENERIC ( n : integer := 32);
PORT( CLK,RST : IN std_logic;
	    d : IN std_logic_vector(n-1 DOWNTO 0);
	    q : OUT std_logic_vector(n-1 DOWNTO 0);
	enable: in std_logic
);
	
END sp_register;
ARCHITECTURE sp_register_nbits OF sp_register IS
BEGIN
PROCESS (RST,d,CLK,enable)
	BEGIN
	
		IF(RST = '1') THEN
			q<= std_logic_vector(to_unsigned(2**20-1, q'length));
		ELSIF (rising_edge(CLK) and enable='1') THEN
			q <= d;
		END IF;
	END PROCESS;
END;

------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY stack_pointer IS
	GENERIC ( n : integer := 32);
	PORT( CLK,RST,push_pop,enable_stack
		      : IN std_logic;
		    sp_out
		      : OUT std_logic_vector(n-1 DOWNTO 0)
	);
END ENTITY;



ARCHITECTURE stack_pointer_arch OF stack_pointer IS
	COMPONENT sp_register IS
	GENERIC ( n : integer := 32);
	PORT( CLK,RST: IN std_logic;
			d : IN std_logic_vector(n-1 DOWNTO 0);
			q : OUT std_logic_vector(n-1 DOWNTO 0);
			enable: in std_logic
			);
	END COMPONENT;
	COMPONENT mux_4X1 is
	GENERIC ( n : integer := 32);
 	port(
 
 	    A,B,C,D : in std_logic_vector(n-1 DOWNTO 0);
 	    S0,S1: in STD_LOGIC;
 	    Z: out std_logic_vector(n-1 DOWNTO 0)
 	 );
	end COMPONENT;
signal sp_reg_input, sp_reg_output, sp_p2,sp_m2  :std_logic_vector(n-1 DOWNTO 0);
begin
sp_reg: sp_register
PORT MAP(CLK,RST,sp_reg_input,sp_reg_output,'1');
sp_p2 <= (sp_reg_output + 2);
sp_m2 <= (sp_reg_output - 2);
mux1: mux_4X1
PORT MAP(sp_reg_output,sp_reg_output,sp_p2,sp_m2,push_pop,enable_stack,sp_reg_input);
mux2: mux_4X1
PORT MAP(sp_reg_output,sp_reg_output,sp_p2,sp_reg_output,push_pop,enable_stack,sp_out);
END stack_pointer_arch;
