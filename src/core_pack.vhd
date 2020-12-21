library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package core_pack is

  TYPE BIT_TYPE IS (ifmap_bitvec_type,kernel_bitvec_type);


  constant DATA_WIDTH : integer := 8;
  constant BUS_WIDTH_BITS : integer := 567; --TODO! set
  constant FINISHED_IFMAPS_SIGNAL_SIZE : integer := 5;


  constant PE_PSUM_SIZE : integer := FINISHED_IFMAPS_SIGNAL_SIZE**2; --3
  constant PE_INDEX_BITVEC_SIZE : integer := 6;
  constant PE_IFMAP_BITVEC : integer := 6;
  constant PE_WEIGHT_BITVEC : integer := 9;
  constant PE_SHIFT_SIZE: integer := 5; --2⁵ = 16 I need 9 shifts

  constant Priority_Encoder_In: integer := 6;
  constant Priority_Encoder_out: integer :=3 ;


  constant REG_KERNELS : natural := 3;
  constant MAX_INDEX_SIZE : natural := 4; --this dictates weight_counter size!
  constant REG_IFMAPS : natural := 2;

  constant REG_KERNEL_BITS_X : natural := 9*8;--Bits needed for KERNEL kernels
  constant REG_KERNEL_BITS_Y : natural := REG_KERNELS;
  constant REG_IFMAP_BITS_X : natural := 6*8;
  constant REG_IFMAP_BITS_Y : natural := REG_KERNELS;

  TYPE MEM_KERNEL is ARRAY (0 to REG_KERNEL_BITS_X-1,0 to REG_KERNEL_BITS_Y) of unsigned(8-1 downto 0);
  TYPE MEM_IFMAP is ARRAY (0 to REG_IFMAP_BITS_X-1,0 to REG_IFMAP_BITS_Y) of unsigned(8-1 downto 0);

  constant REG_KERNEL_BITVEC_BITS : natural := REG_KERNELS*9;--Bits needed for KERNEL kernels
  constant REG_IFMAP_BITVEC_BITS : natural := REG_IFMAPS*6;

  TYPE MEM_BITVEC_KERNEL is ARRAY (0 to REG_KERNELS-1) of std_logic_vector(9-1 downto 0);
  TYPE MEM_BITVEC_IFMAP is ARRAY (0 to REG_IFMAPS-1) of std_logic_vector(6-1 downto 0);

  constant INDEX_BIT_SIZE :integer:= 3;
  TYPE value_type is(ifmap,kernel);

  constant SCALE_MULT_SIZE : integer := 32;
end core_pack;
