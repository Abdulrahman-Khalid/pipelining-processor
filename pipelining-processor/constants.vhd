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
    constant OperationNOP: std_logic_vector(3 downto 0) :=  "0000";
    constant OperationNOT: std_logic_vector(3 downto 0) :=  "0001";
    constant OperationINC: std_logic_vector(3 downto 0) :=  "0010";
    constant OperationDEC: std_logic_vector(3 downto 0) :=  "0011";
    constant OperationADD: std_logic_vector(3 downto 0) :=  "0100";
    constant OperationSUB: std_logic_vector(3 downto 0) :=  "0101";
    constant OperationAND: std_logic_vector(3 downto 0) :=  "0110";
    constant OperationOR: std_logic_vector(3 downto 0) :=  "0111";
    constant OperationSHL: std_logic_vector(3 downto 0) :=  "1000";
    constant OperationSHR: std_logic_vector(3 downto 0) :=  "1001";
    constant OperationIADD: std_logic_vector(3 downto 0) :=  "1010";
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
    