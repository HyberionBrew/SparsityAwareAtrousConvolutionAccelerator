library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

package bus_unit_pck is
  function extract_bitvecs_kernels(v: std_logic_vector)  return std_logic_vector;
  function extract_bitvecs_ifmaps(v: std_logic_vector) return std_logic_vector;
  function extract_data_kernel(v: std_logic_vector) return std_logic_vector;
  function extract_data_ifmap(v: std_logic_vector) return std_logic_vector;
  function extract_zeroes_ifmap(v: std_logic_vector) return std_logic_vector;
  function extract_zeroes_kernel(v: std_logic_vector) return std_logic_vector;
  function extract_current_column(v: std_logic_vector) return natural;
  function extract_current_row(v: std_logic_vector) return natural;
end package;



package body bus_unit_pck is

  function extract_bitvecs_ifmaps(v: std_logic_vector) return std_logic_vector is
    variable bitvecs: std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0):= (others => '0');
 begin
    bitvecs(VALUES_PER_IFMAP*IFMAPS_PER_PE-1 downto 0):= v(VALUES_PER_IFMAP*IFMAPS_PER_PE-1 downto 0);
    return bitvecs;
 end function;

  function extract_bitvecs_kernels(v: std_logic_vector) return std_logic_vector is
    variable bitvecs: std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0):= (others => '0');
 begin
    bitvecs(VALUES_PER_KERNEL*KERNELS_PER_PE-1 downto 0):= v(VALUES_PER_KERNEL*KERNELS_PER_PE-1 downto 0);
    return bitvecs;
 end function;


function extract_data_ifmap(v: std_logic_vector) return std_logic_vector is
    variable data: std_logic_vector(MAX_MEM_WIDTH-1 downto 0):= (others =>'0');
begin
    data(IFMAPS_PER_PE*IFMAP_DATA_WIDTH-1 downto 0) := v(IFMAPS_PER_PE*IFMAP_DATA_WIDTH-1+BUS_DATA_OFFSET downto BUS_DATA_OFFSET);
    return data;
end function;

function extract_data_kernel(v: std_logic_vector) return std_logic_vector is
    variable data: std_logic_vector(MAX_MEM_WIDTH-1 downto 0):= (others =>'0');
begin
    data(KERNELS_PER_PE*KERNEL_DATA_WIDTH-1 downto 0) := v(KERNELS_PER_PE*KERNEL_DATA_WIDTH-1+BUS_DATA_OFFSET downto BUS_DATA_OFFSET);
    return data;
end function;

function extract_zeroes_kernel(v: std_logic_vector) return std_logic_vector is
    variable data: std_logic_vector(ZERO_WIDTH_KERNEL-1 downto 0):= (others =>'0');
begin
    data(KERNELS_PER_PE*DATA_WIDTH_ZEROS-1 downto 0) := v(KERNELS_PER_PE*DATA_WIDTH_ZEROS-1+BUS_ZEROES_OFFSET_KERNEL downto BUS_ZEROES_OFFSET_KERNEL);
    return data;
end function;


function extract_zeroes_ifmap(v: std_logic_vector) return std_logic_vector is
    variable data: std_logic_vector(ZERO_WIDTH_IFMAP-1 downto 0):= (others =>'0');
begin
    data(DATA_WIDTH_ZEROS-1 downto 0) := v(DATA_WIDTH_ZEROS-1+BUS_ZEROES_OFFSET_IFMAP  downto BUS_ZEROES_OFFSET_IFMAP);--DATA_WIDTH_ZEROS-1+BUS_ZEROES_OFFSET downto BUS_ZEROES_OFFSET);
    return data;
end function;


function extract_current_row(v: std_logic_vector) return natural is
    variable row : natural range 0 to IFMAP_ROWS_TILED-1;
begin
    row := to_integer(unsigned(v(DATA_WIDTH_ROW-1+ BUS_ROW_OFFSET downto BUS_ROW_OFFSET)));--DATA_WIDTH_ZEROS-1+BUS_ZEROES_OFFSET downto BUS_ZEROES_OFFSET);
    return row;
end function;


function extract_current_column(v: std_logic_vector) return natural is
    variable column : natural range 0 to IFMAP_COLUMNS_TILED-1;
begin
    column := to_integer(unsigned(v(DATA_WIDTH_COLUMN-1+ BUS_COLUMN_OFFSET downto BUS_COLUMN_OFFSET)));--DATA_WIDTH_ZEROS-1+BUS_ZEROES_OFFSET downto BUS_ZEROES_OFFSET);
    return column;
end function;


end package body bus_unit_pck;
