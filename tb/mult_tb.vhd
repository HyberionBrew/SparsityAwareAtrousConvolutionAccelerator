library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pack.all;
use std.textio.all;
entity mult_tb is
end entity;

architecture arch of mult_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal clk,reset           : std_logic;
  signal weight_val_in : signed(DATA_WIDTH-1 downto 0);
  signal ifmap_val_in  : unsigned(DATA_WIDTH-1 downto 0);
  signal result        : signed(DATA_WIDTH*8-1 downto 0);
  signal Z_weight      : unsigned(DATA_WIDTH-1 downto 0);
  signal Z_index       : unsigned(DATA_WIDTH-1 downto 0);
  signal M0            : signed(SCALE_MULT_SIZE-1 downto 0);
  signal n             : unsigned(6-1 downto 0);
  constant MSG_ASSERTION_FAILED : string(1 to 18) := "Assertion failed: ";
  constant SPACE : string(1 to 1) := " ";
begin

  mult_unit_i : entity work.mult_unit 
  port map (
    clk           => clk,
    reset => reset,
    weight_val_in => weight_val_in,
    ifmap_val_in  => ifmap_val_in,
    result        => result,
    Z_weight      => Z_weight,
    Z_index       => Z_index,
    M0            => M0,
    n             => n
  );

  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  stim : process
  file infile : text open read_mode is "mult.txt";
  file outfile : text open write_mode is "/home/fabian/Documents/Bachelorarbeit/VHDL/tb/testdata/outmult.txt";
  variable inline, outline : line;
  variable s: string(1 to 10) := (others => '%');
  
   procedure get_word_from_line (variable l : inout line; variable s: inout string) is
        variable c : character;
        variable i : natural := 1;
        variable length : natural;
    begin
        length := s'high-s'low + 1;
        read(l, c);
        while not (c = ';' OR i > length) loop
            s(i) := c;
            i := i + 1;
            read(l, c);
        end loop;
    end procedure get_word_from_line;
  
  
  variable int : integer;
  variable result_should : integer;
  variable zero_offset : integer;
  variable real_result: integer;
  begin
    readline(infile, inline); --header
    reset <= '0';
    wait for CLK_PERIOD;
    reset <= '1';
    while not endfile(infile) loop
        readline(infile,inline);
        --get_word_from_line(inline, s);
        read(inline,int);
        M0 <= to_signed(int,M0'length);--integer'value(s),M0'length);
       -- get_word_from_line(inline,s);
        read(inline,int);
        n <= to_unsigned(int,n'length);
      --  get_word_from_line(inline,s);
        read(inline,int);
        Z_index <= to_unsigned(int,Z_index'length);
      --  get_word_from_line(inline,s);
        read(inline,int);
        Z_weight <= to_unsigned(int,Z_weight'length);
      --  get_word_from_line(inline,s);
        --Z_out <= to_unsigned(integer'value(s),Z_index'length);
        read(inline,int);
        zero_offset := int;
        read(inline,int);
        weight_val_in <= to_signed(int,weight_val_in'length);
        read(inline,int);
        ifmap_val_in <= to_unsigned(int,ifmap_val_in'length);
        read(inline,int);
        result_should := int; 
        wait for CLK_PERIOD * 3;
        real_result := to_integer((result)) + zero_offset;
        assert (result_should = to_integer((result)+zero_offset)) report "Assertion failed." severity warning;
        report "Result should be " & integer'image(result_should)& "is:" & integer'image(real_result);
        if not(result_should = real_result) then
            write(outline, MSG_ASSERTION_FAILED);
            write(outline, integer'image(result_should));
            write(outline, SPACE);
            write(outline, integer'image(real_result));
            write(outline, SPACE);
            write(outline, integer'image(to_integer(M0)));
            --write(outline,)
            writeline(outfile,outline);
        end if;
    end loop;
    
    

    weight_val_in <= to_signed(-54,weight_val_in'length);
    ifmap_val_in <= to_unsigned(128, ifmap_val_in'length);
    Z_weight <= to_unsigned(74, Z_weight'length);
    Z_index <= to_unsigned(86, Z_index'length);
    M0 <= to_signed(1195718895, M0'length);
    n <= to_unsigned(6, n'length);
    wait for CLK_PERIOD;
    reset <= '0';
    wait;
  end process;







end architecture;
