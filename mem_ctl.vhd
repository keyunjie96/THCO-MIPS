----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:25:51 11/04/2016 
-- Design Name: 
-- Module Name:    mem_ctl - Behavioral 
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

entity mem_ctl is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sw : in  STD_LOGIC_VECTOR (16 downto 0);
           ram1_oe : out  STD_LOGIC;
           ram1_we : out  STD_LOGIC;
           ram1_en : out  STD_LOGIC;
           ram1_addr : out  STD_LOGIC_VECTOR (18 downto 0);
           ram1_data : inout  STD_LOGIC_VECTOR (16 downto 0);
           ram2_oe : out  STD_LOGIC;
           ram2_we : out  STD_LOGIC;
           ram2_en : out  STD_LOGIC;
           ram2_addr : out  STD_LOGIC_VECTOR (18 downto 0);
           ram2_data : inout  STD_LOGIC_VECTOR (16 downto 0));
end mem_ctl;

architecture Behavioral of mem_ctl is

begin


end Behavioral;

