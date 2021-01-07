library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.pe_group_pck.all;
use work.pe_pack.all;
use work.core_pck.all;
use work.crossbar_pkg.all;



entity PE_group is
port(
  reset: in std_logic;
  clk : in std_logic;
  finished_out: out std_logic;
  new_kernels: in std_logic_vector(PES_PER_GROUP-1 downto 0);--just to debug change to std_logic
  new_ifmaps: in std_logic_vector(PES_PER_GROUP-1 downto 0);
  bus_to_mem: inout std_logic_vector(BUSSIZE-1 downto 0);
  request_bus : out std_logic;
  out_enable   : in std_logic;
  free   : out std_logic
 -- crossbar_packet_ou: out crossbar_packet_out_array(BRAMS_PER_ACCUMULATOR-1 downto 0) --only for test synth
);
end entity;

architecture arch of PE_group is


signal stall,finished_PE: std_logic_vector(PES_PER_GROUP-1 downto 0);

signal crossbar_packet : crossbar_packet_in_array(PES_PER_GROUP-1 downto 0);
signal crossbar_packet_ou : crossbar_packet_out_array(BRAMS_PER_ACCUMULATOR-1 downto 0);
signal empty, finished : std_logic;
signal bus_to_pe, bus_from_reg: std_logic_vector(BUSSIZE-1 downto 0);

begin

bus_driver_i : entity work.bus_driver
port map (
  clk             => clk,
  reset           => reset,
  bus_to_mem      => bus_to_mem,
  request_granted => out_enable,
  bus_to_pe       => bus_to_pe,
  bus_from_reg    => bus_from_reg,
  new_ifmaps      => OR_REDUCE(new_ifmaps),
  new_kernels     => OR_REDUCE(new_kernels)

);




PEs : for i in 0 to PES_PER_GROUP-1 generate
    PE_i : entity work.PE
    port map (
      reset           => reset,
      clk             => clk,
      stall           => stall(i),
      finished        => finished_PE(i),
      new_kernels     => new_kernels(i),
      new_ifmaps      => new_ifmaps(i),
      want_new_values => open,
      bus_to_pe       => bus_to_pe,
      result          => open, --deprecated
      to_index        => open, --deprectaed
      valid_out       => open, --deprcated
      crossbar_packet => crossbar_packet(I) --valid
    );
    end generate;
    
crossbar_i : entity work.crossbar 
    generic map (
      NUM_INPUTS   => PES_PER_GROUP,
      NUM_OUTPUTS  => BRAMS_PER_ACCUMULATOR,
      ADDR_WIDTH   => CROSSBAR_ADDRESS_WIDTH,
      TAG_WIDTH    => CROSSBAR_TAG_WIDTH,
      DATA_WIDTH   => DATA_WIDTH_RESULT,
      FIFO_DEPTH   => FIFO_DEPTH,
      FIFO_ALMOST_FULL => FIFO_MAX_DELAY+2, --DELAY +2
      ENABLE_CYCLE => true--true
    )
    port map (
      clk       => clk, --done
      res       => reset, --done
      valid_in  => '1', --done
      empty_out     => empty,
      ready_in  => (others => '1'), --alway true
      inputs    => crossbar_packet, --done
      stall_out => stall,
      outputs   => crossbar_packet_ou
    );



accumulators_i : entity work.accumulators
generic map (
  NUM_INPUTS     => BRAMS_PER_ACCUMULATOR,
  DEPTH          => KERNELS_PER_PE*6*2,--6 ist the max x-width! 2 is for two x values per array
  ACC_DATA_WIDTH => 24,
  DELAY_FINISHED_CLK => 2
)
port map (
  reset       => reset,
  clk         => clk,
  inputs      => crossbar_packet_ou,
  request_bus => request_bus, --change TODO!
  finished    => finished,
  finished_out    => finished_out, --Delays the finished such that the accumulators are properly switched 
  out_enable  => out_enable,
  free        => free,
  new_kernels => OR_REDUCE(new_kernels), --todo!
  to_bus      => bus_from_reg --change

);


comp_finished: process(all)
begin
  finished <= AND_REDUCE(finished_PE) and empty;
end process;


end architecture;
