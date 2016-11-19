----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    18:43:18 11/06/2016
-- Design Name:
-- Module Name:    dispDecoder - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dispDecoder is
    Port ( data : in  STD_LOGIC_VECTOR (3 downto 0);
           display : out  STD_LOGIC_VECTOR (6 downto 0));
end dispDecoder;

architecture Behavioral of dispDecoder is
begin
    process(data)
    begin
    case data is
        when"0000"=>display<="1111110"; --0
        when"0001"=>display<="0110000"; --1
        when"0010"=>display<="1101101"; --2
        when"0011"=>display<="1111001"; --3
        when"0100"=>display<="0110011"; --4
        when"0101"=>display<="1011011"; --5
        when"0110"=>display<="1011111"; --6
        when"0111"=>display<="1110000"; --7
        when"1000"=>display<="1111111"; --8
        when"1001"=>display<="1110011"; --9
        when"1010"=>display<="1110111"; --A
        when"1011"=>display<="0011111"; --B
        when"1100"=>display<="1001110"; --C
        when"1101"=>display<="0111101"; --D
        when"1110"=>display<="1001111"; --E
        when"1111"=>display<="1000111"; --F
        when others=>display<="0000000"; --others
    end case;
end process;
end Behavioral;
