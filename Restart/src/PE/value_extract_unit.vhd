library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

entity value_extract_unit is
port(
  clk : in std_logic;
  reset: in std_logic;
  index: in natural range 0 to INDEX_MAX-1;--EXTRACTION_WIDTH-1;
  shift: in natural range 0 to SHIFT_MAX-1;
  kernel_number: in natural range 0 to KERNELS_PER_PE-1;
  valid_in: in std_logic;
  valid_out: out std_logic;
  new_kernels : in std_logic;
  new_ifmaps : in std_logic;
  kernel_values: in kernel_values_type;
  ifmap_values: in ifmap_values_type;
  zero_point_weight: out unsigned(DATA_WIDTH-1 downto 0);--TODO CHECK!
  zero_point_ifmap: out unsigned(DATA_WIDTH-1 downto 0);
  ifmap : out unsigned(DATA_WIDTH-1 downto 0);
  weight: out signed(DATA_WIDTH-1 downto 0);
  zero_ifmap_new : in unsigned(DATA_WIDTH-1 downto 0);
  zero_kernel_new: in signed(DATA_WIDTH-1 downto 0)

);
end entity;


architecture arch of value_extract_unit is
  signal kernel_values_reg,kernel_values_reg_nxt: kernel_values_type;
  signal ifmap_values_reg, ifmap_bitvecs_reg_nxt: ifmap_values_type;
  signal zero_ifmap_nxt, zero_ifmap: unsigned(DATA_WIDTH-1 downto 0);
  signal zero_kernel_nxt, zero_kernel: unsigned(DATA_WIDTH-1 downto 0);
  signal valid_intern: std_logic;
  signal shift_intern: natural range 0 to SHIFT_MAX-1;
  signal index_intern: natural range 0 to INDEX_MAX-1;
begin

  sync : process(clk,reset)
  begin
    if reset = '0' then
      valid_intern <= '0';
      index_intern <= 0;
      shift_intern <= 0;
      kernel_number_intern <= 0;

    elsif rising_edge(clk) then
      valid_intern <= valid_in;
      index_intern <= index;
      shift_intern <= shift;
      kernel_number_intern <= kernel_number;
    end if;
  end process;
--needs to save new values
--needs to write out values
  outp : process(all)
  variable kernel_number_clc: natural range 0 to NUMBER_OF_KERNELS_PER_PE-1;
  variable ifmap_pos: natural range 0 to VALUES_PER_IFMAP-1;
  variable kernel_pos: natural range 0 to VALUES_PER_KERNEL-1;
  begin
    --default
    ifmap <= (others => '0');
    kernel <= (others => '0');
    ifmap <= (others => '0');
    zero_point_weight <= (others => '0');
    zero_point_ifmap <= (others => '0');
    valid_out <= '0';
    --calc the positon of the ifmap to extract
    ifmap_pos := index_intern mod 6;

    --calc the current ifmap/kernel-z dimension that is extracted
    if index_intern > 11 then
      kernel_number_clc := 2;
    elsif index_intern > 5 then
      kernel_number_clc := 1;
    else
      kernel_number_clc := 0;
    end if;
    if kernel_number_intern = '1' then
      kernel_number_clc := kernel_number_clc +3;
    end if;

    --calculate the kernel position
    kernel_pos := (shift_intern + ifmap_pos) mod VALUES_PER_KERNEL;

    if valid_intern = '1' then
      ifmap <= ifmap_values(kernel_number_clc,ifmap_pos);
      kernel <= ifmap_values(kernel_number_clc,kernel_pos);
      zero_point_weight <= zero_kernel;
      zero_point_ifmap <= zero_ifmap;
      valid_out <= '1';
    end if;

  end process;


  new_values : process(all)
  begin
  if new_kernels = '1' then
    zero_kernel_nxt <= zero_kernel_new;
    kernel_values_reg_nxt <= kernel_values;
  if new_ifmaps = '1' then
    zero_ifmap_nxt <= zero_ifmap_new;
    ifmap_values_reg_nxt <= ifmap_values;
  end if;
  end process;




end architecture;
