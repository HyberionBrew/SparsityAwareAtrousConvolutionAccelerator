library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pack.all;
use work.pe_pack.all;
use std.textio.all;


entity index_selection_tb is
end entity;

architecture arch of index_selection_tb is

  signal clk,reset              : std_logic;
  signal stall            : std_logic;
  signal index            : unsigned(INDEX_SIZE-1 downto 0);
  signal shift            : unsigned(SHIFT_SIZE-1 downto 0);
  signal valid            : std_logic;
  signal weight_bitvec_in : std_logic_vector(KERNEL_BITVEC_SIZE*CONCURRENT_KERNELS-1 downto 0);
  signal ifmap_bitvec_in  : std_logic_vector(IFMAP_BITVEC_SIZE*CONCURRENT_IFMAPS-1 downto 0);
  signal fetch_values     : std_logic;
    
  signal test:string (1 to 18);
  signal test1,test2: integer;
  signal test3: character;
  constant MSG_ASSERTION_FAILED : string(1 to 18) := "Assertion failed: ";
  constant SPACE : string(1 to 1) := " ";
  constant CLK_PERIOD : time := 20 ns;
    -- source : https://opencores.org/websvn/filedetails?repname=ion&path=%2Fion%2Ftrunk%2Fvhdl%2Ftb%2Ftxt_util.vhdl, slightly edited

function to_std_logic(c : character) return std_logic is
    variable sl : std_logic;
    begin
        case c is
            when 'U' =>
            sl := 'U';
            when 'X' =>
            sl := 'X';
            when '0' =>
            sl := '0';
            when '1' =>
            sl := '1';
            when 'Z' =>
            sl := 'Z';
            when 'W' =>
            sl := 'W';
            when 'L' =>
            sl := 'L';
            when 'H' =>
            sl := 'H';
            when '-' =>
            sl := '-';
            when others =>
            sl := 'X';
        end case;
return sl;
end to_std_logic;

    function to_std_logic_vector(s : string) return std_logic_vector is
        variable slv : std_logic_vector(s'high-s'low downto 0);
        variable k : integer;
        begin
            k := s'high-s'low;
            for i in s'range loop
            slv(k) := to_std_logic(s(i));
            k := k - 1;
        end loop;
        return slv;
    end to_std_logic_vector;

begin

  index_selection_i : entity work.index_selection
  port map(
    clk              => clk,
    reset => reset,
    stall            => stall,
    index            => index,
    shift            => shift,
    valid            => valid,
    weight_bitvec_in => weight_bitvec_in,
    ifmap_bitvec_in  => ifmap_bitvec_in,
    fetch_values     => fetch_values
  );

  clock : process
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

stim : process
file infile : text open read_mode is "indexselection.txt";
--file outfile : text open write_mode is "/home/fabian/Documents/Bachelorarbeit/VHDL/tb/testdata/indexselectionout.txt";
variable inline, outline : line;
variable in_vec : string(1 to 18);
variable s: string(1 to 10) := (others => '%');
variable fetch : character;
variable SPACE: character;
variable int, shift_sh,index_sh: integer;
variable valid_sh: std_logic;
begin
  reset <= '0';
  fetch_values <= '0';
  wait for CLK_PERIOD/2; --falling
  reset <= '1';
    wait for CLK_PERIOD/2; --rising
  while not(endfile(infile)) loop
    --simplest test case
    wait for CLK_PERIOD/2; --falling
    readline(infile,inline);
    read(inline, fetch);
    fetch_values <= to_std_logic(fetch);
    read(inline,SPACE);
    read(inline,in_vec);
    read(inline,SPACE);
    weight_bitvec_in <= to_std_logic_vector(in_vec);
    read(inline,in_vec);
    read(inline,SPACE);
    ifmap_bitvec_in <= to_std_logic_vector(in_vec);
    read(inline,int);
    shift_sh := int;
    test1 <= shift_sh;
    read(inline,int);
    index_sh := int;
    test2<= index_sh;
    read(inline,SPACE);
    read(inline,SPACE);
    test3 <= SPACE;
    valid_sh := to_std_logic(SPACE);
    wait for CLK_PERIOD/2; --rising
    assert valid_sh = valid report "Assertion failed should be:" & std_logic'Image(valid_sh) & "but is" & std_logic'Image(valid) severity WARNING;
    if valid_sh = '1' then
        assert index_sh = to_integer(index) report "Assertion failed INDEX should be:" & integer'Image(index_sh) & "but is" & integer'Image(to_integer(index)) severity WARNING;
        assert shift_sh = to_integer(shift) report "Assertion failed SHIFT should be:" & integer'Image(shift_sh) & "but is" & integer'Image(to_integer(shift)) severity WARNING;
    end if;
    --put all stimulus on, now check the outputs
         
    

 

  end loop;


end process;

end architecture;
