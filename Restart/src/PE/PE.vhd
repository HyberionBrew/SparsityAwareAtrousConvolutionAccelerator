library ieee;
use ieee.std_logic_1164.all; --do I need this?

use ieee.numeric_std.all;
use work.pe_pack.all;
use work.core_pck.all;


entity PE is
  generic(
    NUMBER_OF_IFMAPS: natural := 6;
    NUMBER_OF_KERNELS: natural := 6
  );
  port (
  reset, clk : in std_logic;
  finished : out std_logic;
  new_kernels : in std_logic;
  new_ifmaps : in std_logic;
  kernel_bitvecs: in kernel_bitvecs_type;
  ifmap_bitvecs: in ifmap_bitvecs_type;
  kernel_values: in kernel_values_type;
  ifmap_values: in ifmap_values_type;
  zero_ifmap_new : in unsigned(DATA_WIDTH-1 downto 0);
  zero_kernel_new: in unsigned(DATA_WIDTH-1 downto 0);
  current_row: in natural range 0 to MAX_Y-1
);
end PE;

architecture arch of PE is

  signal index: natural range 0 to INDEX_MAX-1;--EXTRACTION_WIDTH-1;
  signal shift: natural range 0 to SHIFT_MAX-1;

  signal valid_from_fetch_to_extract,valid_from_extract_to_mult,valid_from_mult_to_acc: std_logic;
  signal kernel_number: natural;
  signal zero_point_weight, zero_point_ifmap: unsigned(DATA_WIDTH-1 downto 0);
  signal ifmap_value: unsigned(DATA_WIDTH-1 downto 0);
  signal weight: signed(DATA_WIDTH-1 downto 0);
  signal result: signed(DATA_WIDTH_RESULT-1 downto 0);
  signal norm_ifmap, norm_kernel: natural;
  signal index_to_acc: INDEX_TYPE;
begin


  fetch_unit_i : entity work.fetch_unit
  generic map (
    NUMBER_OF_IFMAPS     => 6,
    NUMBER_OF_KERNELS    => 6,
    SIMULTANEOUS_KERNELS => 3
  )
  port map (
    reset          => reset,
    clk            => clk,
    finished       => finished,
    new_kernels    => new_kernels,
    new_ifmaps     => new_ifmaps,
    kernel_bitvecs => kernel_bitvecs,
    ifmap_bitvecs  => ifmap_bitvecs,
    index          => index,
    shift          => shift,
    kernel_number  => kernel_number,
    valid          => valid_from_fetch_to_extract
  );

  value_extract_unit_i : entity work.value_extract_unit
  port map (
    clk               => clk,
    reset             => reset,
    index             => index,
    shift             => shift,
    kernel_number     => kernel_number,
    valid_in          => valid_from_fetch_to_extract,
    valid_out         => valid_from_extract_to_mult,
    new_kernels       => new_kernels,
    new_ifmaps        => new_ifmaps,
    kernel_values     => kernel_values,
    ifmap_values      => ifmap_values,
    zero_point_weight => zero_point_weight,
    zero_point_ifmap  => zero_point_ifmap,
    ifmap             => ifmap_value,
    weight            => weight,
    zero_ifmap_new    => zero_ifmap_new,
    zero_kernel_new   => zero_kernel_new,
    norm_ifmap        => norm_ifmap,
    norm_kernel       => norm_kernel
  );


  mult_unit_i : entity work.mult_unit
  port map (
    clk               => clk,
    reset             => reset,
    weight            => weight,
    ifmap_value       => ifmap_value,
    result_out        => result,
    zero_point_weight => zero_point_weight,
    zero_point_ifmap  => zero_point_ifmap,
    valid             => valid_from_extract_to_mult
  --  valid_out         => valid_from_mult_to_acc
  );

  index_comp_i : entity work.index_comp
  port map (
    clk            => clk,
    reset          => reset,
    ifmap_index    => norm_ifmap,
    weight_index   => norm_kernel,
    to_index_out   => index_to_acc,
    current_row_in => current_row,
    valid_in       => valid_from_extract_to_mult,
    fetch_ifmap    => new_ifmaps
  );




end architecture;
