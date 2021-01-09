library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_misc.all;


use work.pe_group_pck.all;
use work.core_pck.all;

entity single_accumulator is
    generic(
    DEPTH: natural;
    NUM_INPUTS: natural;
    ACC_DATA_WIDTH: natural
    );
  port
    (
    reset: in std_logic;
    clk: in std_logic;
    enable: in std_logic;
    free: out std_logic;
    finished: in std_logic;
    inputs: in crossbar_packet_out_array(NUM_INPUTS-1 downto 0);
    out_enable: in std_logic;
    bus_out: out std_logic_vector(BUSSIZE-1 downto 0)
    );
end entity;

architecture arch of single_accumulator is
  type acc_reg_type is array(natural range 0 to 60-1, natural range 0 to NUM_INPUTS-1 ) of signed(ACC_DATA_WIDTH-1 downto 0); --todo
   signal acc_reg, acc_reg_nxt: acc_reg_type;
   type state_type is (EMPTY, STORAGE, FULL);
   
   signal state, state_nxt: state_type;
   signal tag_out,tag_out_nxt: natural range 0 to DEPTH-1;
   
begin

sync: process(all)
begin
    if reset = '0' then
        state <= EMPTY;
        acc_reg <=  (others => (others => to_signed(0, ACC_DATA_WIDTH)));
        tag_out <= 0;
    elsif rising_edge(clk) then
        state <= state_nxt;
        acc_reg <=  acc_reg_nxt;
        tag_out <= tag_out_nxt;
    end if;
end process;


state_process : process(all)
variable crossbar_pack: crossbar_packet_out;
variable tag: Integer;

begin
  free <= '0';
  state_nxt <= state;
  acc_reg_nxt <= acc_reg;
  tag_out_nxt <= 0;
  bus_out <= (others => '0');
  case(state) is
    when EMPTY =>
      free <= '1';
      state_nxt <= EMPTY;
      acc_reg_nxt <=  (others => (others => to_signed(0, ACC_DATA_WIDTH)));
      tag_out_nxt <= 0;
      if enable = '1' then
        state_nxt <= STORAGE;
      end if;


      when STORAGE =>
         for I in 0 to NUM_INPUTS-1 loop
            crossbar_pack := inputs(I);
            if crossbar_pack.valid = '1' then
                tag := to_integer(unsigned(crossbar_pack.tag )) mod 60;
                acc_reg_nxt(tag,I) <= signed(crossbar_pack.data) + acc_reg(tag,I); --swap
            end if;
         end loop;
         if finished = '1' then
           state_nxt <= FULL;
         end if;

      when FULL =>
        if out_enable = '1' then
           for I in 0 to NUM_INPUTS-1 loop
             bus_out(ACC_DATA_WIDTH*(I+1)-1 downto ACC_DATA_WIDTH*I)<= std_logic_vector(acc_reg(tag_out,I));
           end loop;
           if tag_out = DEPTH-1 then
                state_nxt <= EMPTY; 
           else
             tag_out_nxt <= tag_out +1;
           end if;
        end if;

  end case;
end process;
end architecture;
