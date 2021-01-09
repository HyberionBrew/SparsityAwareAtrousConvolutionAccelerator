library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;


use work.pe_group_pck.all;
use work.core_pck.all;
use work.acc_bank_pkg.all;

entity accumulators is
  generic(
    NUM_INPUTS : natural;
    DEPTH      : natural;
    ACC_DATA_WIDTH      : natural;
    DELAY_FINISHED_CLK : natural
  );
  port
  (
    reset: in std_logic;
    clk: in std_logic;
    inputs: in crossbar_packet_out_array(NUM_INPUTS-1 downto 0);
    request_bus: out std_logic;
    finished: in std_logic;
    finished_out: out std_logic;
    out_enable: in std_logic;
    free: out std_logic;
    new_kernels: in std_logic;
    to_bus: out std_logic_vector(BUSSIZE-1 downto 0)
  );
end entity;

architecture arch of accumulators is

constant FINISH_DELAY_CYC : integer := 4;
signal finish_delay,finish_delay_nxt: std_logic_vector(FINISH_DELAY_CYC-1 downto 0);
signal swap,swap_nxt: std_logic;
signal finished_brams,finished_brams_nxt, free_brams,free_brams_nxt: std_logic_vector(1 downto 0);
signal ready_out_brams: std_logic;
signal zero: std_logic;
signal rd_en: std_logic_vector(1 downto 0);
signal rd_addr: addr_array;
type data_array_rd_out is array (0 to NUM_INPUTS-1) of data_array;
signal rd_data: data_array_rd_out;
signal tag,tag_nxt : natural range 0 to 71; 
begin
  --signal swap,swap_nxt: natural range 0 to 1;
    brams: for i in 0 to NUM_INPUTS-1 generate 
        accumulator_bank_i : accumulator_bank
            generic map (
              ADDR_WIDTH   => 9,
              RESULT_WIDTH => 24 --TODO!
            )
            port map (
              clk       => clk,
              res       => reset,
              valid_in  => inputs(I).valid,
              switch    => swap,
              wr_addr   => inputs(I).tag,
              wr_data   => inputs(I).data,
              zero      => zero, --used for emptying
              rd_en     => rd_en,
              rd_addr   => rd_addr,
              ready_out => open,
              rd_data   => rd_data(I)
            );
      end generate;
    
   --delaing the finish for 3 Cycles in order not to harm current accumulation 
    --i.e. not to soon switched
    sync: process(all)
    begin
        if reset = '0' then
            finish_delay <= (others => '1');
            swap <= '0';
            finished_brams <= "00";
            free_brams <= "11";
        elsif rising_edge(clk) then
            finish_delay(FINISH_DELAY_CYC-1) <= finished;
            swap <= swap_nxt;
            tag <= tag_nxt;
            finished_brams <= finished_brams_nxt;
            free_brams <= free_brams_nxt;
            --it isnt necessary because of ready_out but it doesnt hurt
            for I in 0 to FINISH_DELAY_CYC-2 loop
                finish_delay(I) <= finish_delay_nxt(I+1);
            end loop;
        end if;
    end process;
    
    
    read_brams: process(all)
    
    begin
        to_bus <= (others => 'U');
        tag_nxt <= 0;
        rd_en <= "00";
        
        if out_enable = '1' then
            tag_nxt <= tag + 1;
            rd_en <= "11";
            rd_addr(0) <= std_logic_vector(to_unsigned(tag,rd_addr(0)'length));
            rd_addr(1) <= std_logic_vector(to_unsigned(tag,rd_addr(0)'length));
            for I in 1 to 17 loop
                to_bus((ACC_DATA_WIDTH*I)-1 downto ACC_DATA_WIDTH*(I-1)) <=  rd_data(I-1)(0) ;
            end loop;
            if tag = 71 then
                tag_nxt <= 0;
            end if;
        end if;
                
    end process;
    --process for the switchero
    switchero: process(all)
    variable swap_var: integer;
    begin
            swap_nxt <= swap;
            free_brams_nxt <= free_brams;
            finished_brams_nxt <= finished_brams;
            swap_var := 0;
            if swap = '1' then
                swap_var := 1;
            end if;
            finish_delay_nxt <= finish_delay;
            if finish_delay(0) = '0' and finish_delay(1) = '1' then
            --if a rising edge on finished is detected the current BRAMS are full and finished
                finished_brams_nxt(swap_var) <= '1';
                swap_nxt <= not(swap);
                
            end if;
             --if a falling edge is detected it is no longer free ASAP
            if finish_delay(FINISH_DELAY_CYC-2) = '1' and finish_delay(FINISH_DELAY_CYC-1) = '0' then

                free_brams_nxt(swap_var) <= '0';
            end if;    
            --free() <= '0';
    end process;
    
    output: process(all)
    variable swap_var: integer;
    begin
        swap_var := 0;
        if swap = '1' then
            swap_var := 1;
        end if;
        finished_out <= free_brams(swap_var);--OR_REDUCE(finished_brams);
        request_bus <= OR_REDUCE(finished_brams);
        free <= OR_REDUCE(free_brams);
    end process;
    
end architecture;
