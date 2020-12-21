library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pe_pack.all;
use std.textio.all;

entity index_comp_tb is
end entity;
architecture arch of index_comp_tb is
    constant SPACE : string(1 to 1) := " ";
    constant CLK_PERIOD : time := 20 ns;
    signal clk            : std_logic;
    signal reset            : std_logic;
    signal stall          : std_logic;
    signal ifmap_index    : unsigned(IFMAP_INDEX_SIZE-1 downto 0);
    signal index          : unsigned(INDEX_SIZE-1 downto 0);
    signal shift          : unsigned(SHIFT_SIZE-1 downto 0);
    signal to_index       : INDEX_TYPE;
    signal current_column : unsigned(COLUMN_INDEX_SIZE-1 downto 0);
    signal current_row : unsigned(ROW_INDEX_SIZE-1 downto 0);

begin
  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  index_comp_i : entity work.index_comp
  port map(
    clk            => clk,
    reset           => reset,
    stall          => stall,
    --ifmap_index    => ifmap_index,
    index_in          => index,
    shift_in          => shift,
    to_index       => to_index,
    current_column => current_column,
    current_row => current_row
  );

  stim : process
  file infile : text open read_mode is "indexcomp.txt"; --here this works with read_mode
  file outfile : text open write_mode is "/home/fabian/Documents/Bachelorarbeit/VHDL/tb/testdata/indexcompout.txt"; -- if not full pathname crashes with write_mode?? WUT??
  variable inline, outline : line;
  variable s: string(1 to 10) := (others => '%');
  variable int : integer;
   variable x_should, y_should : integer;
   constant ERROR : string(1 to 5) := "ERROR";
  begin
  --readline(infile, inline); --header
  reset <= '0';
  wait for CLK_PERIOD;
  reset <= '1';
  while not(endfile(infile)) loop
    readline(infile,inline);
    read(inline,int);
    write(outline,int);
    write(outline,SPACE);
    current_column <= to_unsigned(int,current_column'length);
    read(inline,int);
    write(outline,int);
    write(outline,SPACE);
    current_row <= to_unsigned(int,current_row'length);
    read(inline,int);
    write(outline,int);
    write(outline,SPACE);
    index <= to_unsigned(int,index'length);
    read(inline,int);
    write(outline,int);
    write(outline,SPACE);
    shift <= to_unsigned(int,shift'length);
    read(inline,int);
    write(outline,int);
    write(outline,SPACE);
    x_should :=int;
    read(inline,int);
    y_should := int;
    write(outline,int);
    write(outline,SPACE);
    wait for CLK_PERIOD*3;
    assert(x_should = to_integer(to_index.xindex)) report "Assertion failed,x_should " & integer'Image(x_should) & " Is " & integer'Image(to_integer(to_index.xindex)) severity WARNING;
     assert(y_should = to_integer(to_index.yindex)) report "Assertion failed,y_should " & integer'Image(y_should) & " Is " & integer'Image(to_integer(to_index.yindex)) severity WARNING;
    if not(x_should = to_integer(to_index.xindex) and (y_should = to_integer(to_index.yindex))) then
        write(outline,ERROR);
        write(outline,SPACE);
        write(outline,integer'Image(to_integer(to_index.xindex)));
        write(outline,SPACE);
        write(outline,integer'Image(to_integer(to_index.yindex)));
        writeline(outfile,outline);
    else
        writeline(outfile,outline);
    end if;
  end loop;
  wait;
  end process;


end architecture;
