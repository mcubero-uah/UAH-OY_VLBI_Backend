


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

entity tlast_gen is
	generic(
		TDATA_WIDTH    : positive := 8;
		MAX_PKT_LENGTH : integer  := 256);
	Port (
		-- Clocks and reset
		clk : in std_logic;
		rst : in std_logic;
		-- Control signals
		pkt_length : in std_logic_vector(clog2(MAX_PKT_LENGTH)-1 downto 0);
		-- Slave interface
		s_axis_tvalid : in  std_logic;
		s_axis_tready : out std_logic;
		s_axis_tdata  : in  std_logic_vector (TDATA_WIDTH-1 downto 0);
		-- Master interface
		m_axis_tvalid : out std_logic;
		m_axis_tready : in  std_logic;
		m_axis_tdata  : out std_logic_vector (TDATA_WIDTH-1 downto 0);
		m_axis_tlast  : out std_logic
	);
end tlast_gen;

architecture Behavioral of tlast_gen is

	-- Internal signals
	signal new_sample      : std_logic;
	signal cnt             : unsigned (clog2(MAX_PKT_LENGTH)-1 downto 0);
	signal s_axis_tready_i : std_logic;
	signal m_axis_tlast_i  : std_logic;

begin

	s_axis_tready <= s_axis_tready_i;
	m_axis_tlast  <= m_axis_tlast_i;

	-- Pass through control signals
	s_axis_tready_i <= m_axis_tready;
	m_axis_tvalid   <= s_axis_tvalid;
	m_axis_tdata    <= s_axis_tdata;

	-- Count samples

	new_sample <= s_axis_tvalid and s_axis_tready_i;

	counter : process (clk)
	begin
		if clk'event and clk='1' then
			if (rst='1' or (m_axis_tlast_i='1' and new_sample='1')) then
				cnt <= (others => '0');
			else
				if (new_sample='1') then
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process counter;

	-- Generate tlast
	m_axis_tlast_i <= '1' when (cnt= unsigned(pkt_length)-1) else '0';

end Behavioral;
