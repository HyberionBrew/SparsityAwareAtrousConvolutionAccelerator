library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;

use work.core_pck.all;

entity bus_driver is
  port (
  clk : in std_logic;
  reset: in std_logic;
  bus_to_mem: inout std_logic_vector(BUSSIZE-1 downto 0);
  request_granted: in std_logic;
  bus_to_pe: out std_logic_vector(BUSSIZE-1 downto 0);
  bus_from_reg: in std_logic_vector(BUSSIZE-1 downto 0);
  new_ifmaps: in std_logic;
  new_kernels: in std_logic
  );
end entity;

architecture arch of bus_driver is


begin
  bus_to_mem <= bus_from_reg when request_granted = '1' else (others => 'Z');
  bus_to_pe <= bus_to_mem when new_ifmaps='1'  or new_kernels = '1' else (others => 'U'); 
end architecture;
