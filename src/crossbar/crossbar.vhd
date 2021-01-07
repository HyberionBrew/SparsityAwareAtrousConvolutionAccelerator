----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/22/2018 05:01:38 PM
-- Design Name:
-- Module Name: crossbar - beh
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Crossbar with input FIFOs and wavefront arbiter for #inputs <= #outputs
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Each input channel has a validity bit which is only used to check whether the crossbar can accept
--						the inputs. The transaction has to be started with the master valid_in signal!
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--use work.common_pkg.all;
use work.arbiter_pkg.all;
use work.crossbar_pkg.all;
use work.fifo_pkg.all;
use work.pe_group_pck.all;

entity crossbar is
	generic
	(
		NUM_INPUTS : natural;	-- number of inputs
		NUM_OUTPUTS: natural;
		ADDR_WIDTH : natural;	-- number of bits for output addresses
		TAG_WIDTH : natural;	-- number of bits for user tag
		DATA_WIDTH : natural;	-- number of bits per data block
		FIFO_DEPTH : natural;	-- depth of input fifos
		FIFO_ALMOST_FULL: natural;
		ENABLE_CYCLE : boolean	-- enable arbiter cycling
	);
	port
	(
		clk : in std_logic;
		res : in std_logic;
		valid_in : in std_logic;											-- master valid
		empty_out    : out std_logic; --signals to pipeline that queues are empty
		ready_in : in std_logic_vector(BRAMS_PER_ACCUMULATOR - 1 downto 0);		-- which outputs are ready
		inputs : in crossbar_packet_in_array(NUM_INPUTS - 1 downto 0);--(data(DATA_WIDTH - 1 downto 0), tag(TAG_WIDTH - 1 downto 0), address(ADDR_WIDTH - 1 downto 0));	-- input data, tag, address and validity bit
		stall_out : out std_logic_vector(NUM_INPUTS-1 downto 0);											-- whether the crossbar is ready to accept inputs
		outputs : out crossbar_packet_out_array(BRAMS_PER_ACCUMULATOR - 1 downto 0)--(data(DATA_WIDTH - 1 downto 0), tag(TAG_WIDTH - 1 downto 0))	-- output data, tag and validity bit
	);
end crossbar;

architecture beh of crossbar is



	-- direct requests and grants

	
	signal requests : slv_out_type(NUM_INPUTS - 1 downto 0);
	signal grants : slv_out_type(NUM_INPUTS - 1 downto 0);

	-- cycled rquests and grants
	signal requests_cyc : slv_out_type(NUM_INPUTS - 1 downto 0);
	signal grants_cyc : slv_out_type(NUM_INPUTS - 1 downto 0);

	-- fifo signals
	signal rd_en : std_logic_vector(NUM_INPUTS - 1 downto 0);
	signal data_address_tag : data_address_tag_type(NUM_INPUTS - 1 downto 0);
	signal full, stall_en : std_logic_vector(NUM_INPUTS - 1 downto 0);
	signal empty : std_logic_vector(NUM_INPUTS - 1 downto 0);

	signal cycle : integer range 0 to NUM_INPUTS - 1 := 0;

	-- signals instead of aliases because modelsim has problems with subslice aliases

	signal data : data_type(NUM_INPUTS - 1 downto 0);
	signal address : address_type(NUM_INPUTS - 1 downto 0);
	signal tag : tag_type(NUM_INPUTS - 1 downto 0);

    constant STALL_DELAY : integer := 2;
    type stall_delay_type is array(STALL_DELAY-1 downto 0) of std_logic_vector(NUM_INPUTS-1 downto 0);
    signal stall,stall_nxt: stall_delay_type;

begin
    empty_sig_out: process(all)
    begin
        empty_out <= AND_REDUCE(empty);
    end process;
    
    
    
	arb : arbiter
	generic map
	(
		NUM_INPUTS => NUM_INPUTS,
		NUM_OUTPUTS => NUM_OUTPUTS
	)
	port map
	(
		ready_in => ready_in,
		requests => requests_cyc,
		grants => grants_cyc
	);

	fifos : for i in 0 to NUM_INPUTS - 1 generate
		inst : fifo
		generic map
		(
			DATA_WIDTH => DATA_WIDTH + ADDR_WIDTH + TAG_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH,
	        FIFO_ALMOST_FULL => FIFO_ALMOST_FULL,
			PASS_THROUGH => false
		)
		port map
		(
			clk => clk,
			res => res,
			wr_en => inputs(i).valid and valid_in and not(full(i)),
			wr_data => inputs(i).data & inputs(i).address & inputs(i).tag,
			rd_en => rd_en(i),
			rd_data => data_address_tag(i),
			full => full(i),
			empty => empty(i),
			stall_en => stall_en(i)
		);
		data(i) <= data_address_tag(i)(DATA_WIDTH + ADDR_WIDTH + TAG_WIDTH - 1 downto ADDR_WIDTH + TAG_WIDTH);
		address(i) <= data_address_tag(i)(ADDR_WIDTH + TAG_WIDTH - 1 downto TAG_WIDTH);
		tag(i) <= data_address_tag(i)(TAG_WIDTH - 1 downto 0);

		no_cycle : if not ENABLE_CYCLE generate
			requests_cyc <= requests;
			grants <= grants_cyc;
		end generate;
	end generate;
    
    
	-- only necessary with ENABLE_CYCLE
	en_cycle : if ENABLE_CYCLE generate
		sync : process(all)
		begin
			if ENABLE_CYCLE then
				if res = RESET then
					cycle <= 0;
				elsif rising_edge(clk) then
					if cycle = NUM_INPUTS - 1 then
						cycle <= 0;
					else
						cycle <= cycle + 1;
					end if;
				end if;
			end if;
		end process;

		assign : process(all)
			variable input_id : integer range 0 to NUM_INPUTS - 1;
		begin
			-- avoid latch generation
			grants <= (others => (others => '0'));

			-- calculate cycled input operands
			for i in 0 to NUM_INPUTS - 1 loop
				if cycle + i >= NUM_INPUTS then
					input_id := cycle - (NUM_INPUTS - i);
				else
					input_id := cycle + i;
				end if;
				requests_cyc(i) <= requests(input_id);
				grants(input_id) <= grants_cyc(i);
			end loop;
		end process;
	end generate;
	
	stall_sync : process(all)
	begin
	   if res = RESET then
	       stall <= (others => (others =>'0'));
	   elsif rising_edge(clk) then
		  stall <= stall_nxt;
		end if;			
	end process;
	
	stall_output: process(all)
	begin
	   stall_out <= stall_en;
	--   stall_nxt(STALL_DELAY-1) <= stall_en;
	 --  for I in 0 to STALL_DELAY-2 loop
	  --     stall_nxt(I) <= stall(I+1);
	   --    stall_nxt(I) <= stall(I+1);
	  -- end loop;
	   
	   
	end process;

	output : process(all)
		variable var_ready_out : std_logic;
	begin
		-- reset requests, outputs and enables
		requests <= (others => (others => '0'));
		outputs <= (others => ((others => '-'), (others => '-'), '0'));
		rd_en <= (others => '0');

		-- calculate ready_out
		--var_ready_out := '0';
		--for i in 0 to NUM_INPUTS - 1 loop
		--	var_ready_out := (full(i) and inputs(i).valid) or var_ready_out;
		--end loop;
		--ready_out <= not var_ready_out;
     
		-- operate crossbar
		for i in 0 to NUM_INPUTS - 1 loop
			for o in 0 to NUM_OUTPUTS - 1 loop
				-- set requests
				if empty(i) = '0' and to_integer(unsigned(address(i))) = o then
					requests(i)(o) <= '1';
				end if;
				-- consume inputs and redirect to outputs
				if grants(i)(o) = '1' then
					outputs(o) <= (data(i), tag(i), '1');
					rd_en(i) <= '1';
				end if;
			end loop;
		end loop;

	end process;

end beh;
