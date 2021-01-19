library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use ieee.std_logic_misc.all; --for and_reduce

entity index_comp is
  port (
    clk : in std_logic;
    reset: in std_logic;
    ifmap_index: in natural range 0 to VALUES_PER_IFMAP-1;
    weight_index: in natural range 0 to VALUES_PER_KERNEL-1;
    to_index_out: out INDEX_TYPE;
    current_row_in: in natural range 0 to MAX_Y; --have to also delay this
    valid_in : in std_logic;
    fetch_ifmap: in std_logic
  );
end entity;


architecture arch of index_comp is
signal kernel:  natural range 0 to VALUES_PER_KERNEL-1;
signal ifmap: natural range 0 to VALUES_PER_IFMAP-1;

signal to_index_nxt, to_index: INDEX_TYPE;
constant DELAY_CYCLES :integer := 3; --not used
signal valid_delay : std_logic_vector(DELAY_CYCLES-1 downto 0);
signal current_row, current_row_nxt: natural range 0 to MAX_Y;
begin


sync : process(all)
begin
  if reset = '0' then
    kernel <= 0;
    ifmap <= 0;
    valid_delay <= (others => '0');
  elsif rising_edge(clk) then
    kernel <= weight_index;
    ifmap <= ifmap_index;
    valid_delay(0) <= valid_in;
    to_index <= to_index_nxt;
    to_index_out <= to_index;
    current_row <= current_row_nxt;
  end if;

end process;


set_offset: process(all)
begin
    current_row_nxt <= current_row;
    if fetch_ifmap = '1' then
        current_row_nxt <= current_row_in;
    end if;
end process;


calc_new_index : process(all)
begin

  if valid_delay(0) = '1' then
    if kernel = 0 or kernel = 1 or kernel = 2 then
      to_index_nxt.yindex <= current_row+ ifmap -6;
    elsif kernel=3 or kernel = 4 or kernel = 5 then
      to_index_nxt.yindex <= ifmap + current_row;
    else
      to_index_nxt.yindex <= ifmap + 6 + current_row;
    end if;
    if kernel = 0 or kernel = 3 or kernel = 6 then
      to_index_nxt.xindex <= 0;
    elsif kernel=1 or kernel = 4 or kernel = 7 then
      to_index_nxt.xindex <= 1;
    else
      to_index_nxt.xindex <= 2;
    end if;
  end if;


end process;
end architecture;
