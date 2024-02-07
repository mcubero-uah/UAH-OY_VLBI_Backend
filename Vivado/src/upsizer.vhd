----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.05.2023 15:09:08
-- Design Name: 
-- Module Name: upsizer - Behavioral
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

entity upsizer is
    Port ( din : in STD_LOGIC_VECTOR (1 downto 0);
        din_vld       : in  STD_LOGIC;
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        M_AXIS_TDATA  : out STD_LOGIC_VECTOR (31 downto 0);
        M_AXIS_TVALID : out STD_LOGIC);
end upsizer;

architecture Behavioral of upsizer is

    constant DIN_WIDTH    : integer := din'length;
    constant DOUT_WIDTH   : integer := M_AXIS_TDATA'length;
    constant DWIDTH_RATIO : integer := DOUT_WIDTH/DIN_WIDTH;

    signal byte_sel  : std_logic_vector(DWIDTH_RATIO-1 downto 0);
    signal last_byte : std_logic;

begin

    -- Byte selection signal generation (circular left shift register)
    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(rst = '1') then
                byte_sel    <= (others => '0');
                byte_sel(0) <= '1';
            else
                if(din_vld = '1') then
                    byte_sel <= byte_sel(DWIDTH_RATIO-2 downto 0) & byte_sel(DWIDTH_RATIO-1); -- Circular left shift
                end if;
            end if;
        end if;
    end process;

    -- Packing register:
    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(din_vld = '1') then
                for i in 0 to DWIDTH_RATIO-1 loop
                    if(byte_sel(i) = '1') then
                        M_AXIS_TDATA(DIN_WIDTH*(i+1)-1 downto DIN_WIDTH*i) <= din;
                    end if;
                end loop;
            end if;
        end if;
    end process;

    -- Output valid data
    last_byte <= byte_sel(DWIDTH_RATIO-1);

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(rst = '1') then
                M_AXIS_TVALID <= '0';
            else
                M_AXIS_TVALID <= din_vld and last_byte;
            end if;
        end if;
    end process;

end Behavioral;
