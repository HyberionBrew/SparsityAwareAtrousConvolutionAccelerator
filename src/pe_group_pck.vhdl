library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pe_group_pck is
  constant RESET : std_logic := '0';											-- activity level of reset
  constant PES_PER_GROUP: integer := 8;
  constant BRAMS_PER_ACCUMULATOR: integer := 17;
  constant CROSSBAR_ADDRESS_WIDTH: integer := 5; --derivd from BRAMS_PER_ACCUMULATOR
  constant CROSSBAR_TAG_WIDTH : integer := 9; --512 values = 1 BRAM
  constant DATA_WIDTH_RESULT : integer := (8+1) *2;
  constant FIFO_DEPTH : Integer := 10;
  constant FIFO_MAX_DELAY: integer := 2;
  constant BRAM_DEPTH: integer := 512;
  
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


end package;
