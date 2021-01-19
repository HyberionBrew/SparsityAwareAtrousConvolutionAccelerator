library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package core_pck is

  constant DATA_WIDTH: natural := 8;
  constant VALUES_PER_KERNEL : natural := 9;
  constant VALUES_PER_IFMAP: natural:= 6;
  constant NUMBER_OF_IFMAPS_PER_PE : natural := 6;
  constant NUMBER_OF_KERNELS_PER_PE: natural := NUMBER_OF_IFMAPS_PER_PE;
end package;
