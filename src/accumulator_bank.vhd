----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
-- modified by Fabian Kresse for use in ASPP-Accelerator
-- Create Date: 07/02/2018 03:06:50 PM
-- Design Name:
-- Module Name: accumulator_bank - beh
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Double buffered accumulator bank witha  signle adder and BRAM buffers
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--use work.common_pkg.all;
use work.block_ram_pkg.all;
use work.acc_bank_pkg.all;

entity accumulator_bank is
	generic
	(
		ADDR_WIDTH : natural;
    RESULT_WIDTH: natural

	);
	port
	(
		clk : in std_logic;
		res : in std_logic;
		valid_in : in std_logic;
		switch : in std_logic;
		wr_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wr_data : in std_logic_vector(18-1 downto 0);
		zero : in std_logic;
		rd_en : in std_logic_vector(1 downto 0);
		rd_addr : in addr_array;
		ready_out : out std_logic;										-- whether buffer is ready for reading
		rd_data : out data_array
	);
end accumulator_bank;

architecture beh of accumulator_bank is

	signal write_buffer : integer range 0 to 1 := 0;
	signal read_buffer : integer range 0 to 1;

	signal addr_a : addr_array;--slv_array(1 downto 0)(ADDR_WIDTH - 1 downto 0);
	signal addr_b : addr_array;--slv_array(1 downto 0)(ADDR_WIDTH - 1 downto 0);
	signal din_a : data_array;--slv_array(1 downto 0)(23 downto 0);
	signal din_b : data_array;--slv_array(1 downto 0)(23 downto 0);
	signal en_a : std_logic_vector(1 downto 0);
	signal en_b : std_logic_vector(1 downto 0);
	signal we_a : std_logic_vector(1 downto 0);
	signal we_b : std_logic_vector(1 downto 0);
	signal dout_a : data_array;--slv_array(1 downto 0)(23 downto 0);
	signal dout_b : data_array;--slv_array(1 downto 0)(23 downto 0);

	signal conv_valid : std_logic;
	signal conv_data : std_logic_vector(23 downto 0);

	signal add_valid : std_logic;
	signal psum_old : std_logic_vector(23 downto 0);
	signal psum_new, psum_new_nxt : std_logic_vector(23 downto 0);

	type op_data is record
		valid : std_logic;
		write_buffer : integer range 0 to 1;
		wr_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
	end record;
	type op_data_array is array(integer range <>) of op_data;
	signal op_reg : op_data_array(1 downto 0) := (others => ('0', 0, (others => '-')));

	type ram_forward_type is record
		valid : std_logic;
		data : std_logic_vector(23 downto 0);
	end record;
	signal ram_fwd : ram_forward_type := ('0', (others => '-'));
	signal ram_fwd_next : ram_forward_type;
	type wr_data_delay_type is array(2 downto 0) of std_logic_vector(18-1 downto 0);
    signal wr_data_delay, wr_data_delay_nxt : wr_data_delay_type;
    type valid_delay_type is array(2 downto 0) of std_logic;
    signal valid_delay, valid_delay_nxt: valid_delay_type;
begin

	read_buffer <= 1 - write_buffer;

	ram : for i in 0 to 1 generate
		inst : block_ram
		generic map
		(
			ADDR_WIDTH => ADDR_WIDTH,
			DATA_WIDTH => 24
		)
		port map
		(
			clk => clk,
			addr_a => addr_a(i),
			addr_b => addr_b(i),
			din_a => din_a(i),
			din_b => din_b(i),
			en_a => en_a(i),
			en_b => en_b(i),
			we_a => we_a(i),
			we_b => we_b(i),
			dout_a => dout_a(i),
			dout_b => dout_b(i)
		);
	end generate;

  --need replace (just delete)
	--fc_inst : float_conv
	--generic map
--	(
--		INPUT_WIDTH => 16,
--		OUTPUT_WIDTH => 24,
--		LATENCY => 1
--	)
--	port map
--	(
--		clk => clk,
--		valid_in => valid_in,
--		data_in => wr_data,
--		valid_out => conv_valid,
--		data_out => conv_data
--	);
  --need replace
--	add_inst : adder
--	port map
--	(
--		clk => clk,
--		valid_in => conv_valid,
--		augend => psum_old,
--		addend => conv_data,
--		valid_out => add_valid,
--		sum => psum_new
--	);

adder: process(all)
begin
   psum_new_nxt <= std_logic_vector(to_signed(0,psum_new_nxt'length));
  if valid_delay(0) = '1' then
    psum_new_nxt <= std_logic_vector(signed(psum_old) + signed(wr_data_delay(0)));
  end if;
end process;


	sync : process(all)
	begin
		if res = '0' then
			write_buffer <= 0;
			op_reg <= (others => ('0', 0, (others => '-')));
			ram_fwd <= ('0', (others => '-'));
		elsif rising_edge(clk) then
			op_reg(0).valid <= valid_in;
			op_reg(0).write_buffer <= write_buffer;
			op_reg(0).wr_addr <= wr_addr;
              wr_data_delay(2) <= wr_data;
              wr_data_delay(1) <= wr_data_delay_nxt(2);
              wr_data_delay(0) <= wr_data_delay_nxt(1);
              
              valid_delay(2) <= valid_in;
              valid_delay(1) <= valid_delay_nxt(2);
              valid_delay(0) <= valid_delay_nxt(1);
              
              op_reg(1) <= op_reg(0);
              psum_new <= psum_new_nxt;
			if switch = '1' then
				write_buffer <= read_buffer;
			end if;

			ram_fwd <= ram_fwd_next;
		end if;
	end process;

	comb : process(all)
	begin
	valid_delay_nxt <= valid_delay;
    wr_data_delay_nxt <= wr_data_delay;
		-- default values (actually only necessary for port b on new read buffer in cycle(s) after switch)
		addr_a <= (others => (others => '-'));
		din_a <= (others => (others => '-'));
		en_a <= (others => '0');
		we_a <= (others => '0');
		addr_b <= (others => (others => '-'));
		din_b <= (others => (others => '-'));
		en_b <= (others => '0');
		we_b <= (others => '0');
		rd_data(0) <= (others => '-');
		rd_data(1) <= (others => '-');

		-- only ready for reading when all writes have passed the pipeline
		ready_out <= '1';
		if (read_buffer = op_reg(0).write_buffer and op_reg(0).valid = '1') or (read_buffer = op_reg(1).write_buffer and op_reg(1).valid = '1') then
			ready_out <= '0';
		end if;

		-- process read buffer assignments first
		if ready_out = '1' then
			addr_a(read_buffer) <= rd_addr(0);
			addr_b(read_buffer) <= rd_addr(1);
			din_a(read_buffer) <= (others => '0');
			din_b(read_buffer) <= (others => '0');
			en_a(read_buffer) <= rd_en(0);
			en_b(read_buffer) <= rd_en(1);
			we_a(read_buffer) <= zero;
			we_b(read_buffer) <= zero;
			rd_data(0) <= dout_a(read_buffer);
			rd_data(1) <= dout_b(read_buffer);
		end if;

		-- write buffer read
		addr_b(op_reg(1).write_buffer) <= wr_addr;
		din_b(op_reg(1).write_buffer) <= (others => '-');
		en_b(op_reg(1).write_buffer) <= '1';
		we_b(op_reg(1).write_buffer) <= '0';
		psum_old <= dout_b(op_reg(0).write_buffer);
		-- write buffer write
		addr_a(op_reg(1).write_buffer) <= op_reg(1).wr_addr;
		din_a(op_reg(1).write_buffer) <= psum_new;
		en_a(op_reg(1).write_buffer) <= '1';
		we_a(op_reg(1).write_buffer) <= add_valid;

		-- forwarding
		ram_fwd_next <= ('0', (others => '-'));
		if op_reg(0) = op_reg(1) and op_reg(0).valid = '1' then
			psum_old <= psum_new;				-- forward from adder output to adder input
		elsif ram_fwd.valid = '1' then
			psum_old <= ram_fwd.data;			-- forward from ram-write to adder input
		end if;

		-- schedule ram forward
		if op_reg(1).write_buffer = write_buffer and op_reg(1).wr_addr = wr_addr and op_reg(1).valid = '1' and valid_in = '1' then
			ram_fwd_next <= ('1', psum_new);	-- schedule forward from ram-write to adder input
		end if;

	end process;

end beh;
