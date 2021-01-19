library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;

package pe_pack is
  type kernel_values_type is array(0 to NUMBER_OF_KERNELS_PER_PE, 0 to VALUES_PER_KERNEL-1) of signed(DATA_WIDTH-1 downto 0);
  type ifmap_values_type is array(0 to NUMBER_OF_IFMAPS_PER_PE,0 to VALUES_PER_IFMAP-1) of unsigned(DATA_WIDTH-1 downto 0);
  type kernel_bitvecs_type is array(0 to NUMBER_OF_IFMAPS_PER_PE-1) of std_logic_vector(VALUES_PER_KERNEL-1 downto 0);
  type ifmap_bitvecs_type is array(0 to NUMBER_OF_KERNELS_PER_PE-1) of std_logic_vector(VALUES_PER_IFMAP-1 downto 0);
  constant INDEX_MAX :natural:= 6*3;
  constant SHIFT_MAX :natural:= 9;
  constant DATA_WIDTH_RESULT: natural:= 18;
  constant MAX_Y : natural := 33;
  type INDEX_TYPE is record
    xindex: natural range 0 to 2;
    yindex: natural range 0 to MAX_Y-1;
  end record;



end package;
