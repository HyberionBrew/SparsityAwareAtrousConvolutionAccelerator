----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 07/04/2018 12:55:31 PM
-- Design Name:
-- Module Name: block_ram - beh
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Dual-Port Read-First Block RAM (recognized by vivado 2017.2 inference)
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:	ATTENTION: When a port writes to an address that the other
--			port wants to read from, the old value will be read!
--
----------------------------------------------------------------------------------



library IEEE;
library UNISIM;

use UNISIM.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.


entity block_ram is
	generic
	(
		ADDR_WIDTH : natural;	-- bitwidth of address
		DATA_WIDTH : natural	-- bitwidth of data
	);
	port
	(
		clk : in std_logic;
		addr_a : in std_logic_vector(ADDR_WIDTH - 1 downto 0);	-- port a address
		addr_b : in std_logic_vector(ADDR_WIDTH - 1 downto 0);	-- port b address
		din_a : in std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port a write data
		din_b : in std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port b write data
		en_a : in std_logic;									-- port a enable
		en_b : in std_logic;									-- port b enable
		we_a : in std_logic;									-- port a write-enable
		we_b : in std_logic;									-- port b write-enable
		dout_a : out std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port a read data
		dout_b : out std_logic_vector(DATA_WIDTH - 1 downto 0)	-- port b read data
	);
end block_ram;

architecture beh of block_ram is

	-- memory
	type ram_type is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	shared variable ram : ram_type := (others => (others => '0'));

	-- force BRAM
	attribute ram_style : string;
	attribute ram_style of ram : variable is "block";

begin

	-- port a process
	porta : process(clk)
	begin
		if rising_edge(clk) then
			if en_a = '1' then
				dout_a <= ram(to_integer(unsigned(addr_a)));
				if we_a = '1' then
					ram(to_integer(unsigned(addr_a))) := din_a;
				end if;
			end if;
		end if;
	end process;

	-- port b process
	portb : process(clk)
	begin
		if rising_edge(clk) then
			if en_b = '1' then
				dout_b <= ram(to_integer(unsigned(addr_b)));
				if we_b = '1' then
					ram(to_integer(unsigned(addr_b))) := din_b;
				end if;
			end if;
		end if;
	end process;

end beh;
