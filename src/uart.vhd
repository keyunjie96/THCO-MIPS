----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:06:24 11/03/2016 
-- Design Name: 
-- Module Name:    uart - Behavioral 
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

entity uart is
    Port ( clk : in  STD_LOGIC; 
           rst : in  STD_LOGIC; 
           send_data : in  STD_LOGIC_VECTOR (7 downto 0); --*
           data_ready : in  STD_LOGIC;
           send_data_complete : out STD_LOGIC;
           receive_data_complete : out STD_LOGIC;
           tbre : in  STD_LOGIC;
           tsre : in  STD_LOGIC;
           receive_data : out  STD_LOGIC_VECTOR (7 downto 0); --*
           en1 : in STD_LOGIC; --*1写串口，0读串口；平常默认读串口
           en2 : in STD_LOGIC; --*1串口打开，可以一直打开
           en3 : in STD_LOGIC; --*读取数据时，把它置1；
        --    state_show : out STD_LOGIC_VECTOR(7 downto 0);
           ram1oe : out  STD_LOGIC;
           ram1we : out  STD_LOGIC;
           ram1en : out  STD_LOGIC;
           rdn : out  STD_LOGIC;
           wrn : out  STD_LOGIC;
           ram1data : inout  STD_LOGIC_VECTOR (7 downto 0));
end uart;

architecture Behavioral of uart is
------------------信号声明------------------------
type big_state_machine is (read_uart, write_uart); 
type read_state_machine is (r0, r1, r2, r3);
type write_state_machine is (w0, w1, w2, w3, w4, w5);
signal big_state : big_state_machine;
signal read_state : read_state_machine;
signal write_state : write_state_machine;

begin
process(en3, rst, read_state)
begin
    if en3 = '1' or rst = '0' then
        receive_data_complete <= '0';
    elsif read_state = r3 then
        receive_data_complete <= '1';
    end if;
end process;

process(rst, clk) is
begin
    -- send_data_complete <= '1';
    -- receive_data_complete <= '1';
    if rst = '0' then
        send_data_complete <= '1';
        ram1en <= '1';
        ram1oe <= '1';
        ram1we <= '1';
        if en1 = '0' then
            big_state <= read_uart;
            read_state <= r0;
            -- state_show(5 downto 0) <= "000000";
        elsif en1 = '1' then
            big_state <= write_uart;
            write_state <= w0;
            -- state_show(5 downto 0) <= "100000";
        end if;
    elsif falling_edge(clk) and en2 = '1' then
        if en1 = '1' then -- 只切换到写状态，平常都是读
            big_state <= write_uart;
            if big_state = read_uart then
                write_state <= w0;
            end if;
            -- state_show(5 downto 0) <= "100000";
        end if;
        -- if en3 = '1' and read_state = r1 then --要读取数据时，进入下一个信号
        --     read_state <= r2;
        -- end if;
        if big_state = read_uart then
            case read_state is
                when r0 =>
                    rdn <= '0';
                    read_state <= r1;
                    -- state_show(4 downto 0) <= "10000";
                when r1 =>
                    rdn <= '1';
                    ram1data <= "ZZZZZZZZ";
                    read_state <= r2;
                    -- state_show(4 downto 0) <= "01000";
                when r2 =>
                    if data_ready = '1' then
                        rdn <= '0';
                        read_state <= r3;
                    elsif data_ready = '0' then
                        read_state <= r1;
                    end if;
                    -- state_show(4 downto 0) <= "00100";
                when r3 =>
                    receive_data <= ram1data;
                    read_state <= r1;
                    -- state_show(4 downto 0) <= "00010";
                    -- receive_data_complete <= '1';
            end case;
        elsif big_state = write_uart then 
            case write_state is
                when w0 =>
                    wrn <= '1';
                    write_state <= w1;
                    -- state_show(4 downto 0) <= "10000";
                    send_data_complete <= '0';
                when w1 =>
                    wrn <= '0';
                    ram1data <= send_data;
                    write_state <= w2;
                    -- state_show(4 downto 0) <= "01000";
                when w2 =>
                    wrn <= '1';
                    write_state <= w3;
                    -- state_show(4 downto 0) <= "00100";
                when w3 =>
                    if tbre = '1' then
                        write_state <= w4;
                        -- state_show(4 downto 0) <= "00010";
                    end if;
                when w4 =>
                    if tsre = '1' then 
                        big_state <= read_uart;
                        read_state <= r0;
                        -- state_show(4 downto 0) <= "00001";
                        send_data_complete <= '1';
                        -- send_data_complete <= '1';
                    end if;
                when w5 => null;
            end case;
        end if;
    end if;
end process;
end Behavioral;

