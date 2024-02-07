----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.05.2023 12:18:41
-- Design Name: 
-- Module Name: native_to_axis_converter - Behavioral
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

entity native_to_axis_converter is
    Port ( din : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           M_AXIS_TDATA : out STD_LOGIC_VECTOR (31 downto 0);
           M_AXIS_TVALID : out STD_LOGIC);
end native_to_axis_converter;

architecture Behavioral of native_to_axis_converter is

    component data_conditioner is
        port (
            din      : in  STD_LOGIC_VECTOR (15 downto 0);
            clk      : in  STD_LOGIC;
            rst      : in  STD_LOGIC;
            dout     : out STD_LOGIC_VECTOR (1 downto 0);
            dout_vld : out STD_LOGIC
        );
    end component data_conditioner;

    component upsizer is
        port (
            din           : in  STD_LOGIC_VECTOR (1 downto 0);
            din_vld       : in  STD_LOGIC;
            clk           : in  STD_LOGIC;
            rst           : in  STD_LOGIC;
            M_AXIS_TDATA  : out STD_LOGIC_VECTOR (31 downto 0);
            M_AXIS_TVALID : out STD_LOGIC
        );
    end component upsizer;

    signal data_i : std_logic_vector (1 downto 0);    
    signal data_vld : std_logic;

begin

    data_conditioner_1 : entity work.data_conditioner
        port map (
            din      => din,
            clk      => clk,
            rst      => rst,
            dout     => data_i,
            dout_vld => data_vld
        );

    upsizer_1 : entity work.upsizer
        port map (
            din           => data_i,
            din_vld       => data_vld,
            clk           => clk,
            rst           => rst,
            M_AXIS_TDATA  => M_AXIS_TDATA,
            M_AXIS_TVALID => M_AXIS_TVALID
        );        

end Behavioral;
