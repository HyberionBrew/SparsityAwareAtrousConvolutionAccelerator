library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

entity address_comp is
  port (
  clk : in std_logic;
  reset: in std_logic;
  stall : in std_logic;
  index: in natural range 0 to INDEX_MAX-1;--EXTRACTION_WIDTH-1;
  shift: in natural range 0 to SHIFT_MAX-1;
  ifmap_counter : in natural range 0 to IFMAPS_PER_PE-1; --TODO!
  kernel_counter : in natural range 0 to KERNELS_PER_PE-1;
  addr_kernel: out natural range 0 to MAX_ADDR_KERNEL-1;
  addr_ifmap: out natural range 0 to MAX_ADDR_IFMAP-1;
  kernel_number_out: out natural range 0 to KERNELS_PER_PE-1;
  weight_index : out natural range 0 to KERNEL_BITVEC_SIZE-1;
  index_out: out natural range 0 to INDEX_MAX-1
  );
end entity;



architecture arch of address_comp is


signal shift_intern: natural range 0 to SHIFT_MAX-1;--EXTRACTION_WIDTH-1;
signal index_intern: natural range 0 to INDEX_MAX-1;
signal ifmap_counter_intern:  natural range 0 to IFMAPS_PER_PE-1;
signal kernel_counter_intern:  natural range 0 to KERNELS_PER_PE-1;
signal index_out_nxt: natural range 0 to INDEX_MAX-1;
constant KERNEL_OFFSET_C, IFMAP_OFFSET_C : natural := 32;

begin
  sync : process(clk,reset)
  begin
    if reset = '0' then
      shift_intern <= 0;
      index_intern <= 0;
      ifmap_counter_intern <= 0;
      kernel_counter_intern <= 0;
    elsif rising_edge(clk) then
      shift_intern <= shift;
      index_intern <= index;
      ifmap_counter_intern <= ifmap_counter;
      kernel_counter_intern <= kernel_counter;

    end if;

  end process;

  comp_out : process(all)
  variable kernel_number: natural range 0 to SIMULTANEOUS_KERNELS-1;
  variable index_norm : natural range 0 to VALUES_PER_IFMAP-1;
  variable calc_kernel : natural range 0 to KERNEL_BITVEC_SIZE-1;
  variable kernel_offset :natural range 0 to MAX_ADDR_KERNEL-1;
  variable ifmap_offset :natural range 0 to MAX_ADDR_KERNEL-1;
  begin
    index_out <= index_intern;
    --calculate address offset, could write this mpre general in a for loop
    if ifmap_counter_intern > IFMAPS_PER_BUS_ACCESS-1 then
        ifmap_offset :=  IFMAP_OFFSET_C + (ifmap_counter_intern-IFMAPS_PER_BUS_ACCESS)*VALUES_PER_IFMAP;
    else 
        ifmap_offset :=  (ifmap_counter_intern)*VALUES_PER_IFMAP;
    end if;
    
    if kernel_counter_intern > 0 then
        kernel_offset :=  KERNEL_OFFSET_C;
    else 
        kernel_offset :=  0;
    end if;
    --first we need to take the index %6
    addr_ifmap <= (index_intern mod IFMAP_BITVEC_SIZE) + ifmap_offset;--to_integer(OFFSET_IFMAP_AR(to_integer(current_ifmap))),addra_ifmap'length));

    --calculate which of the 3 kernels is triggered
    for I in 1 to SIMULTANEOUS_KERNELS loop
      if index_intern >= VALUES_PER_IFMAP * (I-1) and index_intern < VALUES_PER_IFMAP * I then
        kernel_number := I-1;
        index_norm := index_intern - VALUES_PER_IFMAP * (I-1);
        exit;
      end if;
    end loop;
    calc_kernel := (shift_intern + index_norm) mod KERNEL_BITVEC_SIZE;
    addr_kernel <= calc_kernel + kernel_number * VALUES_PER_KERNEL + kernel_offset; --TODO create array for this
    kernel_number_out <= kernel_number + kernel_counter_intern * SIMULTANEOUS_KERNELS;
    weight_index <= calc_kernel;
    index_out <= index_norm;
  end process;

end architecture;
