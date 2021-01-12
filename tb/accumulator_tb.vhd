library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use work.pe_group_pck.all;
use work.test_utils.all;
use std.textio.all;


entity accumultor_tb is
end entity;


architecture arch of accumultor_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal clk,reset, request_bus, finished, finished_out, out_enable, free, new_kernels: std_logic;
  signal to_bus: std_logic_vector(BUSSIZE-1 downto 0);
  signal inputs : crossbar_packet_out_array(6-1 downto 0);


begin
  accumulators_i : entity work.accumulators

generic map (
  NUM_INPUTS         => 6,
  DEPTH              => 72,
  ACC_DATA_WIDTH     => 24,
  DELAY_FINISHED_CLK => 2
  )
  port map (
    reset        => reset,
    clk          => clk,
    inputs       => inputs,
    request_bus  => request_bus,
    finished     => finished,
    finished_out => finished_out,
    out_enable   => out_enable,
    free         => free,
    to_bus       => to_bus
  );


clock : process
begin
  clk <= '0';
  wait for CLK_PERIOD/2;
  clk <= '1';
  wait for CLK_PERIOD/2;
end process;

stim : process
begin
  reset <= '0';
  finished <= '1';
  out_enable <= '0';
  wait for CLK_PERIOD;
  reset <= '1';
  wait for CLK_PERIOD;
  finished <= '0';
  for x in 0 to 4 loop
    for i in 0 to 5 loop
      inputs(i) <= (std_logic_vector(to_unsigned(1,DATA_WIDTH_RESULT)),std_logic_vector(to_unsigned(5,CROSSBAR_TAG_WIDTH)),'1');
    end loop;
  wait for CLK_PERIOD;
  for i in 0 to 5 loop
    inputs(i) <= (std_logic_vector(to_unsigned(3,DATA_WIDTH_RESULT)),std_logic_vector(to_unsigned(0,CROSSBAR_TAG_WIDTH)),'1');
  end loop;
wait for CLK_PERIOD;
for i in 0 to 5 loop
  inputs(i) <= (std_logic_vector(to_unsigned(1,DATA_WIDTH_RESULT)),std_logic_vector(to_unsigned(71,CROSSBAR_TAG_WIDTH)),'1');
end loop;
wait for CLK_PERIOD;
for i in 0 to 5 loop
  inputs(i) <= (std_logic_vector(to_unsigned(2,DATA_WIDTH_RESULT)),std_logic_vector(to_unsigned(72,CROSSBAR_TAG_WIDTH)),'1');
end loop;
wait for CLK_PERIOD;
  end loop;
      for i in 0 to 5 loop
  inputs(i) <= (std_logic_vector(to_unsigned(10,DATA_WIDTH_RESULT)),std_logic_vector(to_unsigned(0,CROSSBAR_TAG_WIDTH)),'0');
    end loop;
  finished <= '1';
  wait for CLK_PERIOD;
  while request_bus = '0' loop
    wait for CLK_PERIOD;
  end loop;
--  wait for CLK_PERIOD/2;
 --wait for CLK_PERIOD * 4;
  out_enable <= '1';
  wait for CLK_PERIOD*(72+2);
  out_enable <= '0';

  wait;
end process;


end architecture;
