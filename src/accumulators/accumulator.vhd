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
    to_bus: out std_logic_vector(BUSSIZE-1 downto 0)
  );
end entity;

architecture arch of accumulators is

constant FINISH_DELAY_CYC : integer := 4; --needed for the current BRAMS to finish their writing
signal finish_delay,finish_delay_nxt: std_logic_vector(FINISH_DELAY_CYC-1 downto 0);
signal swap,swap_nxt: std_logic;
signal finished_brams,finished_brams_nxt, free_brams,free_brams_nxt: std_logic_vector(1 downto 0);
signal ready_out_brams: std_logic;
signal zero: std_logic;
signal rd_en: std_logic_vector(1 downto 0);
signal rd_addr: addr_array;
type data_array_rd_out is array (0 to NUM_INPUTS-1) of data_array;
signal rd_data: data_array_rd_out;
signal tag,tag_nxt : natural range 0 to 71+2;
signal switch , switch_nxt: std_logic;
signal valid_read, valid_read_nxt: std_logic_vector(2 downto 0);
signal enable_out, enable_out_nxt, out_enable_reg, out_enable_reg_nxt, out_enable_nxt: std_logic;
signal request_bus_delay, request_bus_delay_nxt: std_logic_vector(1 downto 0);
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
              switch    => switch,
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
            switch <= '0';
            finished_brams <= "00";
            free_brams <= "11";
            valid_read <= "000";
            enable_out <= '0';
            out_enable_reg <= '0';
            request_bus_delay <= "00";
        elsif rising_edge(clk) then
            finish_delay(FINISH_DELAY_CYC-1) <= finished;
            swap <= swap_nxt;
            switch <= switch_nxt;
            tag <= tag_nxt;
            finished_brams <= finished_brams_nxt;
            free_brams <= free_brams_nxt;
            valid_read <= valid_read_nxt;
            finish_delay <= finish_delay_nxt;
            enable_out <= enable_out_nxt;
            out_enable_reg <= out_enable_reg_nxt;
            request_bus_delay <= request_bus_delay_nxt;
            --it isnt necessary because of ready_out but it doesnt hurt

        end if;
    end process;


    read_brams: process(all)

    begin
        zero <= '0';
        to_bus <= (others => '0');
        tag_nxt <= 0;
        rd_en <= "00";
        valid_read_nxt(2) <= '0';
        valid_read_nxt(1) <= valid_read(2);
        valid_read_nxt(0) <= valid_read(1);
        rd_addr(0) <= std_logic_vector(to_unsigned(0,rd_addr(0)'length));
        rd_addr(1) <= std_logic_vector(to_unsigned(0,rd_addr(0)'length));
        out_enable_reg_nxt <= out_enable;
        enable_out_nxt <= enable_out;
        --zero <= '0';
        if out_enable = '1' and out_enable_reg = '0' then
          enable_out_nxt <= '1';
          --zero <= '1';
        end if;
        if enable_out = '1' then

            rd_en <= "10";
            rd_addr(0) <= std_logic_vector(to_unsigned(tag,rd_addr(0)'length));
            rd_addr(1) <= std_logic_vector(to_unsigned(tag,rd_addr(0)'length));
            zero <= '1';
            if valid_read(0) = '1' then
              for I in 1 to NUM_INPUTS loop
                  to_bus((ACC_DATA_WIDTH*I)-1 downto ACC_DATA_WIDTH*(I-1)) <=  rd_data(I-1)(1);
              end loop;
            else
                to_bus <=  (others => '0');
            end if;
            if tag = 72 then
                tag_nxt <= 0;
                valid_read_nxt(0) <= '1';
                enable_out_nxt <= '0';
            else
                tag_nxt <= tag + 1;
                valid_read_nxt(0) <= '1';
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
            switch_nxt <= '0';
            finish_delay_nxt(FINISH_DELAY_CYC-1) <= finished;
            for I in 0 to FINISH_DELAY_CYC-2 loop
                finish_delay_nxt(I) <= finish_delay(I+1);
            end loop;

            if swap = '1' then
                swap_var := 1;
            end if;

            if finish_delay(0) = '0' and finish_delay(1) = '1' then
            --if a rising edge on finished is detected the current BRAMS are full and finished
                finished_brams_nxt(swap_var) <= '1';
                swap_nxt <= not(swap);
                switch_nxt <= '1';
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
        request_bus_delay_nxt(1) <= OR_REDUCE(finished_brams); --needs to be delayed for one additional cycle else the swap isnt fully finished yet
        --request_bus_delay_nxt(1) <= request_bus_delay(2);
        request_bus_delay_nxt(0) <= request_bus_delay(1);
        request_bus <= request_bus_delay(0);
        free <= OR_REDUCE(free_brams);
    end process;

end architecture;
