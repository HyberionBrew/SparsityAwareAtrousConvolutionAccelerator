library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use std.textio.all;

entity PE_tb is
end entity;

architecture arch of PE_tb is
  constant CLK_PERIOD : time := 20 ns;
  signal clk: std_logic;
  --index select
  signal new_kernels, new_ifmaps, want_new_values: std_logic;
  signal bus_to_pe : std_logic_vector(512-1 downto 0);
  signal reset:std_logic;
  signal result:signed(DATA_WIDTH_RESULT-1 downto 0);
  signal finished : std_logic;
   signal to_index: INDEX_TYPE;
  signal valid: std_logic;
  
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

  PE_i : entity work.PE
  port map (
    reset => reset,
    clk             => clk,
    finished        => finished,
    new_kernels     => new_kernels,
    new_ifmaps      => new_ifmaps,
    want_new_values => want_new_values,
    bus_to_pe       => bus_to_pe,
    result          => result,
    to_index        => to_index,
    valid_out       => valid
  );


--  PE_t : entity work.PE
--  port map(
--    reset => reset,
--    clk => clk,
--    index => index
--  );

  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  stimulus : process
  file infile : text open read_mode is "input_pe_test.txt";
  variable inline, outline : line;
  variable in_vec : string(1 to 303);
  variable SPACE: string(1 to 1);
  variable int, x_should,y_should,w_should :integer;
  variable case_counter: integer;
  variable final_count: integer;
  
  constant BUSSIZE_C : integer := 303;
  begin
    reset <= '0';
    new_ifmaps <= '0';
    new_kernels <= '0';
    bus_to_pe <= (others => 'U');
   -- bus_to_pe(3 downto 0) <= "0000";
    --ifmap_bitvec <= "101011";--"000011";--(others=> '0');
    --weight_bitvec <= "111100010";--"111100000";--(others=> '0');
    wait for CLK_PERIOD;
    reset <= '1';
    new_ifmaps <= '1';
    readline(infile,inline);
    read(inline, in_vec);

    bus_to_pe(BUSSIZE_C-1 downto 0) <= to_std_logic_vector(in_vec); --first ifmaps
    --bus_to_pe(3 downto 0) <= "0000";
    wait for CLK_PERIOD;
    readline(infile,inline);
    read(inline, in_vec);

    bus_to_pe(BUSSIZE_C-1 downto 0) <= to_std_logic_vector(in_vec); --second ifmaps
    wait for CLK_PERIOD ;
    readline(infile,inline);
    read(inline, in_vec);

    bus_to_pe(BUSSIZE_C-1 downto 0) <= to_std_logic_vector(in_vec);
   -- bus_to_pe(1 downto 0) <= "00";
    new_ifmaps <= '0';
    new_kernels <= '1';
     WAIT FOR CLK_PERIOD;
     readline(infile,inline);
    read(inline, in_vec);

    bus_to_pe(BUSSIZE_C-1 downto 0) <= to_std_logic_vector(in_vec);
    --now writing kernels
    wait for CLK_PERIOD ;
    
    
    bus_to_pe <= (others => 'U');
    new_kernels <= '0';
    wait for CLK_PERIOD;
    readline(infile,inline);
    read(inline,final_count);
    report integer'image(final_count ) & ": test cases coming up";
    case_counter := 0;
    while not(endfile(infile)) loop
        if valid = '1' then
            readline(infile,inline);
            read(inline,int);
            assert to_integer(result) = int report integer'image(case_counter)&" :ASSERTION FAILED! RESULT testcase: "  & integer'image(int) & " but is: " & integer'image(to_integer(result)) severity WARNING;
            read(inline,x_should);

            read(inline,y_should);
            read(inline,w_should);
            assert x_should = to_index.xindex report integer'image(case_counter)&" :ASSERTION FAILED! INDEX X testcase: "  & integer'image(x_should) & " but is: " & integer'image(to_index.xindex) severity WARNING;
            assert y_should = to_index.yindex  report integer'image(case_counter)&" :ASSERTION FAILED!INDEX Y testcase: "  & integer'image(y_should) & " but is: " & integer'image(to_index.yindex) severity WARNING;
            assert w_should = to_index.w  report integer'image(case_counter)&" :ASSERTION FAILED! W testcase: "  & integer'image(w_should) & " but is: " & integer'image(to_index.w) severity WARNING;

            
            if int = to_integer(result) then
                case_counter := case_counter + 1;
            end if;
        end if;
        wait for CLK_PERIOD;
    end loop;
    report "passsed "& integer'image(case_counter) & "/" & integer'image(final_count);
    
    --readin total number of results
    --as soon as encountering valid check with it
    wait;
  end process;


  --index_tb: entity work.index_select
--  port map(
--  reset => reset,
--      clk => clk,
--      ifmap_bitvec => ifmap_bitvec,
--      weight_bitvec => weight_bitvec,
--      out_bitvec => out_bitvec
--    );

--
  --  shift <= to_unsigned(0,PE_SHIFT_SIZE);



end architecture;
