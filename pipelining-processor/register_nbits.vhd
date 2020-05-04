LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY register_nbits IS
GENERIC ( n : integer := 32);
PORT( Clk,Rst : IN std_logic;
	d1,d2 : IN std_logic_vector(n-1 DOWNTO 0);
	q : OUT std_logic_vector(n-1 DOWNTO 0);
 	enable1,enable2,wb_signal,swap_signal: in std_logic
);
	
END register_nbits;
ARCHITECTURE a_register_nbits OF register_nbits IS
BEGIN
PROCESS (d1,d2,Clk,Rst,enable1,enable2)
BEGIN
	IF Rst = '1' THEN
		q <= (OTHERS=>'0');
	ELSIF (Clk = '1' and enable1='1' and wb_signal = '1') THEN
		q <= d1;
	ELSIF (Clk = '1' and enable2='1' and swap_signal = '1') THEN
		q <= d2;
	END IF;
END PROCESS;
END a_register_nbits;