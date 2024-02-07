----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.06.2023 17:46:40
-- Design Name: 
-- Module Name: sync - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision v.0. 1 - File Created
-- Revision v.0. 2 - Added digital pps output
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.lib_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity onepps_gen is
	generic (
		duty_cycle : integer := 30;
		period     : integer := 100
	);
	port (
		clk        : in  STD_LOGIC;
		onepps_out : out STD_LOGIC
	);
end entity onepps_gen;

architecture Behavioral of onepps_gen is

	signal period_end : std_logic;
	signal carrier    : unsigned (clog2(period)-1 downto 0);

begin

	cnt : process (clk)
	begin
		if (clk'event and clk='1') then
			if (period_end='1') then
				carrier <= (others => '0');
			else
				carrier <= carrier + 1;
			end if;
		end if;
	end process cnt;

	period_end  <= '1' when (carrier=to_unsigned(period,carrier'length)) else '0';

	pps_generation : process (clk)
	begin
		if (clk'event and clk='1') then
			if (carrier < to_unsigned(duty_cycle,carrier'length)) then
				onepps_out  <= '1';
			else
				onepps_out  <= '0';
			end if;
		end if;
	end process pps_generation;

end Behavioral;
