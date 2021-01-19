library ieee;
use ieee.std_logic_1164.all; --do I need this?

use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
use work.fetch_unit_pck.all;

entity fetch_unit is
  generic(
    NUMBER_OF_IFMAPS: natural;
    NUMBER_OF_KERNELS: natural;
    SIMULTANEOUS_KERNELS: natural
  );
  port (
  reset, clk : in std_logic;
  finished : out std_logic;
  new_kernels : in std_logic;
  new_ifmaps : in std_logic;
  kernel_bitvecs: in kernel_bitvecs_type;
  ifmap_bitvecs: in ifmap_bitvecs_type;
  index: out natural range 0 to INDEX_MAX-1;--EXTRACTION_WIDTH-1;
  shift: out natural range 0 to SHIFT_MAX-1;
  kernel_number: out natural range 0 to 1;
  valid : out std_logic
);
end fetch_unit;

architecture arch of fetch_unit is
    signal state, state_nxt: state_type;
    signal kernel_bitvecs_reg, kernel_bitvecs_reg_nxt: kernel_bitvecs_type;
    signal ifmap_bitvecs_reg, ifmap_bitvecs_reg_nxt: ifmap_bitvecs_type;
    signal bitvec, bitvec_nxt: std_logic_vector(COMPARISON_BITVEC_WIDTH-1 downto 0);
    signal valid_prev_nxt, valid_prev: std_logic;
    signal second_offs, second_offs_nxt : natural range 0 to 3;
    signal shift_nxt: natural range 0 to SHIFT_MAX-1;
    signal kernel_number_nxt: natural range 0 to 1;
begin

  sync : process(clk,reset)
  begin
      if reset = '0' then
        state <= LOADING_VALUES;
        ifmap_bitvecs_reg <= (others =>  (others => '0'));
        kernel_bitvecs_reg <= (others =>  (others => '0'));
        bitvec <= (others => '0');
        valid_prev <= '0';
        second_offs <= 0;
        shift <= 0;
        kernel_number <= 0;
      elsif rising_edge(clk) then
        kernel_number <= kernel_number_nxt;
        shift <= shift_nxt;
        second_offs <= second_offs_nxt;
        bitvec <= bitvec_nxt;
        state <= state_nxt;
        valid_prev <= valid_prev_nxt;
        kernel_bitvecs_reg <= kernel_bitvecs_reg_nxt;
        ifmap_bitvecs_reg <= ifmap_bitvecs_reg_nxt;
      end if;
  end process;

  state_process : process(all)
  variable bitvec_var: std_logic_vector(COMPARISON_BITVEC_WIDTH-1 downto 0);
  variable valid_var :std_logic;
  begin
    valid_var := '0';
    bitvec_var := bitvec;
    state_nxt <= state;
    valid <= '0';
    valid_prev_nxt <= '0';
    second_offs_nxt <= second_offs;
    bitvec_nxt <= bitvec_var;
    shift_nxt <= shift;
    kernel_number_nxt <= kernel_number;
    case(state) is

      when LOADING_VALUES =>
        if new_kernels = '1' then
          kernel_bitvecs_reg_nxt <= kernel_bitvecs;
          state_nxt <= PROCESSING;
        elsif new_ifmaps = '1' then
          ifmap_bitvecs_reg_nxt <= ifmap_bitvecs;
        end if;
        finished <= '1';


      when PROCESSING =>
      --set the bitvec
        if valid_prev = '0' then
          for I in 0 to SIMULTANEOUS_KERNELS loop
            bitvec_var(VALUES_PER_IFMAP*(I+1)-1 downto VALUES_PER_IFMAP*I) := kernel_bitvecs_reg(I+second_offs)(VALUES_PER_IFMAP-1 downto 0) AND ifmap_bitvecs_reg(I+second_offs)(VALUES_PER_IFMAP-1 downto 0);
          end loop;
        end if;
        mask_last(bitvec_var ,index, valid_var);
        bitvec_nxt <= bitvec_var;
        if valid_var = '0' then
          shift_regs(kernel_bitvecs_reg,kernel_bitvecs_reg_nxt);
          --do the shift
          if shift = 8 then
            shift_nxt <= 0;
            if second_offs = SIMULTANEOUS_KERNELS then
              kernel_number_nxt <= 0;
              finished <= '1';
              second_offs_nxt <= 0;
              state_nxt <= LOADING_VALUES;
            else
              kernel_number_nxt <= 1;
              second_offs_nxt <= SIMULTANEOUS_KERNELS;
            end if;
          else
            shift_nxt <= shift + 1;
          end if;
        end if;
        valid <= valid_var;
        valid_prev_nxt <= valid_var;
    end case;
  end process;

end architecture;
