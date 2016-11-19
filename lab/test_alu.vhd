--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:30:42 10/19/2016
-- Design Name:   
-- Module Name:   C:/Users/keyun/Documents/Code/cpu/test_alu.vhd
-- Project Name:  cpu
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
ENTITY test_alu IS
END test_alu;
 
ARCHITECTURE behavior OF test_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         rst : IN  std_logic;
         clk : IN  std_logic;
         sw : IN  std_logic_vector(15 downto 0);
         fout : OUT  std_logic_vector(15 downto 0);
         flag : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';
   signal sw : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal fout : std_logic_vector(15 downto 0);
   signal flag : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          rst => rst,
          clk => clk,
          sw => sw,
          fout => fout,
          flag => flag
        );

   -- Clock process definitions
   clk_process :process
   begin
    rst <= '0';
    wait for clk_period/2;
    rst <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    sw <= "0100010000000000";
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
    sw <= "0000000011000000";
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
