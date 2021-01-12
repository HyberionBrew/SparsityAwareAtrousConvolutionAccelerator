library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use work.pe_group_pck.all;
use ieee.std_logic_misc.all; --for and_reduce

entity index_comp is
  port (
    clk : in std_logic;
    reset: in std_logic;
    stall : in std_logic;
    --weight_index: in unsigned(3 downto 0);
    ifmap_index_in: in natural range 0 to INDEX_MAX-1;
    weight_index_in: in natural range 0 to KERNEL_BITVEC_SIZE-1;
    kernel_number_in: in natural range 0 to KERNELS_PER_PE-1;
    to_index_out: out INDEX_TYPE;
    current_column_in: in natural range 0 to MAX_X; --have to delay this
    current_row_in: in natural range 0 to MAX_Y; --have to also delay this
    kernel_offset_in : in natural range 0 to MAX_KERNEL_OFFSET;
    valid_in : in std_logic;
    valid_out : out std_logic;
    fetch_ifmap: in std_logic;
    fetch_kernel: in std_logic;
    kernel_offset: out natural range 0 to MAX_KERNEL_OFFSET
  );
end entity;

architecture arch of index_comp is
constant DELAY_CYCLES : integer:= 2;
constant INDEX_DELAY_CYCLES : integer := 2;
constant DELAY_CYCLES_IN : integer := 3;
constant DELAY_CYCLES_VALID : integer :=2;

type delay_column is array(0 to DELAY_CYCLES) of natural range 0 to MAX_X;
type delay_row is array(0 to DELAY_CYCLES) of natural range 0 to MAX_Y;
type delay_to_index is array (0 to INDEX_DELAY_CYCLES) of INDEX_TYPE;
signal current_column, current_column_nxt : natural range 0 to MAX_X;
signal current_row, current_row_nxt : natural range 0 to MAX_Y;

signal to_index_nxt, to_index: INDEX_TYPE;

type delay_kernel_number is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNELS_PER_PE-1;
type delay_weight_index is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNEL_BITVEC_SIZE-1;
type delay_ifmap_index is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNELS_PER_PE-1;
type delay_valid_type is array(0 to DELAY_CYCLES_VALID) of std_logic;

signal kernel, kernel_nxt: natural range 0 to KERNEL_BITVEC_SIZE-1;
signal ifmap, ifmap_nxt: natural range 0 to IFMAPS_PER_PE-1;
signal kernel_number_nxt, kernel_number: natural range 0 to KERNELS_PER_PE-1;
signal delay_valid_nxt, delay_valid : delay_valid_type;


signal kernel_offset_nxt: natural range 0 to MAX_KERNEL_OFFSET;

begin

sync : process(clk,reset)
begin
  if reset = '0' then
    current_column <= 2;
    current_row <= 12;
    ifmap <= 3;
    kernel_number <= 0;
    kernel <=  0;
    delay_valid <= (others => '0');
    to_index.w <= 0;
    to_index.xindex <= 0;
    to_index.yindex <= 0;
  elsif rising_edge(clk) then
    current_column <= current_column_nxt;
    current_row <= current_row_nxt;
    ifmap <= ifmap_nxt;
    kernel_number <= kernel_number_nxt;
    kernel <= kernel_nxt;
    delay_valid <= delay_valid_nxt;
    to_index <= to_index_nxt;
    kernel_offset <= kernel_offset_nxt;

  end if;
end process;

set_offset: process(all)
begin
    kernel_offset_nxt <= kernel_offset;
    current_column_nxt <= current_column;
    current_row_nxt <= current_row;

    if fetch_ifmap = '1' then
        current_column_nxt <= current_column_in;
        current_row_nxt <= current_row_in;
    end if;
    if fetch_kernel = '1' then
        kernel_offset_nxt <= kernel_offset_in;
    end if;
end process;


--TOP LEFT IS (0,0)
dely_ins : process(all)
begin
    kernel_nxt <= weight_index_in;
    ifmap_nxt <= ifmap_index_in;
    kernel_number_nxt <= kernel_number_in;
    delay_valid_nxt(DELAY_CYCLES_VALID) <= valid_in;

     for I in 0 to DELAY_CYCLES_VALID-1 loop
        delay_valid_nxt(I)<= delay_valid(I+1);
    end loop;
    valid_out <= delay_valid(0);
end process;


windex : process(all)
begin
  to_index_out <= to_index;
  to_index_nxt.w<= kernel_number;
  to_index_nxt.yindex <= 0;
  to_index_nxt.xindex <= 0;
  if delay_valid(1) = '1' then
    if kernel = 0 or kernel = 1 or kernel = 2 then
      to_index_nxt.yindex <= current_row+ ifmap -6;
    elsif kernel=3 or kernel = 4 or kernel = 5 then
      to_index_nxt.yindex <= ifmap + current_row;
    else
      to_index_nxt.yindex <= ifmap + 6 + current_row ;
    end if;


    if kernel = 0 or kernel = 3 or kernel = 6 then
      to_index_nxt.xindex <= current_column-1;
    elsif kernel=1 or kernel = 4 or kernel = 7 then
      to_index_nxt.xindex <= current_column;
    else
      to_index_nxt.xindex <= current_column+1;
    end if;
  end if;
  
  end process;


end architecture;
