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
    ifmap_index_in: in natural range 0 to INDEX_MAX-1;
    weight_index_in: in natural range 0 to KERNEL_BITVEC_SIZE-1;
    to_index_out: out INDEX_TYPE;
    current_column_in: in natural range 0 to MAX_X; --have to delay this
    current_row_in: in natural range 0 to MAX_Y; --have to also delay this
    valid_in : in std_logic;
    valid_out : out std_logic;
    fetch_ifmap: in std_logic;
    fetch_kernel: in std_logic
  );
end entity;
