library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_group_pck.all;

package pe_pack is

  constant SHIFT_MAX : Integer := 9;
  constant INDEX_MAX : Integer := 18;
  constant SIMULTANEOUS_KERNELS :integer := 3;
  constant IFMAP_BITVEC_SIZE : integer := 6;
  constant KERNEL_BITVEC_SIZE : integer := 9;
  constant EXTRACTION_WIDTH :integer := VALUES_PER_IFMAP * SIMULTANEOUS_KERNELS;
  constant MAX_BITVECS_WIDTH : integer := maximum(KERNELS_PER_PE*KERNEL_BITVEC_SIZE, IFMAPS_PER_PE*IFMAP_BITVEC_SIZE);
  --constant INDEX_SIZE: Integer := 4;
  constant ifmap_rows_tiled : integer := 33;
  constant MAX_ADDR_IFMAP : integer := 64;
  constant MAX_ADDR_KERNEL : integer := 64;
  constant BUS_WIDTH_DATA_KERNEL : integer := KERNELS_PER_PE* KERNEL_DATA_WIDTH;
  constant BUS_WIDTH_DATA_IFMAP : integer := IFMAPS_PER_PE* IFMAP_DATA_WIDTH;
  constant BUS_DATA_OFFSET: integer := MAX_BITVECS_WIDTH; --60
  
  constant BUS_ZEROES_OFFSET_KERNEL: integer := BUS_DATA_OFFSET + BUS_WIDTH_DATA_KERNEL;
  
  constant BUS_ZEROES_OFFSET_IFMAP: integer := BUS_DATA_OFFSET + BUS_WIDTH_DATA_IFMAP; --60 + 10 * 8 * 6 = 540
  
  
  constant MAX_MEM_WIDTH: Integer:= maximum(BUS_WIDTH_DATA_KERNEL,BUS_WIDTH_DATA_IFMAP);
  
  
  constant DATA_WIDTH_ZEROS : integer := DATA_WIDTH;
  constant ZERO_WIDTH_IFMAP : integer := DATA_WIDTH_ZEROS;
  constant ZERO_WIDTH_KERNEL : integer := KERNELS_PER_PE* DATA_WIDTH_ZEROS;
  
  
 -- constant DATA_WIDTH_RESULT :integer := (DATA_WIDTH+1) *2;
  constant MAX_X :integer := 6;
  constant MAX_Y :integer := 33;
  constant MAX_KERNEL_OFFSET: integer := 511;
  constant DATA_WIDTH_ROW :integer:= 6;--from 0 to 5
  constant DATA_WIDTH_COLUMN : integer:= 3;--from 0 to 32
  constant BUS_KERNEL_OFFSET_OFFSET: integer := BUS_ZEROES_OFFSET_KERNEL + ZERO_WIDTH_KERNEL;
  constant KERNEL_OFFSET_WIDTH : integer := 9;
  constant BUS_COLUMN_OFFSET: integer:= BUS_ZEROES_OFFSET_IFMAP +ZERO_WIDTH_IFMAP;
  constant BUS_ROW_OFFSET: integer:= BUS_COLUMN_OFFSET+DATA_WIDTH_COLUMN;
  
  type INDEX_TYPE is record
    xindex: natural range 0 to MAX_X-1;
    yindex: natural range 0 to MAX_Y-1;
    w: natural range 0 to KERNELS_PER_PE-1;
  end record;
  
  
  component PE is
	port
	(
      reset, clk : in std_logic;
      stall: in std_logic;
      finished : out std_logic;
      new_kernels : in std_logic;
      new_ifmaps : in std_logic;
      want_new_values : out std_logic;
      bus_to_pe : in std_logic_vector(BUSSIZE-1 downto 0);
      result : out signed(DATA_WIDTH_RESULT-1 downto 0);
      to_index : out INDEX_TYPE;
      valid_out : out std_logic;
      crossbar_packet : out crossbar_packet_in-- output data, tag and validity bit
	);
end component;

end package;
--
