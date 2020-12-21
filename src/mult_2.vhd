library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pack.all;
use ieee.std_logic_misc.all;

entity mult_unit is
  port (
  reset, clk: in std_logic;
  weight_val_in : in signed(DATA_WIDTH-1 downto 0);
  ifmap_val_in : in unsigned(DATA_WIDTH-1 downto 0);
  result : out signed(64-1 downto 0);
  Z_weight : in unsigned(DATA_WIDTH-1 downto 0); --of the QType =  uint8
  Z_index : in unsigned(DATA_WIDTH-1 downto 0);
  M0 : in signed(SCALE_MULT_SIZE-1 downto 0);
  n : in unsigned(6-1 downto 0)
  );
end entity;


architecture arch of mult_unit is

  signal ifmap_val :signed(DATA_WIDTH-1 downto 0);

  signal result_mult,result_mult_nxt: signed(SCALE_MULT_SIZE-1 downto 0);
  signal result_scale,result_scale_nxt: signed(SCALE_MULT_SIZE*2-1 downto 0);
  --signal test: sfixed(SCALE_MULT_SIZE*2-1 downto 0);
  signal reg_weight,weight_val, reg_weight_nxt,reg_ifmap,reg_ifmap_nxt :signed(16-1 downto 0);


  function round_away_from_zero(vec : signed(64-1 downto 0); n_in: unsigned(6-1 downto 0)) return signed is
      variable n: unsigned(6-1 downto 0) := to_unsigned(31,6);
      variable result : signed(64-1 downto 0) := (others => '0');
      variable neg : std_logic; --tells if negative

  begin
    n := n_in + 31; -- +31;
    result := (others=> '0');
    if (n < 30) then
        return result;
    end if;
    result := shift_right(vec,to_integer(n));
    neg := std_logic(vec(63));
    if neg = '1' then
        if vec(to_integer(n)-1) = '1' then
            return result + 1;
        else --first place is '1'
            return result;
        end if;
     else -- positve
        if vec(to_integer(n-1)) = '0' then
            return result;

        else --first place is a '1'
            return result +1;
        end if;
     end if;
    return result;
  end function;

begin

  sync : process(clk,reset)
  begin
    if reset = '0' then
      reg_weight <= (others => '0');
      reg_ifmap <= (others => '0');
      result_mult <= (others => '0');
    elsif rising_edge(clk) then
      reg_weight <= reg_weight_nxt;
      reg_ifmap <= reg_ifmap_nxt;
      result_mult <= result_mult_nxt;
      result_scale <= result_scale_nxt;
    end if;
  end process;

  mult : process(all)
  variable x:integer;
  begin

    reg_weight_nxt <= to_signed(to_integer(weight_val_in)-to_integer(Z_weight), reg_weight_nxt'length);
    reg_ifmap_nxt <= to_signed(to_integer(ifmap_val_in)-to_integer(Z_index),reg_ifmap_nxt'length);

    result_mult_nxt <= signed(reg_weight) * signed(reg_ifmap); --result is signed
    result_scale_nxt <= signed(result_mult)* signed(M0);
    result <= round_away_from_zero(result_scale, n); --TODO!TODO!!!!!
    --result <= round_away_from_zero(result_scale,n)
  end process;


end architecture;
