library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package core_pck is
  constant IFMAP_ROW_TILED : integer := 33;
  constant IFMAP_COLUMNS_TILED: integer := 6;
  constant NUMBER_KERNELS : Integer := 256;
  constant DATA_WIDTH : Integer := 8;
  constant ZERO_POINTS_MAX : Integer := 256;

  constant WRITE_DEPTH : Integer := 2;

  constant BUSSIZE : integer:=512;
  --for PE
  constant VALUES_PER_KERNEL : integer := 9;
  constant VALUES_PER_IFMAP: integer := 6;

  constant KERNELS_PER_PE : Integer := 6;
  constant IFMAPS_PER_PE : integer := 10;
  constant KERNEL_DATA_WIDTH : Integer := DATA_WIDTH * VALUES_PER_KERNEL;
  constant IFMAP_DATA_WIDTH : Integer := DATA_WIDTH * VALUES_PER_IFMAP;

  constant KERNELS_PER_BUS_ACCESS : integer := KERNELS_PER_PE/WRITE_DEPTH;

  constant IFMAPS_PER_BUS_ACCESS : integer := IFMAPS_PER_PE/WRITE_DEPTH;
  

     --constant SHIFT_SIZE : integer := 9;

end package;