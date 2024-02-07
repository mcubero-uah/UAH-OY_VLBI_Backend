----------------------------------------------------------------------------------
-- Company: Universidad de Alcala / Observatorio de Yebes
-- Engineer: Miguel Cubero Vacas
-- 
-- Create Date: 25.04.2023 13:29:13
-- Design Name: 
-- Module Name: vdif_logic - Behavioral
-- Project Name: 
-- Target Devices: Zedboard
-- Tool Versions: Vivado 2017.4
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
use ieee.numeric_std.all;


entity vdif_logic is
	Port (
		rst : in std_logic;
		clk : in std_logic;
		-- FIFO AXIS write interface		
		S_AXIS_TDATA  : in  std_logic_vector(31 downto 0);
		S_AXIS_TVALID : in  std_logic;
		S_AXIS_TREADY : out std_logic;
		-- FIFO AXIS read interface		
		M_AXIS_TDATA  : out std_logic_vector(31 downto 0);
		M_AXIS_TVALID : out std_logic;
		M_AXIS_TREADY : in  std_logic;
		-- PPS Input
		digital_pps_in : in std_logic;
		--VDIF Header inputs ---------------------------------------------------
		EUD_W7 : in std_logic_vector(31 downto 0);          -- Word 7 Extended User Data 
		EUD_W6 : in std_logic_vector(31 downto 0);          -- Word 6 Extended User Data 
		EUD_W5 : in std_logic_vector(31 downto 0);          -- Word 5 Extended User Data
		                                                    -- Word 4
		EUD_W4 : in std_logic_vector(23 downto 0);       -- Word 4 Extended User Data 	
		EDV    : in std_logic_vector(7 downto 0);        -- Word 4 Extended Data Version 	
		                                                    -- Word 3
		Station_ID    : in std_logic_vector(15 downto 0);   -- Word 3 Station ID
		Thread_ID     : in std_logic_vector(9 downto 0);    -- Word 3 Thread ID 
		Bits_sample_1 : in std_logic_vector(4 downto 0);    -- Word 3 Bits/sample-1
		Data_type     : in std_logic;                 -- Word 3 Data type		
		                                                    -- Word 2
		Frame_length : in std_logic_vector(23 downto 0); -- Word 2 Data Frame length (in units of 8 bytes or 64 bits)	
		log2chns     : in std_logic_vector(4 downto 0);     -- Word 2 log2 channels in Data Array
		VDIF_version : in std_logic_vector(2 downto 0);     -- Word 2 VDIF Version number
		                                                 -- Word 1	
		Ref_epoch  : in std_logic_vector(5 downto 0);       -- Word 1 Reference Epoch 
		Unassigned : in std_logic_vector(1 downto 0);       -- Word 1 Unassigned (all 0s)
		                                                    -- Word 0
		Sec_from_epoch : in std_logic_vector(29 downto 0);  -- Word 0 Seconds from reference epoch
		Legacy_mode    : in std_logic;                      -- Word 0 Legacy mode
		Invalid_data   : in std_logic;                      -- Word 0 Invalid data
		                                              --		
		Frame_end : out std_logic
	);
end vdif_logic;

architecture Behavioral of vdif_logic is
	type FSM_state is (idle_state, transmit_header,transmit_payload);
	signal state : FSM_state;

	signal payload_end : std_logic;
	signal header_end  : std_logic;
	signal word_cnt    : unsigned (24 downto 0);
	signal frame_end_i : std_logic;

	signal M_AXIS_TVALID_i : std_logic;
	-----------------------------------------------------------------------------
	--			VDIF Header signals 
	-----------------------------------------------------------------------------

	signal data_frame_number  : std_logic_vector(23 downto 0); -- Word 1 Data Frame number
	signal data_frame_number_u  : unsigned(23 downto 0); -- Word 1 Data Frame number
	signal frame_length_i     : unsigned (23 downto 0);
	signal frame_length_words : unsigned(24 downto 0);
	-- Words

	signal word_7 : std_logic_vector(31 downto 0);
	signal word_6 : std_logic_vector(31 downto 0);
	signal word_5 : std_logic_vector(31 downto 0);
	signal word_4 : std_logic_vector(31 downto 0);
	signal word_3 : std_logic_vector(31 downto 0);
	signal word_2 : std_logic_vector(31 downto 0);
	signal word_1 : std_logic_vector(31 downto 0);
	signal word_0 : std_logic_vector(31 downto 0);
	
	signal frame_number_clr : std_logic;

begin
	
	word_7 <= EUD_W7;
	word_6 <= EUD_W6;
	word_5 <= EUD_W5;
	word_4 <= EDV & EUD_W4;
	word_3 <= Data_type & Bits_sample_1 & Thread_ID & Station_ID;
	word_2 <= VDIF_version & log2chns & Frame_length;
	word_1 <= Unassigned & Ref_epoch & data_frame_number;
   	word_0 <=  Invalid_data & Legacy_mode & Sec_from_epoch;
	
	data_frame_number  <= std_logic_vector(data_frame_number_u);
	frame_end     <= frame_end_i;
	M_AXIS_TVALID <= M_AXIS_TVALID_i;

	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (rst = '1') then
                state <= idle_state;
            else    
                case state is
                    when idle_state =>
                        state <= transmit_header;
                    when transmit_header =>
                        if (header_end = '1') then
                            state <= transmit_payload;
                        else
                            state <= transmit_header;
                        end if;
                    when transmit_payload =>
                        if (frame_end_i = '1') then
                            state <= transmit_header;
                        else
                            state <= transmit_payload;
                        end if;
                end case;
            end if;
		end if;
	end process;

	process(state,rst,word_cnt,word_0,word_1,word_2,word_3,word_4,word_5,word_6,word_7,S_AXIS_TDATA,M_AXIS_TREADY,S_AXIS_TVALID)
	variable word_cnt_int : integer;
	begin
	   word_cnt_int := to_integer(word_cnt);
		case state is

			when idle_state =>
				S_AXIS_TREADY   <= '0';	
				if (rst='1') then
				    M_AXIS_TVALID_i <= '0';
				    M_AXIS_TDATA    <= (others => '0');
				else
				    M_AXIS_TVALID_i <= '1';
				    M_AXIS_TDATA <= word_0;
				end if;

			when transmit_header =>
				S_AXIS_TREADY   <= '0';
				M_AXIS_TVALID_i <= '1';
				case word_cnt_int is
					when 0 =>
						M_AXIS_TDATA <= word_0;
					when 1 =>
						M_AXIS_TDATA <= word_1;
					when 2 =>
						M_AXIS_TDATA <= word_2;
					when 3 =>
						M_AXIS_TDATA <= word_3;
					when 4 =>
						M_AXIS_TDATA <= word_4;
					when 5 =>
						M_AXIS_TDATA <= word_5;
					when 6 =>
						M_AXIS_TDATA <= word_6;
					when 7 =>
						M_AXIS_TDATA <= word_7;
					when others =>
						M_AXIS_TDATA <= (others => '0');
				end case;

			when transmit_payload =>
				M_AXIS_TDATA    <= S_AXIS_TDATA;
				S_AXIS_TREADY   <= M_AXIS_TREADY;
				M_AXIS_TVALID_i <= S_AXIS_TVALID;
		end case;
	end process;


	--Almaceno datos de 4 bytes en 4 bytes (32 bits) ->
	--Longitud del array en uds de 8 bytes = [Frame_length(8 bytes) - 4 (32 bytes de header)]*2 =(Frame_length-4) << 1 (uds de 4 bytes)
	frame_length_i     <= unsigned(Frame_length);
	frame_length_words <= frame_length_i & '0';

	payload_counter : process (clk)
	begin
		if clk'event and clk='1' then
		    if (rst = '1') then
                word_cnt <= (others => '0');
            else
                if (M_AXIS_TVALID_i='1' and M_AXIS_TREADY='1') then
                    word_cnt <= word_cnt + 1;
                    if (word_cnt=(frame_length_words-1)) then
                        word_cnt <= (others => '0');
                    end if;
                end if;
            end if;        
		end if;
	end process payload_counter;

	header_end  <= '1' when (M_AXIS_TVALID_i='1' and M_AXIS_TREADY='1' and word_cnt=7) else '0'; --When 8 words of header are transmitted
	frame_end_i <= '1' when (M_AXIS_TVALID_i='1' and M_AXIS_TREADY='1' and word_cnt=(frame_length_words-1)) else '0';

	frame_number_clr_process: process (clk)
	begin
		if clk'event and clk='1' then
		  if (rst = '1' ) then --if new second
            frame_number_clr <= '0';
          elsif (digital_pps_in='1') then 
          	frame_number_clr <= '1';
          elsif (frame_end_i = '1') then
          	frame_number_clr <= '0';	
		  end if;	
		end if;
	end process frame_number_clr_process;
	
	frame_counter : process (clk)
	begin
		if clk'event and clk='1' then
		  if (rst = '1' or frame_number_clr='1') then --if new second
            data_frame_number_u <= (others => '0');
          else  
			if (frame_end_i = '1') then
				data_frame_number_u <= data_frame_number_u + 1;
			end if;
		  end if;	
		end if;
	end process frame_counter;

end Behavioral;
