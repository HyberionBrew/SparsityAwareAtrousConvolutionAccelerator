library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.core_pck.all;
--use work.common_pkg.all;
use work.crossbar_pkg.all;
use work.pe_group_pck.all;
--use work.pe_pack.all;
use work.test_utils.all;
use std.textio.all;


entity crossbar_tb is
end entity;

architecture arch of crossbar_tb is
  constant Testcases : integer := 256;
  signal clk, reset: std_logic;
  signal valid_in: std_logic;
  signal ready_in: std_logic_vector(BRAMS_PER_ACCUMULATOR-1 downto 0);
  signal inputs: crossbar_packet_in_array(PES_PER_GROUP-1 downto 0);--(data(DATA_WIDTH_RESULT - 1 downto 0), tag(CROSSBAR_TAG_WIDTH - 1 downto 0), address(CROSSBAR_ADDRESS_WIDTH - 1 downto 0));--data,tag,address,valid
  type inputs_array_type is array (0 to Testcases-1) of crossbar_packet_in_array(PES_PER_GROUP-1 downto 0);
  signal inputs_array: inputs_array_type;
  signal outputs : crossbar_packet_out_array(BRAMS_PER_ACCUMULATOR-1 downto 0);--(data(DATA_WIDTH_RESULT - 1 downto 0), tag(CROSSBAR_TAG_WIDTH - 1 downto 0));	-- output data, tag and validity bit
  signal stall : std_logic_vector(PES_PER_GROUP-1 downto 0);
  constant CLK_PERIOD : time := 20ns;
  type check_outputs_type is array (0 to 2**9-1) of std_logic_vector(DATA_WIDTH_RESULT-1 downto 0);
  signal check_outputs: check_outputs_type;
  signal finished : std_logic;
  constant DELAY_CYCLES :Integer:= 2;
  type stall_delay_typ is array(0 to DELAY_CYCLES) of std_logic_vector(PES_PER_GROUP-1 downto 0);
  signal stall_delay,stall_delay_nxt: stall_delay_typ;
  signal counters_sig: integer_vector(PES_PER_GROUP-1 downto 0);
begin


   
    delay_stall_pro: process
        begin
        stall_delay_nxt(DELAY_CYCLES) <= stall;
        for I in 0 to DELAY_CYCLES-1 loop
            stall_delay_nxt(I) <= stall_delay(I+1);
        end loop;
        wait for CLK_PERIOD/2;
   
    end process;
    
   comp_outs: process
   variable tag: integer;
   begin
   while true loop
        for I in 0 to BRAMS_PER_ACCUMULATOR-1 loop
            check_outputs(to_integer(unsigned(outputs(I).tag))) <= outputs(I).data; --
        end loop;
        wait for CLK_PERIOD;
   end loop;
   
   end process;
   
   com_ins: process
    
    file infile : text open read_mode is "crossbar_test.txt"; --data, address,tag,valid
    variable inline, outline : line;
    variable data: string(1 to DATA_WIDTH_RESULT);
    variable space: string(1 to 1);
    variable int: integer;
    variable addr:integer;
    variable counter : integer := 0;
        
   begin
     while not(endfile(infile)) loop
           for I in 0 to PES_PER_GROUP-1 loop
               readline(infile,inline);
                read(inline,int);
                addr := int;
                inputs_array(counter)(I).address <= std_logic_vector(to_unsigned(int,CROSSBAR_ADDRESS_WIDTH));
                
                read(inline, space);
                read(inline, data);
        
                inputs_array(counter)(I).data <= to_std_logic_vector(data);
             --   check_outputs(addr).data <=  to_std_logic_vector(data);
                read(inline,int);
               -- check_outputs(addr).tag <=  std_logic_vector(to_unsigned(int,CROSSBAR_TAG_WIDTH));
                inputs_array(counter)(I).tag <= std_logic_vector(to_unsigned(int,CROSSBAR_TAG_WIDTH));
                read(inline,int);
                inputs_array(counter)(I).valid <= '1';--std_logic(to_unsigned(int,1)(0));
            end loop;
            counter := counter +1;
       end loop;
       wait;
   end process;
   
   
   check_outs:process
   
    file infile : text open read_mode is "crossbar_test.txt"; --data, address,tag,valid
    variable inline, outline : line;
    variable data: string(1 to DATA_WIDTH_RESULT);
    variable space: string(1 to 1);
    variable int: integer;
    variable addr:integer;
    variable counter : integer := 1;
   begin
      readline(infile,inline);
     while true loop
         if finished = '1' then
           
            while not(endfile(infile)) loop
                readline(infile,inline);
                read(inline,int);
                read(inline, space);
                read(inline, data);
                 
                assert check_outputs(counter) = to_std_logic_vector(data) report integer'Image(counter) & ": Should be " 
                & integer'Image(to_integer(unsigned(to_std_logic_vector(data)))) & " | but is: " 
                & integer'Image(to_integer(unsigned(check_outputs(counter)))) severity WARNING;
                if check_outputs(counter) = to_std_logic_vector(data) then
                    counter := counter + 1;
                end if;
             end loop;
            exit;
         end if;
         wait for CLK_PERIOD*10;
         
     end loop;
     report "passed " & integer'image(counter) & " of " & integer'image(Testcases);
     wait;
   end process;
   

  clock : process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    stall_delay <= stall_delay_nxt;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  stim  : process

  --  file infile : text open read_mode is "crossbar_test.txt"; --data, address,tag,valid
    variable inline, outline : line;
    variable data: string(1 to DATA_WIDTH_RESULT);
    variable space: string(1 to 1);
    variable int: integer;
    variable addr:integer;
    variable counters: integer_vector(PES_PER_GROUP-1 downto 0):= (others => 0);
    variable var_ex: std_logic;
  begin
    finished <= '0';
    reset <= '0';
    valid_in <= '1';
    ready_in <= (others => '1');
    wait for CLK_PERIOD;
    
    reset <= '1';
    while true loop
      
      for I in 0 to PES_PER_GROUP-1 loop
        if stall_delay(0)(I) = '0' and counters(I) < Testcases/PES_PER_GROUP then

            addr := int;
            inputs(I).address <= (others => '0');--inputs_array(counters(I))(I).address;

    
            inputs(I).data <= inputs_array(counters(I))(I).data;
         --   check_outputs(addr).data <=  to_std_logic_vector(data);
           -- check_outputs(addr).tag <=  std_logic_vector(to_unsigned(int,CROSSBAR_TAG_WIDTH));
            inputs(I).tag <= inputs_array(counters(I))(I).tag;
            inputs(I).valid <= '1';--std_logic(to_unsigned(int,1)(0));
            counters(I) := counters(I)+1;
         else
            inputs(I).valid <= '0';
         end if;
       -- check_outputs(addr).valid <= std_logic(to_unsigned(int,1)(0));
    
      end loop;
      counters_sig <= counters;
      wait for CLK_PERIOD;
     var_ex := '1';
     for I in 0 to PES_PER_GROUP-1 loop
        if not(counters(I)=Testcases/PES_PER_GROUP) then
            var_ex := '0';
        end if;
     end loop;
     if var_ex = '1' then
     exit;
     end if;
     end loop;
     
     
     for I in 0 to PES_PER_GROUP-1 loop
     inputs(I).tag <= std_logic_vector(to_unsigned(0,CROSSBAR_TAG_WIDTH));
     end loop;
     wait for CLK_PERIOD * (FIFO_DEPTH*PES_PER_GROUP + 30);
     finished <= '1';
     
     wait;
   -- end loop;

  end process;


crossbar_i : entity work.crossbar

generic map (
  NUM_INPUTS   => PES_PER_GROUP,
  NUM_OUTPUTS  => BRAMS_PER_ACCUMULATOR,
  ADDR_WIDTH   => CROSSBAR_ADDRESS_WIDTH,
  TAG_WIDTH    => CROSSBAR_TAG_WIDTH,
  DATA_WIDTH   => DATA_WIDTH_RESULT,
  FIFO_DEPTH   => FIFO_DEPTH,
  FIFO_ALMOST_FULL => DELAY_CYCLES+2, --DELAY +2
  ENABLE_CYCLE => true--true
)
port map (
  clk       => clk, --done
  res       => reset, --done
  valid_in  => valid_in, --done
  ready_in  => ready_in, --alway true
  inputs    => inputs, --done
  stall_out => stall,
  outputs   => outputs
);





end architecture;
