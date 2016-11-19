--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:47:06 11/04/2016
-- Design Name:   
-- Module Name:   E:/Study/xilinx/THCO-MIPS/test_mem_ctl.vhd
-- Project Name:  THCO-MIPS
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mem_ctl
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_mem_ctl IS
END test_mem_ctl;
 
ARCHITECTURE behavior OF test_mem_ctl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mem_ctl
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         sw : IN  std_logic_vector(15 downto 0);
         ram1_oe : OUT  std_logic;
         ram1_we : OUT  std_logic;
         ram1_en : OUT  std_logic;
         ram1_addr : OUT  std_logic_vector(15 downto 0);
         ram1_data : INOUT  std_logic_vector(15 downto 0);
         ram2_oe : OUT  std_logic;
         ram2_we : OUT  std_logic;
         ram2_en : OUT  std_logic;
         ram2_addr : OUT  std_logic_vector(15 downto 0);
         ram2_data : INOUT  std_logic_vector(15 downto 0);
         led : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal sw : std_logic_vector(15 downto 0) := (others => '0');

	--BiDirs
   signal ram1_data : std_logic_vector(15 downto 0);
   signal ram2_data : std_logic_vector(15 downto 0);

 	--Outputs
   signal ram1_oe : std_logic;
   signal ram1_we : std_logic;
   signal ram1_en : std_logic;
   signal ram1_addr : std_logic_vector(15 downto 0);
   signal ram2_oe : std_logic;
   signal ram2_we : std_logic;
   signal ram2_en : std_logic;
   signal ram2_addr : std_logic_vector(15 downto 0);
   signal led : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mem_ctl PORT MAP (
          rst => rst,
          clk => clk,
          sw => sw,
          ram1_oe => ram1_oe,
          ram1_we => ram1_we,
          ram1_en => ram1_en,
          ram1_addr => ram1_addr,
          ram1_data => ram1_data,
          ram2_oe => ram2_oe,
          ram2_we => ram2_we,
          ram2_en => ram2_en,
          ram2_addr => ram2_addr,
          ram2_data => ram2_data,
          led => led
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '0';
      wait for 5 ns;
		rst <= '1';
		sw <= "0000000010000000";
		wait for 6 ns;
		sw <= "0000000000010000";
		wait for 10 ns;

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
