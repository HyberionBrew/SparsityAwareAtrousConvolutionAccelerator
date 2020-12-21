library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.pe_pack.all;

entity weight_calc_unit is
  port (
  clock : in std_logic;
  reset: in std_logic;
  shift : in unsigned(SHIFT_SIZE-1 downto 0);
  index : in unsigned(INDEX_SIZE-1 downto 0);
  weight_index : out unsigned(3-1 downto 0);
  weight_group: out unsigned(CONCURRENT_KERNELS_BITSIZE-1 downto 0)
  );
end entity;

architecture arch of weight_calc_unit is
begin

  sync : process(clk,reset)
  begin
    if reset = '0' then
      shift_intern <= (others => '0');
      index_intern <= (others => '0');
    elsif rising_edge(clk) then
      shift_intern <= shift;
      index_intern <= index;
    end if;
  end process;

  calc_weight : process(all)
  variable tmp: unsigned(INDEX_SIZE-1 downto 0);
  begin
    tmp := index_intern;
    weight_group <= "0";
    if to_integer(index_intern)>5 then
      tmp := index_intern - 6;
      weight_group <= "1";
    end if;
    tmp := tmp + shift;
    weight_index <= tmp(3) and not(and_reduce(tmp 2 downto 0));
  end process;



end architecture;
