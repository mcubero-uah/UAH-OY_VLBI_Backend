----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2023 19:14:11
-- Design Name: 
-- Module Name: input_buff - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity input_buff is
    Port ( DCO_p_in : in STD_LOGIC;
        DCO_n_in : in  STD_LOGIC;
        D_p_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        D_n_in   : in  STD_LOGIC_VECTOR(7 downto 0);
        DCO      : out STD_LOGIC;
        D_out    : out STD_LOGIC_VECTOR (7 downto 0));
end input_buff;

architecture Behavioral of input_buff is

begin

    Ibufgds_BitClk : IBUFGDS
        generic map (DIFF_TERM => TRUE, IOSTANDARD => "LVDS_25")
        port map (I            => DCO_p_in, IB => DCO_n_in, O => DCO);

    DATA_IBUF_GEN : for i in 0 to 7 generate

        IBUFDS_data_B2_I : IBUFDS
            generic map (
                DIFF_TERM    => TRUE, -- Differential Termination
                IBUF_LOW_PWR => TRUE,  -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
                IOSTANDARD   => "LVDS_25")
            port map (
                O  => D_out(i),  -- Buffer output
                I  => D_p_in(i), -- Diff_p buffer input (connect directly to top-level port)
                IB => D_n_in(i)  -- Diff_n buffer input (connect directly to top-level port)
            );

    end generate DATA_IBUF_GEN;

end Behavioral;
