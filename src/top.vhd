library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pe_pack.all;
use work.core_pck.all;
use work.pe_group_pck.all;
use ieee.std_logic_misc.all;

entity top is
port(
  clk : in std_logic;
  reset : in std_logic
  );
end entity;

architecture arch of top is

  signal request_bus: std_logic;
  signal new_ifmaps,new_kernels: std_logic_vector(PES_PER_GROUP-1 downto 0);
  signal bus_to_mem : std_logic_vector(BUSSIZE-1 downto 0);
  signal out_enable:std_logic;
  signal finished, free : std_logic;
  
  signal stall,finished_PE: std_logic_vector(PES_PER_GROUP-1 downto 0);

signal crossbar_packet, inputs : crossbar_packet_in_array(PES_PER_GROUP-1 downto 0);
signal crossbar_packet_ou : crossbar_packet_out_array(BRAMS_PER_ACCUMULATOR-1 downto 0);
signal empty, finished_out,enable : std_logic;
signal bus_to_pe, bus_from_reg: std_logic_vector(BUSSIZE-1 downto 0);

begin

  PE_group_i : entity work.PE_group
    port map (
      reset       => reset,
      clk         => clk,
      finished_out    => finished,
      new_kernels => new_kernels,
      new_ifmaps  => new_ifmaps,
      bus_to_mem   => bus_to_mem,
     request_bus => request_bus,
      out_enable   => out_enable,
      free  => free
    );
single_accumulator_i : entity work.single_accumulator
    generic map(
    DEPTH => 72,
    NUM_INPUTS => 17,
    ACC_DATA_WIDTH => 24
    )
port map (
  reset      => reset,
  clk        => clk,
  enable     => enable,
  free       => free,
  finished   => finished,
  inputs     => crossbar_packet_ou,
  out_enable => out_enable,
  bus_out    => bus_to_pe
);


end architecture;
