
--------------------------------------------------------------------------------
-- Company: <Company Name>
-- Engineer: Miguel Cubero
--
-- Create Date: <date>
-- Design Name: <name_of_top-level_design>
-- Component Name: monostable
-- Target Device: <target device>
-- Tool versions: <tool_versions>
-- Description:
--    Retriggerable monostable
-- Dependencies:
--    <Dependencies here>
-- Revision:
--    <Code_revision_information>
-- Additional Comments:
--    <Additional_comments>
--------------------------------------------------------------------------------
			
			
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity monostable is
    Port (
        pulse_length : in  std_logic_vector(15 downto 0);
        clk          : in  STD_LOGIC;
        din          : in  std_logic;
        dout         : out std_logic
    );
end monostable;

architecture Behavioral of monostable is

    signal pulse_cnt  : unsigned(15 downto 0);

begin
    ----------------------------------------------------------------------------------
    -- Monostable 
    ----------------------------------------------------------------------------------

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if (din = '1') then
                pulse_cnt <= unsigned(pulse_length);
            else
                pulse_cnt <= pulse_cnt - 1;
                if (pulse_cnt=0) then
                    pulse_cnt <=(others => '0');
                end if;
            end if;
        end if;
    end process;
    
    dout <= '1' when (pulse_cnt>0) else '0';

end Behavioral;
