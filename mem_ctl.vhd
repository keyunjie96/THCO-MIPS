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
           data_ready : in  STD_LOGIC;
           tbre : in  STD_LOGIC;
           tsre : in  STD_LOGIC;
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
type big_state_machine is (r_uart, w_mem1, r_mem1, w_mem2, r_mem2, w_uart);
type read_state_machine is (r0, r1, r2, r3);
type write_state_machine is (w0, w1, w2, w3, w4, w5);
signal big_state : big_state_machine;
signal read_state : read_state_machine;
signal write_state : write_state_machine;

signal loop_state : integer;
signal big_state_num : STD_LOGIC_VECTOR(3 downto 0);
signal loop_state_num : STD_LOGIC_VECTOR(3 downto 0);

type word_vector is array (0 to 9) of STD_LOGIC_VECTOR(15 downto 0);
signal address : word_vector;
signal data : word_vector;

constant zero : std_logic_vector(15 downto 0) := "0000000000000000";
constant high_z : std_logic_vector(15 downto 0) := "ZZZZZZZZZZZZZZZZ";

begin
    loop_state_num <= std_logic_vector(to_unsigned(loop_state, 4));
    with big_state select
        big_state_num <=    "0000" when r_uart, 
                            "0001" when w_mem1,
                            "0010" when r_mem1,
                            "0011" when w_mem2,
                            "0100" when r_mem2,
                            "0101" when w_uart;
    dispDecoder0 : dispDecoder port map(big_state_num, dispNum1);
    dispDecoder1 : dispDecoder port map(loop_state_num, dispNum0);

    process (clk, rst)
    begin
        if rst = '0' then
            --reset state
            big_state <= r_uart;
            loop_state <= 0;
            ram1_en <= '1';
            ram1_oe <= '1';
            ram1_we <= '1';
            big_state <= r_uart;
            read_state <= r0;
            write_state <= w0;
            --clean up data
            ram1_addr <= zero;
            ram1_data <= zero;
            ram2_data <= zero;
            ram2_addr <= zero;
            -- ram1_en <= '1';
            -- ram1_we <= '0';
            -- ram1_oe <= '0';
            -- ram2_en <= '1';
            -- ram2_we <= '0';
            -- ram2_oe <= '0';
            led <= zero;
        elsif falling_edge(clk) then
            case big_state is
                when r_uart =>
                    case read_state is
                        when r0 =>
                            rdn <= '0';
                            read_state <= r1;
                            led <= "0000000000000001";
                        when r1 =>
                            rdn <= '1';
                            ram1_data <= high_z;
                            read_state <= r2;
                            led <= "0000000000000010";
                        when r2 =>
                            if data_ready = '1' then
                                rdn <= '0';
                                read_state <= r3;
                            elsif data_ready = '0' then
                                read_state <= r1;
                            end if;
                            led <= "0000000000000100";
                        when r3 =>
                            case loop_state is
                                    when 0 =>
                                        address(0)(15 downto 8) <= ram1_data(7 downto 0);
                                        loop_state <= loop_state + 1;
                                    when 1 => 
                                        address(0)(7 downto 0) <= ram1_data(7 downto 0);
                                        loop_state <= loop_state + 1;
                                    when 2 =>
                                        address(0)(15 downto 8) <= ram1_data(7 downto 0);
                                        loop_state <= loop_state + 1;
                                    when 3 => 
                                        address(0)(7 downto 0) <= ram1_data(7 downto 0);
                                        --set control ram1 control signal
                                        ram1_en <= '0';
                                        ram1_we <= '1';
                                        ram1_oe <= '1';
                                        --close uart
                                        rdn <= '1';
                                        wrn <= '1';
                                        --state change
                                        loop_state <= 0;
                                        big_state <= w_mem1;
                                    when others => null;
                            end case;
                            led <= ram1_data;
                            read_state <= r1;
                            --led <= "0000000000001000";
                    end case;
                -- when r_addr =>
                --     --read address from switches
                --     address(0) <= sw;
                --     led <= sw;
                --     --state change
                --     big_state <= r_data;
                -- when r_data =>
                --     --read data from switches
                --     data(0) <= sw;
                --     led <= sw;
                --     --set control ram1 control signal
                --     ram1_en <= '0';
                --     ram1_we <= '1';
                --     ram1_oe <= '1';
                --     --state change
                --     big_state <= w_mem1;
                --     loop_state <= 0;
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
                        big_state <= w_mem1;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        big_state <= r_mem1;
                    end if;
                when r_mem1 =>
                    ram1_en <= '0';
                    ram1_oe <= '0';
                    ram1_we <= '1';
                    ram1_data <= high_z;
					ram1_addr <= address(loop_state);
					led <= ram1_data;

                    --state change
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        big_state <= r_mem1;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        big_state <= w_mem2;
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
                        big_state <= w_mem2;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        big_state <= r_mem2;
                    end if;
                when r_mem2 =>
                    ram2_en <= '0';
                    ram2_we <= '1';
                    ram2_oe <= '0';
                    ram2_data <= high_z;
                    ram2_addr(15 downto 0) <= address(loop_state);
                    led <= ram2_data;
                    if loop_state < 9 then
                        loop_state <= loop_state + 1;
                        big_state <= r_mem2;
                    elsif loop_state = 9 then
                        loop_state <= 0;
                        big_state <= w_uart;
                    end if;
                when w_uart =>
                    --close ram1
                    ram1_en <= '1';
                    ram1_oe <= '1';
                    ram1_we <= '1';
                    case write_state is
                        when w0 =>
                            wrn <= '1';
                            write_state <= w1;
                        when w1 =>
                            wrn <= '0';
                            case loop_state is
                                when 0 => ram1_data(7 downto 0) <= ram2_data(15 downto 8);
                                when 1 => ram1_data(7 downto 0) <= ram2_data(7 downto 0);
                                when others => null;
                            end case;
                            write_state <= w2;
                        when w2 =>
                            wrn <= '1';
                            write_state <= w3;
                        when w3 =>
                            if tbre = '1' then
                                write_state <= w4;
                            end if;
                        when w4 =>
                            if tsre = '1' then
                            case loop_state is
                                when 0 => write_state <= w0;
                                when 1 => write_state <= w5;
                                when others => null;
                            end case;
                                loop_state <= loop_state + 1;
                            end if;
                        when w5 => null;
                    end case;
            end case;
        end if;
    end process;
end Behavioral;
