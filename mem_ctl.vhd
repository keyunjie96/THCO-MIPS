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
use IEEE.NUMERIC_STD.ALL;

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
           sw : in  STD_LOGIC_VECTOR (15 downto 0);
           ram1_oe : out  STD_LOGIC;
           ram1_we : out  STD_LOGIC;
           ram1_en : out  STD_LOGIC;
           ram1_addr : out  STD_LOGIC_VECTOR (15 downto 0);
           ram1_data : inout  STD_LOGIC_VECTOR (15 downto 0);
           ram2_oe : out  STD_LOGIC;
           ram2_we : out  STD_LOGIC;
           ram2_en : out  STD_LOGIC;
           ram2_addr : out  STD_LOGIC_VECTOR (15 downto 0);
           ram2_data : inout  STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           dispNum0 : out STD_LOGIC_VECTOR (6 downto 0);
           dispNum1 : out STD_LOGIC_VECTOR (6 downto 0);
           rdn : out STD_LOGIC;
           wrn : out STD_LOGIC);
end mem_ctl;

architecture Behavioral of mem_ctl is
------------components--------------------------
component dispDecoder
	port (
		data : in std_logic_vector(3 downto 0);
		display : out std_logic_vector(6 downto 0)
	);
end component;

------------signal allocation-------------------
type mem_states is (r_addr, r_data, w_mem1, r_mem1, w_mem2, r_mem2);
signal mem_state : mem_states;
signal loop_state : integer;
signal mem_state_num : STD_LOGIC_VECTOR(3 downto 0);
signal loop_state_num : STD_LOGIC_VECTOR(3 downto 0);
type word_vector is array (0 to 9) of STD_LOGIC_VECTOR(15 downto 0);
signal address : word_vector;
signal data : word_vector;
constant zero : std_logic_vector(15 downto 0) := "0000000000000000";
constant high_z : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";

begin
    rdn <= '1';
    wrn <= '1';
    loop_state_num <= std_logic_vector(to_unsigned(loop_state, 4));
    with mem_state select
        mem_state_num <= "0000" when r_addr,
                        "0001" when r_data,
                        "0010" when w_mem1,
                        "0011" when r_mem1,
                        "0100" when w_mem2,
                        "0101" when r_mem2;
    dispDecoder0 : dispDecoder port map(mem_state_num, dispNum1);
    dispDecoder1 : dispDecoder port map(loop_state_num, dispNum0);

    process (clk, rst)
    begin
        if rst = '0' then
            --reset state
            mem_state <= r_addr;
            loop_state <= 0;
            --clean up data
            ram1_addr <= zero;
            ram1_data <= zero;
            ram2_data <= zero;
            ram2_addr <= zero;
            ram1_en <= '1';
            ram1_we <= '0';
            ram1_oe <= '0';
            ram2_en <= '1';
            ram2_we <= '0';
            ram2_oe <= '0';
            led <= zero;
        elsif falling_edge(clk) then
            case mem_state is
                when r_addr =>
                    --read address from switches
                    address(0) <= sw;
                    led <= sw;
                    --state change
                    mem_state <= r_data;
                when r_data =>
                    --read data from switches
                    data(0) <= sw;
                    led <= sw;
                    --set control ram1 control signal
                    ram1_en <= '0';
                    ram1_we <= '1';
                    ram1_oe <= '1';
                    --state change
                    mem_state <= w_mem1;
                    loop_state <= 0;
                when w_mem1 =>
                    ram1_en <= '0';
                    ram1_oe <= '1';
                    ram1_we <= '0';
                    ram1_addr <= address(loop_state);
                    ram1_data <= data(loop_state);
                    led <= data(loop_state);
                    address(loop_state + 1) <= STD_LOGIC_VECTOR(UNSIGNED(address(loop_state)) + 1);
                    data(loop_state + 1) <= STD_LOGIC_VECTOR(UNSIGNED(data(loop_state)) + 1);
                    --state change
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        mem_state <= w_mem1;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        mem_state <= r_mem1;
                    end if;
                when r_mem1 =>
                    ram1_en <= '0';
                    ram1_oe <= '0';
                    ram1_we <= '1';
                    ram1_data <= high_z;
					ram1_addr <= address(loop_state);
					led <= ram1_data after 20ns;

                    --state change
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        mem_state <= r_mem1;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        mem_state <= w_mem2;
                    end if;
                when w_mem2 =>
                    ram2_en <= '0';
                    ram2_we <= '0';
                    ram2_oe <= '1';
                    ram2_addr <= address(loop_state);
                    ram2_data <= STD_LOGIC_VECTOR(UNSIGNED(data(loop_state)) - 1);
                    led <= address(loop_state);
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        mem_state <= w_mem2;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        mem_state <= r_mem2;
                    end if;
                when r_mem2 =>
                    ram2_en <= '0';
                    ram2_we <= '1';
                    ram2_oe <= '0';
                    ram2_addr(15 downto 0) <= address(loop_state);
                    led <= ram2_data;
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        mem_state <= r_mem2;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        mem_state <= r_addr;
                    end if;
            end case;
        end if;
    end process;
end Behavioral;
