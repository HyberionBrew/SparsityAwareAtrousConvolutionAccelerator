library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;


use work.pe_group_pck.all;
use work.core_pck.all;

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
  --signal swap,swap_nxt: natural range 0 to 1;
  type acc_reg_type is array(natural range 0 to DEPTH-1, natural range 0 to NUM_INPUTS-1 ) of signed(ACC_DATA_WIDTH-1 downto 0); --todo
  signal acc_reg1, acc_reg2, acc_reg1_nxt, acc_reg2_nxt: acc_reg_type;
  --signal finish_detect,finish_detect_nxt: std_logic_vector(1 downto 0);
  signal tag_out, tag_out_nxt : natural range 0 to DEPTH-1;
   signal to_bus_0, to_bus_1: std_logic_vector(BUSSIZE-1 downto 0);

  signal out_values_available_nxt : std_logic;
  signal swap_in_use,swap_in_use_nxt: std_logic_vector(1 downto 0);
    signal out_enable_reg,out_enable_reg_nxt :std_logic;
  signal delay_finished, delay_finished_nxt: std_logic_vector(DELAY_FINISHED_CLK downto 0);
  signal enable, free_intern: std_logic_vector(1 downto 0);
  signal swap ,swap_nxt, rd_ptr, rd_ptr_nxt,out_enable_delay,out_enable_delay_nxt: std_logic;

  signal out_enable_intern_nxt,out_enable_intern,finished_intern,finished_intern_nxt,swap_used,swap_used_nxt: std_logic_vector(1 downto 0);
begin

  delay_finito: process(all)
  begin
    delay_finished_nxt(DELAY_FINISHED_CLK) <= finished;

    for i in 0 to DELAY_FINISHED_CLK-1 loop
        delay_finished_nxt(I) <= delay_finished(I+1);

    end loop;
    finished_out <= delay_finished(0);
  end process;


  sync : process(clk,reset)
  begin
    if reset = '0' then
      acc_reg1 <= (others => (others => (to_signed(0,ACC_DATA_WIDTH))));
      acc_reg2 <= (others => (others => (to_signed(0,ACC_DATA_WIDTH))));
      swap <= '0';
    --  finish_detect <= "11";
      swap_in_use <= "00";
    --  finished_reg <= "00";
      delay_finished <= (others => '1');
      tag_out <= 0;
      out_enable_intern <= (others => '0');
      out_enable_delay <= '0';
      rd_ptr <= '0';
      finished_intern <= (others => '1');
      swap_used <= "10";
    elsif rising_edge(clk) then
     delay_finished <= delay_finished_nxt;
      acc_reg1 <= acc_reg1_nxt;
       acc_reg2 <= acc_reg2_nxt;
      swap <= swap_nxt;
    --  finish_detect <= finish_detect_nxt;
      swap_in_use <= swap_in_use_nxt;
      tag_out <= tag_out_nxt;
    --  finished_reg <= finished_reg_nxt;
      out_enable_intern <= out_enable_intern_nxt;
      out_enable_delay <= out_enable_delay_nxt;
      rd_ptr <= rd_ptr_nxt;
      finished_intern <= finished_intern_nxt;
      swap_used <= swap_used_nxt;
    end if;

  end process;

single_accumulator_1 : entity work.single_accumulator
    generic map(
    DEPTH => 72,
    NUM_INPUTS => 17,
    ACC_DATA_WIDTH => 24
    )
port map (
  reset      => reset,
  clk        => clk,
  enable     => swap,
  free       => free_intern(0),
  finished   => not(delay_finished(DELAY_FINISHED_CLK-1))AND  delay_finished(DELAY_FINISHED_CLK),
  inputs     => inputs,
  out_enable => out_enable_intern(0),
  bus_out    => to_bus_0
);

single_accumulator_2 : entity work.single_accumulator
    generic map(
    DEPTH => 72,
    NUM_INPUTS => 17,
    ACC_DATA_WIDTH => 24
    )
port map (
  reset      => reset,
  clk        => clk,
  enable     => not(swap),
  free       => free_intern(1),
  finished   => not(delay_finished(DELAY_FINISHED_CLK-1))AND  delay_finished(DELAY_FINISHED_CLK),
  inputs     => inputs,
  out_enable => out_enable_intern(1),
  bus_out    => to_bus_1
);


internal: process(all)
begin
    --out_enable_intern <= "00"; --problematic
    out_enable_delay_nxt <= out_enable;

    rd_ptr_nxt <= rd_ptr;
    swap_nxt <= swap;
    swap_used_nxt <= swap_used;
    out_enable_intern_nxt <= out_enable_intern;
    if delay_finished(DELAY_FINISHED_CLK-1) = '0' and delay_finished(DELAY_FINISHED_CLK)= '1'  then --falling edge
        swap_nxt <= not(swap);
        if swap = '1' then
            swap_used_nxt(1) <= '1';
         else
            swap_used_nxt(0) <= '1';
         end if;
    end if;

    if out_enable = '1' and out_enable_delay = '0' then --rising
        rd_ptr_nxt <= not(rd_ptr);
        if rd_ptr = '1' then
            out_enable_intern_nxt <= "01";
        else
            out_enable_intern_nxt <= "10";
        end if;

    elsif out_enable = '0' and out_enable_delay = '1' then --falling
        out_enable_intern_nxt <= "00";
        if rd_ptr= '1' then
            --finished_intern_nxt(1) <= '0';
            swap_used_nxt(1) <= '0';
        else
             swap_used_nxt(0) <= '0';
        end if;
    end if;

end process;
output: process(all)
begin
    free <= OR_REDUCE(free_intern);
    if rd_ptr = '1' then
        to_bus <= to_bus_1;
    else
        to_bus <= to_bus_0;
    end if;

    request_bus <= OR_REDUCE(swap_used);
end process;



end architecture;
