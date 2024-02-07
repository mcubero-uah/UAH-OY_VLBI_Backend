----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2023 12:26:10
-- Design Name: 
-- Module Name: data_conditioner - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_conditioner is
    Port ( din : in STD_LOGIC_VECTOR (15 downto 0);
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        dout     : out STD_LOGIC_VECTOR (1 downto 0);
        dout_vld : out STD_LOGIC);
end data_conditioner;

architecture Behavioral of data_conditioner is
    signal dvld_1 : std_logic;
    signal dvld_2 : std_logic;
begin

    -- Input data clippling
    dout <= din (15 downto 14);

    -- 3-stage FF to generate valid data flag

    VLD_FF : process (clk, rst)
    begin
        if clk'event and clk='1' then
            if (rst = '1') then
                dout_vld <= '0';
                dvld_1   <= '0';
                dvld_2   <= '0';
            else
                dvld_1   <= '1';
                dvld_2   <= dvld_1;
                dout_vld <= dvld_2;
            end if;

        end if;
    end process VLD_FF;

end Behavioral;
