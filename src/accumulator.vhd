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
  signal swap,swap_nxt: natural range 0 to 1;
  type acc_reg_type is array(natural range 0 to 1, natural range 0 to NUM_INPUTS-1 ,natural range 0 to DEPTH-1) of signed(ACC_DATA_WIDTH-1 downto 0); --todo
  signal acc_reg, acc_reg_nxt: acc_reg_type;
  signal finish_detect,finish_detect_nxt: std_logic_vector(1 downto 0);
  signal tag_out, tag_out_nxt : natural range 0 to DEPTH-1;
    
  signal out_values_available_nxt : std_logic;
  signal swap_in_use,swap_in_use_nxt, finished_reg, finished_reg_nxt: std_logic_vector(1 downto 0);
    signal out_enable_reg,out_enable_reg_nxt :std_logic;
  signal delay_finished, delay_finished_nxt: std_logic_vector(DELAY_FINISHED_CLK downto 0);
    
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
      acc_reg <= (others => (others => (others => (to_signed(0,ACC_DATA_WIDTH)))));
      swap <= 0;
      finish_detect <= "11";
      swap_in_use <= "00";
      finished_reg <= "00";
      delay_finished <= (others => '0');
      tag_out <= 0;
    elsif rising_edge(clk) then
     delay_finished <= delay_finished_nxt;
      acc_reg <= acc_reg_nxt;
      swap <= swap_nxt;
      finish_detect <= finish_detect_nxt;
      swap_in_use <= swap_in_use_nxt;
      tag_out <= tag_out_nxt;
      finished_reg <= finished_reg_nxt;
      
    end if;

  end process;

  state_m : process(all)
  begin
   
  
    finish_detect_nxt(1) <= finished;
    finish_detect_nxt(0) <= finish_detect(1);
    request_bus <= OR_REDUCE(finished_reg);
    free  <= NAND_REDUCE(swap_in_use);
    
    if finish_detect(0) = '0' and finish_detect(1) = '1' then
      if swap = 0 then
        swap_nxt <= 1;
      else
        swap_nxt <= 0;
      end if;
    end if;
  end process;
  
  

  storage: process(all)
  variable crossbar_pack: crossbar_packet_out;
  variable tag: Integer;
  variable swap_out: integer;
  
  begin
    acc_reg_nxt <= acc_reg;
    finished_reg_nxt <= finished_reg;
    swap_in_use_nxt <= swap_in_use;
    --out_enable_reg_nxt <= out_enable;
    --request_bus <= OR_REDUCE(finished_reg);
    to_bus <= (others => 'U');
    tag_out_nxt <= 0;
    for I in 0 to NUM_INPUTS-1 loop
      crossbar_pack := inputs(I);
      if crossbar_pack.valid = '1' then
          tag := to_integer(unsigned(crossbar_pack.tag));
          acc_reg_nxt(swap,I,tag) <= signed(crossbar_pack.data) + acc_reg(swap,I,tag);
      end if;
    end loop;
    
    --write the other swap out!    
    swap_out := 0;
     if swap = 0 then
        swap_out := 1;
     end if;

     if out_enable = '1' and finished_reg(swap_out) = '1' then
         --assert finished_reg(swap_out) = '1' report "Wants to swap out non finished registers!" severity ERROR;
         
         for I in 0 to NUM_INPUTS-1 loop
            to_bus((ACC_DATA_WIDTH*(I+1))-1 downto ACC_DATA_WIDTH*I) <= std_logic_vector(acc_reg(swap_out,I,tag_out));
            acc_reg_nxt(swap_out,I,tag_out) <=  to_signed(0,ACC_DATA_WIDTH);
         end loop;
         
         if tag_out = DEPTH-1 then
             tag_out_nxt <= 0;
             finished_reg_nxt(swap_out) <= '0';
             swap_in_use_nxt(swap_out) <= '0';
             out_enable_reg_nxt <= '0';
           --  request_bus <= '0';
         else
            tag_out_nxt <= tag_out + 1;
         end if;
     end if;
    
      if finish_detect(0) = '0' and finish_detect(1) = '1' then
        finished_reg_nxt(swap) <= '1';
       end if;
        
      if new_kernels = '1' then
        swap_in_use_nxt(swap) <= '1';
      end if;


  end process;

end architecture;
