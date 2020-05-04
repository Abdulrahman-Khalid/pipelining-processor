LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- 2's Complement Entity
ENTITY TwosComplement is
    GENERIC (wordSize : INTEGER := 32);
    PORT(
        input:in STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0);
        output:out STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0)
        );
END ENTITY TwosComplement;

-- 2's Complement Architecture
ARCHITECTURE TwosComplementArch of TwosComplement is
    SIGNAL inA:STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0) ;
    SIGNAL inB:STD_LOGIC_VECTOR(wordSize-1 DOWNTO 0) ;
    SIGNAL inC:STD_LOGIC;
    SIGNAL outC:STD_LOGIC;
  BEGIN
    inA <= NOT input;
    inB <=  std_logic_vector(to_signed(1,wordSize));
    --inB <= (0=>'1', OTHERS=>'0'); 
    inC <= '0';
    fx: ENTITY work.NBitAdder GENERIC MAP(wordSize) PORT MAP(inA,inB,inC,output,outC);
END ARCHITECTURE;
