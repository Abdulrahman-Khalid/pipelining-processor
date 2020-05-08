library IEEE;
USE IEEE.std_logic_1164.all;
package constants is
--registers
    constant R0: std_logic_vector(2 downto 0) := "000";
    constant R1: std_logic_vector(2 downto 0) := "001";
    constant R2: std_logic_vector(2 downto 0) := "010";
    constant R3: std_logic_vector(2 downto 0) := "011";
    constant R4: std_logic_vector(2 downto 0) := "100";
    constant R5: std_logic_vector(2 downto 0) := "101";
    constant R6: std_logic_vector(2 downto 0) := "110";
    constant R7: std_logic_vector(2 downto 0) := "111";
--ALU operations
    -- constant OperationNOP: std_logic_vector(4 downto 0) :=  "0000000000000000";
    -- constant OperationINC: std_logic_vector(4 downto 0) :=  "0001000000";
    -- constant OperationDEC: std_logic_vector(4 downto 0) :=  "0001100000";
    -- constant OperationNOT: std_logic_vector(4 downto 0) :=  "0000100000";
    -- constant OperationADD: std_logic_vector(4 downto 0) :=  "0010000";
    -- constant OperationSUB: std_logic_vector(4 downto 0) :=  "0010100";
    -- constant OperationAND: std_logic_vector(4 downto 0) :=  "0011000";
    -- constant OperationOR: std_logic_vector(4 downto 0) :=  "0011100";
    -- constant OperationSHL: std_logic_vector(4 downto 0) :=  "01000";
    -- constant OperationSHR: std_logic_vector(4 downto 0) :=  "01001";
    -- constant OperationIADD: std_logic_vector(4 downto 0) :=  "0101000000";
    constant OperationNOP: std_logic_vector(4 downto 0) :=  "00000";
    constant OperationNOT: std_logic_vector(4 downto 0) :=  "00001";
    constant OperationINC: std_logic_vector(4 downto 0) :=  "00010";
    constant OperationDEC: std_logic_vector(4 downto 0) :=  "00011";
    constant OperationADD: std_logic_vector(4 downto 0) :=  "00100";
    constant OperationSUB: std_logic_vector(4 downto 0) :=  "00101";
    constant OperationAND: std_logic_vector(4 downto 0) :=  "00110";
    constant OperationOR: std_logic_vector(4 downto 0) :=  "00111";
    constant OperationSHL: std_logic_vector(4 downto 0) :=  "01000";
    constant OperationSHR: std_logic_vector(4 downto 0) :=  "01001";
    constant OperationIADD: std_logic_vector(4 downto 0) :=  "01010";
    --Data Size
    constant ROM_ADDRESS_WIDTH: integer := 11;
    constant RAM_ADDRESS_WIDTH: integer := 32;
    constant WORD_SIZE: integer := 16;
    --flags 
    constant flagsCount: integer := 3;
    constant zFlag: integer := 0; --zero flag
    constant nFlag: integer := 1; --negative flag
    constant cFlag: integer := 2; --carry flag

end constants;
    