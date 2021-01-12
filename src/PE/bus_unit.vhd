library ieee;
use ieee.std_logic_1164.all; --do I need this?

use ieee.numeric_std.all;
use work.bus_unit_pck.all;
use work.pe_pack.all;
use work.core_pck.all;

--careful with stall!!!! need to set finished to low if stall and stuff
entity bus_unit is
  port (
  clk : in std_logic;
  reset: in std_logic;
  stall: in std_logic;
  new_ifmaps : in std_logic;
  new_kernels : in std_logic;
  bus_to_pe : in std_logic_vector(BUSSIZE-1 downto 0);
  current_row : out natural range 0 to IFMAP_ROWS_TILED-1; --33
  current_column : out natural range 0 to IFMAP_COLUMNS_TILED-1; --6
  zeroes : out std_logic_vector (ZERO_WIDTH_KERNEL-1 downto 0);
  --zero_weights : out ZERO_POINT_KERNEL_ARRAY;
  -- only for index_select
  fetch_ifmaps : out std_logic;
  fetch_kernels : out std_logic;
  bitvecs : out std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0);
  values : out std_logic_vector(MAX_MEM_WIDTH-1 downto 0);
  kernel_offset: out natural range 0 to MAX_KERNEL_OFFSET-1
  );
end entity;


architecture arch of bus_unit is


begin
    --repsonsible for extracting the bitvecs and writing them to the index_selection unit
    current_row_col_forward: process(all)
    begin
        current_row <= 0;
        current_column <= 0;
        if new_ifmaps = '1' then
            current_row <= extract_current_row(bus_to_pe);
            current_column <= extract_current_column(bus_to_pe);
        end if;
    end process;
    
    
    bitvec_calc : process(all)  --done
    begin
      fetch_ifmaps <= '0';
      fetch_kernels <= '0';
      bitvecs <= (others => '0');
      if new_ifmaps = '1' then
        fetch_ifmaps <= '1';
        bitvecs <= extract_bitvecs_ifmaps(bus_to_pe);
      elsif new_kernels = '1' then
        fetch_kernels <= '1';
        bitvecs <= extract_bitvecs_kernels(bus_to_pe);
      end if;
    end process;
    
    data_forward :process(all) --done
    begin
        values <= (others => '0');
        if new_ifmaps = '1' then
            values <= extract_data_ifmap(bus_to_pe);
         elsif new_kernels = '1' then
            values <= extract_data_kernel(bus_to_pe);
         end if;
    end process;
    
    zeroes_forward: process(all)
    begin
        zeroes <= (others => '0');
        if new_ifmaps = '1' then
            zeroes(ZERO_WIDTH_IFMAP-1 downto 0) <= extract_zeroes_ifmap(bus_to_pe);
        elsif new_kernels = '1' then
            zeroes <= extract_zeroes_kernel(bus_to_pe);
        end if;
    end process;
    
    kernel_offset_forward: process(all)
    begin
        kernel_offset <=  0;
        if new_kernels = '1' then
            kernel_offset <= extract_kernel_offset(bus_to_pe);
        end if;
    
    end process;
    
    
    
    --values : process(all)
  --  begin


  --  end process;


end architecture;
