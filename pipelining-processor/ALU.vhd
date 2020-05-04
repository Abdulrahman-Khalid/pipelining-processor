library IEEE;
use IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.constants.all;

--operation codes
    -- ADD (A + B)
    -- IADD (A + B)
    -- SUB (A - B)
    -- INC (A + 1)
    -- DEC (A - 1)
    
    -- OR (A or B)
    -- AND (A and B)
    -- NOT (not A)

    -- SHL shift left A by B times
    -- SHR shift right A by B times

entity ALU is
    generic(n: integer := 32; m: integer := 5);
    port(
        operationControl: in std_logic_vector(m-1 downto 0);
        A, B: in std_logic_vector(n-1 downto 0);
        F: out std_logic_vector(n-1 downto 0);
        flagIn: in std_logic_vector(flagsCount-1 downto 0);
        flagOut: out std_logic_vector(flagsCount-1 downto 0));
end entity;

architecture ALU_Arch of ALU is
    signal sigB, sigF, subTowsCompB: std_logic_vector(n-1 downto 0);
    signal arthimatic, logical, shift, arth_logic_shift, carryIn, carryOut, shiftCarry: std_logic;
    signal FTemp: std_logic_vector(n-1 downto 0);
    signal shiftTemp, shiftResult: std_logic_vector(n downto 0);
    constant ZEROS: std_logic_vector(n-1 downto 0):= (others=>'0');
    begin
        F <= FTemp;
        
        fAdder: entity work.nbitAdder generic map(n) port map(A, sigB, carryIn, sigF, carryOut);
        twosSUB: entity work.TwosComplement generic map(n) port map(B, subTowsCompB);
        
        sigB <= subTowsCompB when operationControl = OperationSUB
        else (others => '0') when operationControl = OperationINC
        else (others => '1') when operationControl = OperationDEC
        else B;

        carryIn <= '1' when operationControl = OperationINC
        else '0';
        
        arthimatic <= '1' when (operationControl = OperationADD
                                or operationControl = OperationIADD
                                or operationControl = OperationSUB 
                                or operationControl = OperationINC 
                                or operationControl = OperationDEC) else '0';
        logical <= '1' when (operationControl = OperationAND 
                            or operationControl = OperationOR
                            or operationControl = OperationNOT) else '0';
        shift <= '1' when (operationControl = OperationSHL 
                          or operationControl = OperationSHR) else '0';
        arth_logic_shift <= '1' when (arthimatic = '1' or logical = '1' or shift = '1') else '0';

        shiftTemp <= ('0' & B) when operationControl = OperationSHL
        else (B & '0') when operationControl = OperationSHR else (others => '0');

        shiftResult <= shift_left(unsigned(shiftTemp), to_integer(unsigned(B))) when operationControl = OperationSHL
        else shift_right(unsigned(shiftTemp), to_integer(unsigned(B))) when operationControl = OperationSHR
        else (others => '0');

        FTemp <= sigF when arthimatic = '1'
        else (A and B) when operationControl = OperationAND
        else (A or B) when operationControl = OperationOR
        else not(A) when operationControl = OperationNOT
        else shiftResult(n-1 downto 0) when operationControl = OperationSHL
        else shiftResult(n downto 1) when operationControl = OperationSHR
        else A; -- A when (operationControl = OperationNOP) or other operations
        
        --carry flag
        -- if (operationControl = OperationNOP) or other operations flags don't change
        flagOut(cFlag) <= carryOut  when arthimatic = '1'
        else shiftResult(n) when operationControl = OperationSHL 
        else shiftResult(0) when operationControl = OperationSHR 
        else flagIn(cFlag); 

        --zero flag
        -- if (operationControl = OperationNOP) or other operations flags don't change
        flagOut(zFlag) <= '1' when (FTemp = ZEROS and arth_logic_shift = '1') 
        else '0' when arth_logic_shift = '1'
        else flagIn(zFlag);

        --negative flag
        -- if (operationControl = OperationNOP) or other operations flags don't change
        flagOut(nFlag) <= FTemp(n-1) when arth_logic_shift = '1' else flagIn(nFlag);

end architecture;