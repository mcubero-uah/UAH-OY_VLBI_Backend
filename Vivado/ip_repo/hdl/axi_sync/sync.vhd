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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;

entity sync is
    Port ( onepps_in : in STD_LOGIC;
        clk                : in  STD_LOGIC;
        sclr               : in  STD_LOGIC;
        load               : in  STD_LOGIC;
        time_load          : in  STD_LOGIC_VECTOR (29 downto 0);
        seconds_from_epoch : out STD_LOGIC_VECTOR (29 downto 0);
        digital_pps_out    : out STD_LOGIC
        );
end sync;

architecture Behavioral of sync is

    signal onepps_r_2 : STD_LOGIC;

    signal onepps_r_3 : STD_LOGIC;
    signal onepps_RE  : STD_LOGIC;
    signal cnt        : unsigned (29 downto 0);
    signal cnt_ce     : STD_LOGIC;
begin

    --------------------------------------------------------------------------------
    -- 2-stage synchronizer
    --------------------------------------------------------------------------------
    synchronizer_ffs : xpm_cdc_sync_rst
        generic map (
            DEST_SYNC_FF => 2,   -- DECIMAL; range: 2-10
            INIT         => 1,   -- DECIMAL; 0=initialize synchronization registers to 0, 1=initialize
                                 -- synchronization registers to 1
            INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
            SIM_ASSERT_CHK => 0  -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        )
        port map (
            dest_rst => onepps_r_2,     -- 1-bit output: src_rst synchronized to the destination clock domain. This output
                                      -- is registered.
            dest_clk => clk,  -- 1-bit input: Destination clock.
            src_rst  => onepps_in -- 1-bit input: Source reset signal.
        );       


    --------------------------------------------------------------------------------
    -- Rising edge detector
    --------------------------------------------------------------------------------

    R_edge_detector_ff : process (clk)
    begin
        if clk'event and clk='1' then
            onepps_r_3 <= onepps_r_2;
        end if;
    end process R_edge_detector_ff;

    onepps_RE <= onepps_r_2 and not onepps_r_3;

    --------------------------------------------------------------------------------
    -- Up counter
    --------------------------------------------------------------------------------
    digital_pps_out    <= onepps_RE;
    cnt_ce             <= onepps_RE;
    seconds_from_epoch <= std_logic_vector(cnt);

    count : process (clk)
    begin
        if clk'event and clk='1' then
            if (sclr = '1') then
                cnt <= (others => '0');
            elsif (load='1') then
                cnt <= unsigned(time_load);
            elsif(cnt_ce='1') then
                cnt <= cnt+1;
            end if;
        end if;
    end process count;
end Behavioral;
