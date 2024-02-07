library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-- Revision:
--   v1.1 (23/06/2023)
-- Changed Destiny clock times source clock constant by parameter (generic)
--
--   v1.2 (24/06/2023)
-- Changed plain VHDL 2-stage synchronizers by XPM synchronizers to avoid timing warnings
--
-- v2.0 (30/06/2023)
-- Added logic to implement Data frame number reset when new second from epoch
-- (Previously was incorrectly keeping counting
--------------------------------------------------------------------------------
			
			

entity vdif_formatter_v1_0 is
	generic (
		-- Users to add parameters here
        DST_CLK_TIMES_SRC_CLK : INTEGER := 2;
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH : integer := 32;
		C_S_AXI_ADDR_WIDTH : integer := 6
	);
	port (
		-- Users to add ports here
		adc_rst        : out std_logic;
		-- FIFO input AXI4-Stream slave interface
        S_AXIS_TDATA   : in  std_logic_vector(31 downto 0);
        S_AXIS_TVALID  : in  std_logic;
        S_AXIS_TREADY  : out std_logic;
        S_AXIS_ACLK    : in  std_logic;
        -- Output AXI4-Stream master interface
        M_AXIS_TDATA   : out std_logic_vector(31 downto 0);
        M_AXIS_TVALID  : out std_logic;
        M_AXIS_TREADY  : in  std_logic;
        M_AXIS_TLAST   : out std_logic;
		-- PPS Input
		digital_pps_in : in std_logic;        
        -- Seconds from epoch input
        Sec_from_epoch : in  std_logic_vector(29 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI
		s_axi_aclk    : in  std_logic;
		s_axi_aresetn : in  std_logic;
		s_axi_awaddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awprot  : in  std_logic_vector(2 downto 0);
		s_axi_awvalid : in  std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_wstrb   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		s_axi_wvalid  : in  std_logic;
		s_axi_wready  : out std_logic;
		s_axi_bresp   : out std_logic_vector(1 downto 0);
		s_axi_bvalid  : out std_logic;
		s_axi_bready  : in  std_logic;
		s_axi_araddr  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arprot  : in  std_logic_vector(2 downto 0);
		s_axi_arvalid : in  std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		s_axi_rresp   : out std_logic_vector(1 downto 0);
		s_axi_rvalid  : out std_logic;
		s_axi_rready  : in  std_logic
	);
end vdif_formatter_v1_0;

architecture arch_imp of vdif_formatter_v1_0 is

	-- component declaration
	component vdif_formatter_v1_0_S_AXI is
		generic (
		    DST_CLK_TIMES_SRC_CLK : INTEGER := 2;
			C_S_AXI_DATA_WIDTH : integer := 32;
			C_S_AXI_ADDR_WIDTH : integer := 6
		);
		port (
			adc_rst        : out std_logic;
			S_AXIS_TDATA   : in  std_logic_vector(31 downto 0);
			S_AXIS_TVALID  : in  std_logic;
			S_AXIS_TREADY  : out std_logic;
			S_AXIS_ACLK    : in  std_logic;
			M_AXIS_TDATA   : out std_logic_vector(31 downto 0);
			M_AXIS_TVALID  : out std_logic;
			M_AXIS_TREADY  : in  std_logic;
			M_AXIS_TLAST   : out std_logic;
			digital_pps_in : in std_logic;			
			Sec_from_epoch : in  std_logic_vector(29 downto 0);
			S_AXI_ACLK     : in  std_logic;
			S_AXI_ARESETN  : in  std_logic;
			S_AXI_AWADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
			S_AXI_AWVALID  : in  std_logic;
			S_AXI_AWREADY  : out std_logic;
			S_AXI_WDATA    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_WSTRB    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
			S_AXI_WVALID   : in  std_logic;
			S_AXI_WREADY   : out std_logic;
			S_AXI_BRESP    : out std_logic_vector(1 downto 0);
			S_AXI_BVALID   : out std_logic;
			S_AXI_BREADY   : in  std_logic;
			S_AXI_ARADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
			S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
			S_AXI_ARVALID  : in  std_logic;
			S_AXI_ARREADY  : out std_logic;
			S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
			S_AXI_RRESP    : out std_logic_vector(1 downto 0);
			S_AXI_RVALID   : out std_logic;
			S_AXI_RREADY   : in  std_logic
		);
	end component vdif_formatter_v1_0_S_AXI;

begin

	-- Instantiation of Axi Bus Interface S_AXI
	vdif_formatter_v1_0_S_AXI_inst : vdif_formatter_v1_0_S_AXI
		generic map (
		    DST_CLK_TIMES_SRC_CLK => DST_CLK_TIMES_SRC_CLK,
			C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
			C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
		)
		port map (
			adc_rst        => adc_rst,
			S_AXIS_TDATA   => S_AXIS_TDATA,
			S_AXIS_TVALID  => S_AXIS_TVALID,
			S_AXIS_TREADY  => S_AXIS_TREADY,
			S_AXIS_ACLK    => S_AXIS_ACLK,
			M_AXIS_TDATA   => M_AXIS_TDATA,
			M_AXIS_TVALID  => M_AXIS_TVALID,
			M_AXIS_TREADY  => M_AXIS_TREADY,
			M_AXIS_TLAST   => M_AXIS_TLAST,
			digital_pps_in => digital_pps_in,
			Sec_from_epoch => Sec_from_epoch,
			--		
			S_AXI_ACLK    => s_axi_aclk,
			S_AXI_ARESETN => s_axi_aresetn,
			S_AXI_AWADDR  => s_axi_awaddr,
			S_AXI_AWPROT  => s_axi_awprot,
			S_AXI_AWVALID => s_axi_awvalid,
			S_AXI_AWREADY => s_axi_awready,
			S_AXI_WDATA   => s_axi_wdata,
			S_AXI_WSTRB   => s_axi_wstrb,
			S_AXI_WVALID  => s_axi_wvalid,
			S_AXI_WREADY  => s_axi_wready,
			S_AXI_BRESP   => s_axi_bresp,
			S_AXI_BVALID  => s_axi_bvalid,
			S_AXI_BREADY  => s_axi_bready,
			S_AXI_ARADDR  => s_axi_araddr,
			S_AXI_ARPROT  => s_axi_arprot,
			S_AXI_ARVALID => s_axi_arvalid,
			S_AXI_ARREADY => s_axi_arready,
			S_AXI_RDATA   => s_axi_rdata,
			S_AXI_RRESP   => s_axi_rresp,
			S_AXI_RVALID  => s_axi_rvalid,
			S_AXI_RREADY  => s_axi_rready
		);

	-- Add user logic here

	-- User logic ends

end arch_imp;
