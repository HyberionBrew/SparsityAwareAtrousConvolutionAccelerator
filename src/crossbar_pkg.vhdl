
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
package crossbar_pkg is

  type crossbar_packet_in is record
  	data : std_logic_vector;
  	tag : std_logic_vector;
  	address : std_logic_vector;
  	valid : std_logic;
  end record;

  type crossbar_packet_out is record
  	data : std_logic_vector;
  	tag : std_logic_vector;
  	valid : std_logic;
  end record;

  type crossbar_packet_in_array is array(integer range <>) of crossbar_packet_in;
  type crossbar_packet_out_array is array(integer range <>) of crossbar_packet_out;

end package;
