library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

use std.textio.all;
use work.test_utils.all;


entity PE_tb is
end entity;

architecture arch of PE_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal clk,reset: std_logic;
  --index select
  signal new_kernels, new_ifmaps, finished: std_logic;

  signal kernel_bitvecs: kernel_bitvecs_type;
  signal ifmap_bitvecs: ifmap_bitvecs_type;
  signal kernel_values: kernel_values_type;
  signal ifmap_values: ifmap_values_type;
  signal zero_ifmap_new, zero_kernel_new: unsigned(DATA_WIDTH-1 downto 0);
  signal current_row : natural range 0 to MAX_Y-1;
begin

  PE_i : entity work.PE
  generic map (
    NUMBER_OF_IFMAPS  => 6,
    NUMBER_OF_KERNELS => 6
  )
  port map (
    reset           => reset,
    clk             => clk,
    finished        => finished,
    new_kernels     => new_kernels,
    new_ifmaps      => new_ifmaps,
    kernel_bitvecs  => kernel_bitvecs,
    ifmap_bitvecs   => ifmap_bitvecs,
    kernel_values   => kernel_values,
    ifmap_values    => ifmap_values,
    zero_ifmap_new  => zero_ifmap_new,
    zero_kernel_new => zero_kernel_new,
    current_row     => current_row
  );



--  PE_t : entity work.PE
--  port map(
--    reset => reset,
--    clk => clk,
--    index => index
--  );

  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;


  stim : process
  begin
    reset <= '1';
    wait;
  end process;


end architecture;
