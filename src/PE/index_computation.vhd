library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use ieee.std_logic_misc.all; --for and_reduce

entity index_comp is
  port (
    reset, clk: in std_logic;
    stall : in std_logic;
    --weight_index: in unsigned(3 downto 0);
    ifmap_index_in: in natural range 0 to INDEX_MAX-1;
    weight_index_in: in natural range 0 to KERNEL_BITVEC_SIZE-1;
    kernel_number_in: in natural range 0 to KERNELS_PER_PE-1;
    to_index: out INDEX_TYPE;
    current_column_in: in natural range 0 to MAX_X; --have to delay this
    current_row_in: in natural range 0 to MAX_Y; --have to also delay this
    valid_in : in std_logic;
    valid_out : out std_logic;
    fetch_ifmap: in std_logic
  );
end entity;

architecture arch of index_comp is
constant DELAY_CYCLES : integer:= 2;
constant INDEX_DELAY_CYCLES : integer := 2;
constant DELAY_CYCLES_IN : integer := 3;
constant DELAY_CYCLES_VALID : integer :=4;

type delay_column is array(0 to DELAY_CYCLES) of natural range 0 to MAX_X;
type delay_row is array(0 to DELAY_CYCLES) of natural range 0 to MAX_Y;
type delay_to_index is array (0 to INDEX_DELAY_CYCLES) of INDEX_TYPE;
signal current_column, current_column_nxt : delay_column;
signal current_row, current_row_nxt : delay_row;

signal to_index_nxt : delay_to_index;

type delay_kernel_number is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNELS_PER_PE-1;
type delay_weight_index is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNEL_BITVEC_SIZE-1;
type delay_ifmap_index is array(0 to DELAY_CYCLES_IN) of natural range 0 to KERNELS_PER_PE-1;
type delay_valid_type is array(0 to DELAY_CYCLES_VALID) of std_logic;

signal kernel, kernel_nxt: delay_weight_index;
signal ifmap, ifmap_nxt: delay_ifmap_index;
signal kernel_number_nxt, kernel_number: delay_kernel_number;
signal delay_valid_nxt, delay_valid : delay_valid_type;
begin

sync : process(clk,reset)
begin
  if reset = '0' then
    current_column <= (others => 0);
    current_row <= (others => 0);
        ifmap <= (others => 0);
    kernel_number <= (others => 0);
    kernel <= (others => 0);
    delay_valid <= (others => '0');
  elsif rising_edge(clk) then
    current_column <= current_column_nxt;
    current_row <= current_row_nxt;
    ifmap <= ifmap_nxt;
    kernel_number <= kernel_number_nxt;
    kernel <= kernel_nxt;
    delay_valid <= delay_valid_nxt;
  end if;
end process;

set_offset: process(all)
begin
    for I in 0 to DELAY_CYCLES-1 loop
        current_column_nxt(I)<= current_column(I+1);
        current_row_nxt(I)<= current_row(I+1);
    end loop;
    if fetch_ifmap = '1' then
        current_column_nxt(DELAY_CYCLES) <= current_column_in;
        current_row_nxt(DELAY_CYCLES) <= current_row_in; 
    end if;
end process;


--TOP LEFT IS (0,0)
dely_ins : process(all)
begin
    kernel_nxt(DELAY_CYCLES_IN) <= weight_index_in;
    ifmap_nxt(DELAY_CYCLES_IN) <= ifmap_index_in;
    kernel_number_nxt(DELAY_CYCLES_IN) <= kernel_number_in;
    delay_valid_nxt(DELAY_CYCLES_VALID) <= valid_in;
    
    for I in 0 to DELAY_CYCLES_IN-1 loop 
        kernel_nxt(I)<= kernel(I+1);
        ifmap_nxt(I)<= ifmap(I+1);
        kernel_number_nxt(I) <= kernel_number(I+1);
    end loop;
    
     for I in 0 to DELAY_CYCLES_VALID-1 loop 
        delay_valid_nxt(I)<= delay_valid(I+1);
    end loop;
    valid_out <= delay_valid(0);
end process;


windex : process(all)
begin

  to_index.w<= kernel_number(0);  
  to_index.yindex <= 0;
  to_index.xindex <= 0;
  
  if kernel(0) = 0 or kernel(0) = 1 or kernel(0) = 2 then
    to_index.yindex <= current_row(0)+ ifmap(0) -6;
  elsif kernel(0)=3 or kernel(0) = 4 or kernel(0) = 5 then
    to_index.yindex <= ifmap(0) + current_row(0);
  else
    to_index.yindex <= ifmap(0) + 6 + current_row(0);
  end if;


  if kernel(0) = 0 or kernel(0) = 3 or kernel(0) = 6 then
    to_index.xindex <= current_column(0)-1;
  elsif kernel(0)=1 or kernel(0) = 4 or kernel(0) = 7 then
    to_index.xindex <= current_column(0);
  else
    to_index.xindex <= current_column(0)+1;
  end if;
end process;
end architecture;
