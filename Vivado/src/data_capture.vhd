----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2023 19:22:34
-- Design Name: 
-- Module Name: data_capture - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity data_capture is
    Port ( din : in STD_LOGIC_VECTOR (7 downto 0);
        rst  : in  std_logic;
        clk  : in  std_logic;
        dout : out STD_LOGIC_VECTOR (15 downto 0));
end data_capture;

architecture Behavioral of data_capture is

    signal dat_even : STD_LOGIC_VECTOR (7 downto 0);
    signal dat_odd  : STD_LOGIC_VECTOR (7 downto 0);
    signal dat_odd_d : STD_LOGIC_VECTOR (7 downto 0);

begin

    IDDR_FF_GEN : for n in 0 to 7 generate
    begin
        IDDR_n : IDDR
            generic map (
                DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE"
                                                       -- or "SAME_EDGE_PIPELINED"
                INIT_Q1 => '0',                        -- Initial value of Q1: '0' or '1'
                INIT_Q2 => '0',                        -- Initial value of Q2: '0' or '1'
                SRTYPE  => "SYNC")                     -- Set/Reset type: "SYNC" or "ASYNC"
            port map (
                Q1 => dat_even(n), -- 1-bit output for positive edge of clock
                Q2 => dat_odd(n),  -- 1-bit output for negative edge of clock
                C  => clk,         -- 1-bit clock input
                CE => '1',         -- 1-bit clock enable input
                D  => din(n),      -- 1-bit DDR data input
                R  => rst,         -- 1-bit reset
                S  => '0'          -- 1-bit set
            );
        -- End of IDDR_n instantiation
        
  dat_odd_ff_n : FDRE
         generic map (
            INIT => '0') -- Initial value of register ('0' or '1')  
         port map (
            Q => dat_odd_d(n),      -- Data output
            C => clk,      -- Clock input
            CE => '1',    -- Clock enable input
            R => rst,      -- Synchronous reset input
            D => dat_odd(n)       -- Data input
         );           

        dout(n*2)   <= dat_even(n);
        dout(n*2+1) <= dat_odd_d(n);
        
    end generate IDDR_FF_GEN;

 

end Behavioral;
