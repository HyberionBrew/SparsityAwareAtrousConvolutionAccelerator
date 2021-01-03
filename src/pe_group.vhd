library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.pe_group_pck.all;
use work.core_pck.all;



entity PE_group is
port(
  reset: in std_logic;
  clk : in std_logic;
  finished: out std_logic;
  new_kernels: out std_logic;
  new_ifmaps: out std_logic_vector(PES_PER_GROUP-1 downto 0);
  bus_to_pe: in std_logic_vector(BUSSIZE-1 downto 0)
);
end entity;

architecture arch of PE_group is

type array_std_logic is array(PES_PER_GROUP-1 downto 0) of std_logic;
signal stall: array_std_logic;
signal want_new_values: array_std_logic;

signal crossbar_packet : crossbar_packet_in;
signal finished_PE: array_std_logic;

begin

PEs : for i in 0 to PES_PER_GROUP-1 generate
    PE_i : work.PE
    port map (
      clk             => clk,
      stall           => stall(i),
      finished        => finished_PE(i),
      new_kernels     => new_kernels,
      new_ifmaps      => new_ifmaps(i),
      want_new_values => open,
      bus_to_pe       => bus_to_pe,
      result          => open, --deprectaed
      to_index        => open, --deprectaed
      valid_out       => open, --deprcated
      crossbar_packet => crossbar_packet --valid
    );
    
crossbar_i : work.crossbar 
    generic map (
      NUM_INPUTS   => PES_PER_GROUP,
      ADDR_WIDTH   => CROSSBAR_ADDRESS_WIDTH,
      TAG_WIDTH    => CROSSBAR_TAG_WIDTH,
      DATA_WIDTH   => DATA_WIDTH_RESULT,
      FIFO_DEPTH   => FIFO_DEPTH,
      FIFO_ALMOST_FULL => DELAY_CYCLES+2, --DELAY +2
      ENABLE_CYCLE => true--true
    )
    port map (
      clk       => clk, --done
      res       => reset, --done
      valid_in  => valid_in, --done
      ready_in  => ready_in, --alway true
      inputs    => inputs, --done
      stall_out => stall,
      outputs   => outputs
    );


end architecture;
