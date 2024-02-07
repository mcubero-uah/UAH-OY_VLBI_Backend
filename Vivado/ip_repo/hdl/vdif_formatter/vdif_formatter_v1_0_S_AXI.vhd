library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lib_pkg.all;

Library xpm;
use xpm.vcomponents.all;

entity vdif_formatter_v1_0_S_AXI is
	generic (
		-- Users to add parameters here
		DST_CLK_TIMES_SRC_CLK : INTEGER := 2;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH : integer := 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH : integer := 6
	);
	port (
		-- Users to add ports here
		adc_rst : out std_logic;

		-- Input AXIS slave interface		
		S_AXIS_TDATA  : in  std_logic_vector(31 downto 0);
		S_AXIS_TVALID : in  std_logic;
		S_AXIS_TREADY : out std_logic;
		S_AXIS_ACLK   : in  std_logic;
		-- Output AXIS master interface
		M_AXIS_TDATA  : out std_logic_vector(31 downto 0);
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TREADY : in  std_logic;
		M_AXIS_TLAST  : out std_logic;
		-- PPS Input
		digital_pps_in : in std_logic;		
		-- VDIF inputs
		Sec_from_epoch : in std_logic_vector(29 downto 0); -- Word 0 Seconds from reference epoch
		                                                   -- User ports ends
		                                                   -- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK : in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN : in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
		-- privilege and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT : in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
		-- valid write address and control information.
		S_AXI_AWVALID : in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
		-- to accept an address and associated control signals.
		S_AXI_AWREADY : out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
		-- valid data. There is one write strobe bit for each eight
		-- bits of the write data bus.    
		S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
		-- data and strobes are available.
		S_AXI_WVALID : in std_logic;
		-- Write ready. This signal indicates that the slave
		-- can accept the write data.
		S_AXI_WREADY : out std_logic;
		-- Write response. This signal indicates the status
		-- of the write transaction.
		S_AXI_BRESP : out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
		-- is signaling a valid write response.
		S_AXI_BVALID : out std_logic;
		-- Response ready. This signal indicates that the master
		-- can accept a write response.
		S_AXI_BREADY : in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether the
		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT : in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
		-- is signaling valid read address and control information.
		S_AXI_ARVALID : in std_logic;
		-- Read address ready. This signal indicates that the slave is
		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY : out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
		-- read transfer.
		S_AXI_RRESP : out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
		-- signaling the required read data.
		S_AXI_RVALID : out std_logic;
		-- Read ready. This signal indicates that the master can
		-- accept the read data and response information.
		S_AXI_RREADY : in std_logic
	);
end vdif_formatter_v1_0_S_AXI;

architecture arch_imp of vdif_formatter_v1_0_S_AXI is

	-- AXI4LITE signals
	signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready : std_logic;
	signal axi_wready  : std_logic;
	signal axi_bresp   : std_logic_vector(1 downto 0);
	signal axi_bvalid  : std_logic;
	signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready : std_logic;
	signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp   : std_logic_vector(1 downto 0);
	signal axi_rvalid  : std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 3;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 10
	signal slv_reg0     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9     : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_rden : std_logic;
	signal slv_reg_wren : std_logic;
	signal reg_data_out : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index   : integer;
	signal aw_en        : std_logic;

	signal adc_rst_i      : std_logic;
	signal rst_i              : std_logic;

	-- FIFO Memory signals
	signal FIFO_full     : std_logic;
	signal FIFO_empty    : std_logic;
	signal FIFO_rd_en    : std_logic;
	signal FIFO_wr_en    : std_logic;
	signal FIFO_S_tready : std_logic;
	signal FIFO_M_tvalid : std_logic;
	signal FIFO_M_tdata  : std_logic_vector(31 downto 0);
	signal FIFO_M_tready : std_logic;

	-- VDIF headers
	signal vdif_word0 : std_logic_vector(31 downto 0);
	signal vdif_word1 : std_logic_vector(31 downto 0);
	signal vdif_word2 : std_logic_vector(31 downto 0);
	signal vdif_word3 : std_logic_vector(31 downto 0);
	signal vdif_word4 : std_logic_vector(31 downto 0);
	signal vdif_word5 : std_logic_vector(31 downto 0);
	signal vdif_word6 : std_logic_vector(31 downto 0);
	signal vdif_word7 : std_logic_vector(31 downto 0);


	--------------------------------------------------------------------------------
	-- Components
	--------------------------------------------------------------------------------

	component monostable is
		port (
			pulse_length : in  std_logic_vector(15 downto 0);
			clk          : in  STD_LOGIC;
			din          : in  std_logic;
			dout         : out std_logic
		);
	end component monostable;

	COMPONENT fifo_generator_0
		PORT (
			rst    : IN  STD_LOGIC;
			wr_clk : IN  STD_LOGIC;
			rd_clk : IN  STD_LOGIC;
			din    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			wr_en  : IN  STD_LOGIC;
			rd_en  : IN  STD_LOGIC;
			dout   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			full   : OUT STD_LOGIC;
			empty  : OUT STD_LOGIC
		);
	END COMPONENT;

	component vdif_logic is
		port (
			rst            : in  std_logic;
			clk            : in  std_logic;
			S_AXIS_TDATA   : in  std_logic_vector(31 downto 0);
			S_AXIS_TVALID  : in  std_logic;
			S_AXIS_TREADY  : out std_logic;
			M_AXIS_TDATA   : out std_logic_vector(31 downto 0);
			M_AXIS_TVALID  : out std_logic;
			M_AXIS_TREADY  : in  std_logic;
			digital_pps_in : in  std_logic;
			EUD_W7         : in  std_logic_vector(31 downto 0);
			EUD_W6         : in  std_logic_vector(31 downto 0);
			EUD_W5         : in  std_logic_vector(31 downto 0);
			EUD_W4         : in  std_logic_vector(23 downto 0);
			EDV            : in  std_logic_vector(7 downto 0);
			Station_ID     : in  std_logic_vector(15 downto 0);
			Thread_ID      : in  std_logic_vector(9 downto 0);
			Bits_sample_1  : in  std_logic_vector(4 downto 0);
			Data_type      : in  std_logic;
			Frame_length   : in  std_logic_vector(23 downto 0);
			log2chns       : in  std_logic_vector(4 downto 0);
			VDIF_version   : in  std_logic_vector(2 downto 0);
			Ref_epoch      : in  std_logic_vector(5 downto 0);
			Unassigned     : in  std_logic_vector(1 downto 0);
			Sec_from_epoch : in  std_logic_vector(29 downto 0);
			Legacy_mode    : in  std_logic;
			Invalid_data   : in  std_logic;
			Frame_end      : out std_logic
		);
	end component vdif_logic;

begin
	-- I/O Connections assignments

	S_AXI_AWREADY <= axi_awready;
	S_AXI_WREADY  <= axi_wready;
	S_AXI_BRESP   <= axi_bresp;
	S_AXI_BVALID  <= axi_bvalid;
	S_AXI_ARREADY <= axi_arready;
	S_AXI_RDATA   <= axi_rdata;
	S_AXI_RRESP   <= axi_rresp;
	S_AXI_RVALID  <= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awready <= '0';
				aw_en       <= '1';
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
					-- slave is ready to accept write address when
					-- there is a valid write address and write data
					-- on the write address and data bus. This design 
					-- expects no outstanding transactions. 
					axi_awready <= '1';
				elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
					aw_en       <= '1';
					axi_awready <= '0';
				else
					axi_awready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_awaddr <= (others => '0');
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
					-- Write Address latching
					axi_awaddr <= S_AXI_AWADDR;
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_wready <= '0';
			else
				if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
					-- slave is ready to accept write data when 
					-- there is a valid write address and write data
					-- on the write address and data bus. This design 
					-- expects no outstanding transactions.           
					axi_wready <= '1';
				else
					axi_wready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
		variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				slv_reg0 <= (others => '0');
				slv_reg1 <= (others => '0');
				slv_reg2 <= (others => '0');
				slv_reg3 <= (others => '0');
				slv_reg4 <= (others => '0');
				slv_reg5 <= (others => '0');
				slv_reg6 <= (others => '0');
				slv_reg7 <= (others => '0');
				slv_reg8 <= (others => '0');
				slv_reg9 <= (others => '0');
			else
				loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
				if (slv_reg_wren = '1') then
					case loc_addr is
						when b"0000" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 0
									slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 1
									slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0010" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 2
									slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0011" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 3
									slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0100" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 4
									slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0101" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 5
									slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0110" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 6
									slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0111" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 7
									slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1000" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 8
									slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 9
									slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when others =>
							slv_reg0 <= slv_reg0;
							slv_reg1 <= slv_reg1;
							slv_reg2 <= slv_reg2;
							slv_reg3 <= slv_reg3;
							slv_reg4 <= slv_reg4;
							slv_reg5 <= slv_reg5;
							slv_reg6 <= slv_reg6;
							slv_reg7 <= slv_reg7;
							slv_reg8 <= slv_reg8;
							slv_reg9 <= slv_reg9;
					end case;
				end if;
			end if;
		end if;
	end process;

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_bvalid <= '0';
				axi_bresp  <= "00"; --need to work more on the responses
			else
				if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0' ) then
					axi_bvalid <= '1';
					axi_bresp  <= "00";
				elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then --check if bready is asserted while bvalid is high)
					axi_bvalid <= '0';                               -- (there is a possibility that bready is always asserted high)
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_arready <= '0';
				axi_araddr  <= (others => '1');
			else
				if (axi_arready = '0' and S_AXI_ARVALID = '1') then
					-- indicates that the slave has acceped the valid read address
					axi_arready <= '1';
					-- Read Address latching 
					axi_araddr <= S_AXI_ARADDR;
				else
					axi_arready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_rvalid <= '0';
				axi_rresp  <= "00";
			else
				if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
					-- Valid read data is available at the read data bus
					axi_rvalid <= '1';
					axi_rresp  <= "00"; -- 'OKAY' response
				elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
					-- Read data is accepted by the master
					axi_rvalid <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
		variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
	begin
		-- Address decoding for reading registers
		loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
		case loc_addr is
			when b"0000" =>
				reg_data_out <= slv_reg0;
			when b"0001" =>
				reg_data_out <= slv_reg1;
			when b"0010" =>
				reg_data_out <= slv_reg2;
			when b"0011" =>
				reg_data_out <= slv_reg3;
			when b"0100" =>
				reg_data_out <= slv_reg4;
			when b"0101" =>
				reg_data_out <= slv_reg5;
			when b"0110" =>
				reg_data_out <= slv_reg6;
			when b"0111" =>
				reg_data_out <= slv_reg7;
			when b"1000" =>
				reg_data_out <= slv_reg8;
			when b"1001" =>
				reg_data_out <= slv_reg9;
			when others =>
				reg_data_out <= (others => '0');
		end case;
	end process;

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
		if (rising_edge (S_AXI_ACLK)) then
			if ( S_AXI_ARESETN = '0' ) then
				axi_rdata <= (others => '0');
			else
				if (slv_reg_rden = '1') then
					-- When there is a valid read address (S_AXI_ARVALID) with 
					-- acceptance of read address by the slave (axi_arready), 
					-- output the read dada 
					-- Read address mux
					axi_rdata <= reg_data_out; -- register read data
				end if;
			end if;
		end if;
	end process;


	-- Add user logic here

	--------------------------------------------------------------------------------
	-- Synchronization Stage (With stretcher for rst) to avoid metastability
	--------------------------------------------------------------------------------
	rst_i   <= slv_reg0(0) or not(S_AXI_ARESETN);

	stretcher : entity work.monostable
		port map (
			pulse_length => std_logic_vector(to_unsigned(DST_CLK_TIMES_SRC_CLK+1,16)),
			clk          => S_AXI_ACLK,
			din          => rst_i,
			dout         => adc_rst_i
		);

	rst_synchronizer : xpm_cdc_sync_rst
		generic map (
			DEST_SYNC_FF => 2,   -- DECIMAL; range: 2-10
			INIT         => 1,   -- DECIMAL; 0=initialize synchronization registers to 0, 1=initialize
			                     -- synchronization registers to 1
			INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
			SIM_ASSERT_CHK => 0  -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
		)
		port map (
			dest_rst => adc_rst,     -- 1-bit output: src_rst synchronized to the destination clock domain. This output
			                          -- is registered.
			dest_clk => S_AXIS_ACLK,  -- 1-bit input: Destination clock.
			src_rst  => adc_rst_i -- 1-bit input: Source reset signal.
		);


	--------------------------------------------------------------------------------
	-- Asynchronous FIFO Memory (for CDC)
	--------------------------------------------------------------------------------

	-- Read AXI Stream Interface 

	FIFO_M_tvalid <= not (FIFO_empty);
	FIFO_rd_en    <= '1' when (FIFO_M_tvalid='1' and FIFO_M_tready='1') else '0';

	-- Write AXI Stream Interface 
	S_AXIS_TREADY <= FIFO_S_tready;
	FIFO_S_tready <= not (FIFO_full);
	-- Write enable is asserted if and only if FULL flag is not asserted. This is done
	-- to follow the reset pulse requirement and avoid unespected behavior (PG057 p. 130)
	FIFO_wr_en <= '1' when (FIFO_S_tready='1' and S_AXIS_TVALID='1') else '0';

	async_fifo : fifo_generator_0
		PORT MAP (
			rst    => rst_i,
			wr_clk => S_AXIS_ACLK,
			rd_clk => S_AXI_ACLK,
			din    => S_AXIS_TDATA,
			wr_en  => FIFO_wr_en,
			rd_en  => FIFO_rd_en,
			dout   => FIFO_M_tdata,
			full   => FIFO_full,
			empty  => FIFO_empty
		);

	--------------------------------------------------------------------------------
	-- VDIF Formatter logic
	--------------------------------------------------------------------------------
    
    vdif_word0 <= slv_reg1;
    vdif_word1 <= slv_reg2;
    vdif_word2 <= slv_reg3;
    vdif_word3 <= slv_reg4;
    vdif_word4 <= slv_reg5;
    vdif_word5 <= slv_reg6;
    vdif_word6 <= slv_reg7;
    vdif_word7 <= slv_reg8;
 
    
	vdif_logic_1 : entity work.vdif_logic
		port map (
			rst            => rst_i,
			clk            => S_AXI_ACLK,
			S_AXIS_TDATA   => FIFO_M_tdata,
			S_AXIS_TVALID  => FIFO_M_tvalid,
			S_AXIS_TREADY  => FIFO_M_tready,
			M_AXIS_TDATA   => M_AXIS_TDATA,
			M_AXIS_TVALID  => M_AXIS_TVALID,
			M_AXIS_TREADY  => M_AXIS_TREADY,
			digital_pps_in => digital_pps_in,
			EUD_W7         => vdif_word7,
			EUD_W6         => vdif_word6,
			EUD_W5         => vdif_word5,
			EUD_W4         => vdif_word4(23 downto 0),
			EDV            => vdif_word4(31 downto 24),
			Station_ID     => vdif_word3(15 downto 0),
			Thread_ID      => vdif_word3(25 downto 16),
			Bits_sample_1  => vdif_word3(30 downto 26),
			Data_type      => vdif_word3(31),
			Frame_length   => vdif_word2(23 downto 0),
			log2chns       => vdif_word2(28 downto 24),
			VDIF_version   => vdif_word2(31 downto 29),
			Ref_epoch      => vdif_word1(29 downto 24),
			Unassigned     => vdif_word1(31 downto 30),
			Sec_from_epoch => Sec_from_epoch,
			Legacy_mode    => vdif_word0(30),
			Invalid_data   => vdif_word0(31),
			Frame_end      => M_AXIS_TLAST
		);
	-- User logic ends

end arch_imp;
