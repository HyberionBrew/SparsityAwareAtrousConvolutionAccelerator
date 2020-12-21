library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;

entity mult_unit is
  port (
  reset, clk: in std_logic;
  weight_val_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
  ifmap_val_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
  result : out signed(DATA_WIDTH_RESULT-1 downto 0);
  Z_weight_in : in std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0); --of the QType =  uint8
  Z_index_in : in std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0)
  );
end entity;


architecture arch of mult_unit is

  --signal ifmap_val :signed(DATA_WIDTH-1 downto 0);

 -- signal result_mult,result_mult_nxt: signed(SCALE_MULT_SIZE-1 downto 0);
 -- signal result_scale,result_scale_nxt: signed(SCALE_MULT_SIZE*2-1 downto 0);
  --signal test: sfixed(SCALE_MULT_SIZE*2-1 downto 0);
  signal reg_weight,weight_val, reg_weight_nxt,reg_ifmap,reg_ifmap_nxt :signed(DATA_WIDTH+1-1 downto 0);
   
  signal kernel_val, ifmap_val : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal Z_weight, Z_index : std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);

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
      ifmap_val <= (others => '0');
      kernel_val <= (others => '0');
      
    elsif rising_edge(clk) then
      ifmap_val <= ifmap_val_in;
      kernel_val <= weight_val_in;
      Z_weight <= Z_weight_in;
      Z_index <= Z_index_in;
      reg_weight <= reg_weight_nxt;
      reg_ifmap <= reg_ifmap_nxt;
    end if;
  end process;

  mult : process(all)
  variable x:integer;
  begin
    
    reg_weight_nxt <= to_signed(to_integer(signed(kernel_val))-to_integer(unsigned(Z_weight)), reg_weight_nxt'length);
    reg_ifmap_nxt <= to_signed(to_integer(unsigned(ifmap_val))-to_integer(unsigned(Z_index)),reg_ifmap_nxt'length);

    result <= signed(reg_weight) * signed(reg_ifmap); --result is signed
   -- result_scale_nxt <= signed(result_mult)* signed(M0);
    --result <= round_away_from_zero(result_scale, n); --TODO!TODO!!!!!
    --result <= round_away_from_zero(result_scale,n)
  end process;


end architecture;
