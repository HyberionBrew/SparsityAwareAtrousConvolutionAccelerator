library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

entity mult_unit is
  port (
  clk : in std_logic;
  reset: in std_logic;
  weight : in std_logic_vector(DATA_WIDTH-1 downto 0);
  ifmap_value : in std_logic_vector(DATA_WIDTH-1 downto 0);
  result_out : out signed(DATA_WIDTH_RESULT-1 downto 0);
  zero_point_weight : in std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0); --of the QType =  uint8
  zero_point_ifmap : in std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0)
  valid: in std_logic
  );
end entity;


architecture arch of mult_unit is

  signal reg_weight,weight_val, reg_weight_nxt,reg_ifmap,reg_ifmap_nxt :signed(DATA_WIDTH+1-1 downto 0);
  signal ifmap_val_nxt,ifmap_val:  unsigned(DATA_WIDTH-1 downto 0);
  signal kernel_val,kernel_val_nxt : signed(DATA_WIDTH-1 downto 0);
  signal Z_weight, Z_index,Z_weight_nxt,Z_index_nxt : unsigned(DATA_WIDTH-1 downto 0);
  signal result, result_nxt: signed(DATA_WIDTH_RESULT-1 downto 0);
  signal valid_delay: std_logic_vector(1 downto 0);
begin

  sync : process(clk,reset)
  begin
    if reset = '0' then
      reg_weight <= (others => '0');
      reg_ifmap <= (others => '0');
      ifmap_val <= (others => '0');
      kernel_val <= (others => '0');
      result <= (others => '0');
      valid_delay<= "00";

    elsif rising_edge(clk) then
      ifmap_val <= ifmap_val_nxt;
      kernel_val <= kernel_val_nxt;
      Z_weight <= Z_weight_nxt;
      Z_index <= Z_index_nxt;
      reg_weight <= reg_weight_nxt;
      reg_ifmap <= reg_ifmap_nxt;
      result <= result_nxt;
      valid_delay(0) <= valid_in;
      valid_delay(1) <= valid_delay(0);
    end if;
  end process;

  mult : process(all)
  begin
    ifmap_val_nxt <= ifmap_value;
    kernel_val_nxt <= weight;
    Z_weight_nxt <= zero_point_weight;
    Z_index_nxt <= zero_point_ifmap;
    reg_weight_nxt <= (others => '-');
    reg_ifmap_nxt <= (others => '-');
    result_nxt <= (others => '-');
    result_out <= '0';

    if valid = '1' then
      reg_weight_nxt <= to_signed(to_integer(kernel_val)-to_integer(Z_weight), reg_weight_nxt'length);
      reg_ifmap_nxt <= to_signed(to_integer(ifmap_val)-to_integer(Z_index),reg_ifmap_nxt'length);
    end if;
    if valid_delay(0) = '1' then
      result_nxt <= reg_weight) * reg_ifmap; --result is signed
    end if;
    if valid_delay(1) = '1' then
      result_out <= result;
    end if;

  end process;


end architecture;
