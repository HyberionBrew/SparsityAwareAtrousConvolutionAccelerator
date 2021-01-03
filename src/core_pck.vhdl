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

  constant BUSSIZE : integer:=557;
  --for PE
  constant VALUES_PER_KERNEL : integer := 9;
  constant VALUES_PER_IFMAP: integer := 6;

  constant KERNELS_PER_PE : Integer := 6;
  constant IFMAPS_PER_PE : integer := 10;
  constant KERNEL_DATA_WIDTH : Integer := DATA_WIDTH * VALUES_PER_KERNEL;
  constant IFMAP_DATA_WIDTH : Integer := DATA_WIDTH * VALUES_PER_IFMAP;

  constant KERNELS_PER_BUS_ACCESS : integer := KERNELS_PER_PE/WRITE_DEPTH; --to remove

  constant IFMAPS_PER_BUS_ACCESS : integer := IFMAPS_PER_PE/WRITE_DEPTH;--to remove

  --needed for crossbar
  --constant PES_PER_GROUP: integer := 5;
  --constant BRAMS_PER_ACCUMULATOR: integer := 17;
 --- constant CROSSBAR_ADDRESS_WIDTH: integer := 5; --derivd from BRAMS_PER_ACCUMULATOR
 -- constant CROSSBAR_TAG_WIDTH : integer :=9; --512 values = 1 BRAM
  --constant DATA_WIDTH_RESULT : integer := (DATA_WIDTH+1) *2;
  --constant FIFO_DEPTH : Integer := 10;


     --constant SHIFT_SIZE : integer := 9;

end package;
