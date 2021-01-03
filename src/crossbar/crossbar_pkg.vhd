----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/23/2018 11:40:46 AM
-- Design Name:
-- Module Name: crossbar_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Crossbar package
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
use work.pe_group_pck.all;
--use work.common_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package crossbar_pkg is
  --needed for crossbar

type crossbar_packet_in is record
	data : std_logic_vector(DATA_WIDTH_RESULT - 1 downto 0);
	tag : std_logic_vector(CROSSBAR_TAG_WIDTH - 1 downto 0);
	address : std_logic_vector(CROSSBAR_ADDRESS_WIDTH - 1 downto 0);
	valid : std_logic;
end record;

type crossbar_packet_out is record
	data : std_logic_vector(DATA_WIDTH_RESULT - 1 downto 0);
	tag : std_logic_vector(CROSSBAR_TAG_WIDTH - 1 downto 0);
	valid : std_logic;
end record;

type crossbar_packet_in_array is array (integer range <>) of crossbar_packet_in;
type crossbar_packet_out_array is array(integer range <>) of crossbar_packet_out;

component crossbar is
	generic
	(
		NUM_INPUTS : natural;	-- number of inputs
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
		ready_in : in std_logic_vector(2 ** ADDR_WIDTH - 1 downto 0);		-- which outputs are ready
		inputs : in crossbar_packet_in_array(NUM_INPUTS - 1 downto 0)(data(DATA_WIDTH - 1 downto 0), tag(TAG_WIDTH - 1 downto 0), address(ADDR_WIDTH - 1 downto 0));	-- input data, tag, address and validity bit
		ready_out : out std_logic;											-- whether the crossbar is ready to accept inputs
		outputs : out crossbar_packet_out_array(2 ** ADDR_WIDTH - 1 downto 0)(data(DATA_WIDTH - 1 downto 0), tag(TAG_WIDTH - 1 downto 0))	-- output data, tag and validity bit
	);
end component;

end crossbar_pkg;
