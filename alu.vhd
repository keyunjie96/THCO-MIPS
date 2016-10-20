----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:29:02 10/19/2016 
-- Design Name: 
-- Module Name:    alu - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
USE IEEE.numeric_std.all;--The IEEE.numeric_std library will need to be accessed for these functions
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (15 downto 0);
           fout : out  STD_LOGIC_VECTOR (15 downto 0);
           flag : out  STD_LOGIC);
end alu;


architecture Behavioral of alu is

---------------------------信号声明-------------------------------
type alu_state_machine is (iA, iB, iOP_oF, oFLAG); --分别是待输入A，待输入B，待输入OP且输入后会输出FOUT，输出FLAG
signal alu_state : alu_state_machine;
signal operand_A, operand_B : STD_LOGIC_VECTOR(16 downto 0); --操作数A和操作数B
signal result : STD_LOGIC_VECTOR(16 downto 0); --存储结果，高位保留进位信息
begin
fout <= result(15 downto 0);
-------------------clk, rst 主导的alu运算--------------------
process(clk, rst) is
variable integer_B : INTEGER;
begin
    --重置信号
    if rst = '0' then
        alu_state <= iA;
        result <= "00000000000000000";
        flag <= '0';
    --时钟下降沿，进行原始计算
    elsif falling_edge(clk) then
        integer_B := conv_integer(operand_B);
        case alu_state is
            when iA =>
                operand_A(15 downto 0) <= sw;
                result(15 downto 0) <= sw;
                alu_state <= iB;
            when iB =>
                operand_B(15 downto 0) <= sw;
                result(15 downto 0) <= sw;
                alu_state <= iOP_oF;
            when iOP_oF=>
                case sw is 
                    when "1000000000000000" =>
                        result <= operand_A + operand_B;
                    when "0100000000000000" =>
                        result <= operand_A - operand_B;
                    when "0010000000000000" =>
                        result <= operand_A and operand_B;
                    when "0001000000000000" =>
                        result <= operand_A or operand_B;
                    when "0000100000000000" =>
                        result <= operand_A xor operand_B;
                    when "0000010000000000" =>
                        result <= not operand_A;
                    when "0000001000000000" =>
                        result <= to_stdlogicvector(to_bitvector(operand_A) sll integer_B);
                    when "0000000100000000" =>
                        result <= to_stdlogicvector(to_bitvector(operand_A) srl integer_B);
                    when "0000000010000000" =>
                        result <= to_stdlogicvector(to_bitvector(operand_A) sla integer_B);
                    when "0000000001000000" =>
                        result <= to_stdlogicvector(to_bitvector(operand_A) rol integer_B);
                    when others => null;
                end case; 
                alu_state <= oFLAG;
            when oFLAG=>
                --分别对应进位，负数，全0
                if result(16) = '1' or result(15) = '1' or result(15 downto 0) = "0000000000000000" then
                    flag <= '1';
                else
                    flag <= '0';
                end if;
                alu_state <= iA;
            when others => null;
        end case;
    end if;
end process;

end Behavioral;

