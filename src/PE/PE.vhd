 library ieee;
use ieee.std_logic_1164.all; --do I need this?

use ieee.numeric_std.all;
use work.pe_pack.all;
use work.core_pck.all;
use work.pe_group_pck.all;

--use work.core_pack.all;

entity PE is
  port (

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
  crossbar_packet : out crossbar_packet_in
  );

end entity;

architecture arch of PE is


  signal bitvec          : std_logic;
  signal current_row     : natural range 0 to IFMAP_ROWS_TILED-1;
  signal current_column  : natural range 0 to IFMAP_COLUMNS_TILED-1;
  signal zero_ifmap      : natural range 0 to ZERO_POINTS_MAX-1;
  --signal zero_weights    : ZERO_POINT_KERNEL_ARRAY;
  signal write_from_bus  : std_logic;
  signal fetch_ifmaps,fetch_kernels_bus_to_index_select2    : std_logic;
  signal fetch_kernels,fetch_ifmaps_bus_to_index_select2   : std_logic;
  signal bitvec_bus_to_index_select,bitvec_bus_to_index_select2  : std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0);


  signal index: natural range 0 to 18-1;
  signal shift: natural range 0 to SHIFT_MAX-1;
  signal valid: std_logic;

  signal ifmap_counter : natural range 0 to IFMAPS_PER_PE-1; --TODO!
  signal kernel_counter : natural range 0 to KERNELS_PER_PE-1;
  signal addr_kernel: natural range 0 to MAX_ADDR_KERNEL-1;
  signal addr_ifmap: natural range 0 to MAX_ADDR_IFMAP-1;
  
  signal values : std_logic_vector(MAX_MEM_WIDTH-1 downto 0);
  signal ifmap_value,weight_value: std_logic_vector(DATA_WIDTH-1 downto 0);
  
  signal zeroes:std_logic_vector(ZERO_WIDTH_KERNEL-1 downto 0);
  signal zero_ifmap_out, zero_kernel_out: std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);
  signal addr_kernel_zero : natural range 0 to KERNELS_PER_PE-1;
  
 signal weight_index : natural range 0 to KERNEL_BITVEC_SIZE-1;
 signal index_to_index_comp: natural range 0 to INDEX_MAX-1;

 signal kernel_offset,kernel_offset_reg : natural range 0 to MAX_KERNEL_OFFSET;
  
begin

  bus_unit_i : entity work.bus_unit
  port map (
    clk             => clk,
    reset           => reset,
    stall           => stall,
    new_ifmaps      => new_ifmaps,
    new_kernels     => new_kernels,
    bus_to_pe       => bus_to_pe,
    current_row     => current_row,
    current_column  => current_column,
    zeroes      => zeroes,
    fetch_ifmaps    => fetch_ifmaps,
    fetch_kernels   => fetch_kernels,
    bitvecs         => bitvec_bus_to_index_select,
    values          => values,
    kernel_offset   => kernel_offset
  );

  index_selection_i : entity work.index_selection
  port map (
   clk                 => clk,
    reset               => reset,
   stall               => stall,
    index               => index,
    shift               => shift,
   valid               => valid,
    bitvec_in           => bitvec_bus_to_index_select, --here smth from bus
   fetch_values_ifmap  => fetch_ifmaps,--fetch_ifmaps_bus_to_index_select, --from bus
    fetch_values_kernel => fetch_kernels,--fetch_kernels_bus_to_index_secect, --from bus
    ifmap_counter       => ifmap_counter,
    kernel_counter      => kernel_counter,
    finished            => finished
);

address_comp_i : entity work.address_comp
port map (
  clk            => clk,
  reset          => reset,
  stall          => stall,
  index          => index,
  shift          => shift,
  ifmap_counter  => ifmap_counter,
  kernel_counter => kernel_counter,
  addr_kernel    => addr_kernel,
  addr_ifmap     => addr_ifmap,
  kernel_number_out => addr_kernel_zero,
  weight_index => weight_index,
  index_out => index_to_index_comp
);

index_comp_i : entity work.index_comp
port map (
  clk               => clk,
  reset             => reset,
  stall             => stall,
  ifmap_index_in    => index_to_index_comp,
  weight_index_in   => weight_index,
  kernel_number_in  => addr_kernel_zero,
  to_index_out          => to_index,
  current_column_in => current_column,
  current_row_in    => current_row,
  kernel_offset_in => kernel_offset,
  valid_in => valid,
  valid_out => valid_out,
  fetch_ifmap       => fetch_ifmaps,
  fetch_kernel => fetch_kernels,
  kernel_offset => kernel_offset_reg
 -- crossbar_packet => crossbar_packet
);




value_extraction_i : entity work.value_extraction
port map (
    clk          => clk,
  reset        => reset,
  addr_kernel  => addr_kernel,
  addr_ifmap   => addr_ifmap,
  addr_kernel_zero => addr_kernel_zero,
  valid        => valid,
  values_in    => values,
  zeroes       => zeroes,
  fetch_kernel => fetch_kernels,
  fetch_ifmap  => fetch_ifmaps,
  ifmap_value  => ifmap_value,
  weight_value => weight_value,
  zero_ifmap_out => zero_ifmap_out,
  zero_kernel_out =>  zero_kernel_out
);

mult_unit_i : entity work.mult_unit
port map (
 clk           => clk,
  reset         => reset,
  weight_val_in => weight_value,
  ifmap_val_in  => ifmap_value,
  result        => result,
  Z_weight_in   => zero_kernel_out,
  Z_index_in    => zero_ifmap_out
);

 
 comp_crossbar_packet : process(all)
 variable tag_calc :integer := 0;   
begin
    crossbar_packet.address <= std_logic_vector(to_unsigned((to_index.yindex mod BRAMS_PER_ACCUMULATOR),crossbar_packet.address'length));
    tag_calc := to_index.xindex + to_index.w*6;
    if to_index.yindex > BRAMS_PER_ACCUMULATOR-1 then
        tag_calc := tag_calc + 6*6;
    end if;
    crossbar_packet.tag <= std_logic_vector(to_unsigned(tag_calc,crossbar_packet.tag'length)); 
    crossbar_packet.valid <= valid_out;--consits of y and w, where w is the weight offset 
    crossbar_packet.data <= std_logic_vector(result);
end process;

end architecture;
