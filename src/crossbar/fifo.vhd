----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/25/2018 11:50:27 AM
-- Design Name:
-- Module Name: fifo - beh
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: FWFT FIFO with optional pass-through logic
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

use work.common_pkg.all;

entity fifo is
	generic
	(
		DATA_WIDTH : natural;	-- bitwidth of fifo entry
		FIFO_DEPTH : natural;	-- number of fifo entries
		FIFO_ALMOST_FULL: natural;
		PASS_THROUGH : boolean	-- whether pass-through is available
	);
	port
	(
		clk : in std_logic;
		res : in std_logic;
		wr_en : in std_logic;										-- write to fifo
		wr_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);		-- data to be written
		rd_en : in std_logic;										-- acknowledge output (fwft)
		rd_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);	-- current data in fifo
		full : out std_logic;										-- asserts whether fifo is full
		empty : out std_logic;                                       -- asserts whether fifo is empty
		stall_en: out std_logic                                      --enables stall										
	);
end fifo;

architecture beh of fifo is

	type data_array is array(FIFO_DEPTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);

	signal data : data_array;-- := (others => (others => '0'));
	signal rd_ptr : integer range 0 to FIFO_DEPTH - 1 := 0;
	signal wr_ptr : integer range 0 to FIFO_DEPTH - 1 := 0;
	signal rd_ptr_next : integer range 0 to FIFO_DEPTH - 1;
	signal wrap : boolean := false;
	signal wrap_next : boolean;
	signal data_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);
	
	--constant FIFO_ALMOST_FULL: integer := 2;

begin

	sync : process(all)
	begin
		if res = RESET then
			rd_ptr <= 0;
			wr_ptr <= 0;
			wrap <= false;
		elsif rising_edge(clk) then

			-- update rd_ptr, wrap and data_reg
			rd_ptr <= rd_ptr_next;
			wrap <= wrap_next;
			data_reg <= data(rd_ptr_next);

			-- perform write
			if full = '0' and wr_en = '1' then
				data(wr_ptr) <= wr_data;
				if rd_ptr_next = wr_ptr then
					data_reg <= wr_data;
				end if;
				if wr_ptr = FIFO_DEPTH - 1 then
					wr_ptr <= 0;
					if not wrap and not (rd_ptr_next = 0 and rd_en = '1') then
						wrap <= true;
					end if;
					if wrap and (rd_ptr_next = 0 and rd_en = '1') then
						wrap <= true;
					end if;
				else
					wr_ptr <= wr_ptr + 1;
				end if;
			end if;

		end if;
	end process;

	output : process(all)
	begin
		rd_ptr_next <= rd_ptr;
		wrap_next <= wrap;

		-- set full and empty flags
		full <= '0';
		empty <= '0';
		stall_en <= '0';
		if rd_ptr = wr_ptr then
			if not wrap then
				if not PASS_THROUGH then
					empty <= '1';
				elsif wr_en = '0' then
					empty <= '1';
				end if;
			elsif rd_en = '0' then
				full <= '1';
				stall_en <= '1';
			end if;
		end if;
		
		if wrap = True then
		  if rd_ptr -wr_ptr < FIFO_ALMOST_FULL then
		      stall_en <= '1';
		   end if;
		else 
		  IF (FIFO_DEPTH-wr_ptr) +rd_ptr < FIFO_ALMOST_FULL then
		      stall_en <= '1';
		   end if;
	    end if;


		-- perform read
		if empty = '0' and rd_en = '1' then
			if rd_ptr = FIFO_DEPTH - 1 then
				rd_ptr_next <= 0;
				wrap_next <= false;
			else
				rd_ptr_next <= rd_ptr + 1;
			end if;
		end if;

		-- data assignment
		if PASS_THROUGH and rd_ptr = wr_ptr and not wrap and wr_en = '1' then
			rd_data <= wr_data;
		else
			rd_data <= data_reg;
		end if;

	end process;

end beh;
