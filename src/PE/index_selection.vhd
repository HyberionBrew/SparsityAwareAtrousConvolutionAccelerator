library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_pck.all;
use work.pe_pack.all;
use work.index_selection_pck.all;
--

use ieee.std_logic_misc.all; --for and_reduce


entity index_selection is
  port (
  clk,reset: in std_logic;
  stall : in std_logic;
  --weight_index: in unsigned(3 downto 0);
--  ifmap_index:in unsigned(IFMAP_INDEX_SIZE-1 downto 0);
  index: out natural range 0 to INDEX_MAX-1;--EXTRACTION_WIDTH-1;
  shift: out natural range 0 to SHIFT_MAX-1;
  valid : out std_logic;
  bitvec_in: in std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0);
  fetch_values_ifmap: in std_logic;
  fetch_values_kernel: in std_logic;
  ifmap_counter : out natural range 0 to IFMAPS_PER_PE-1; --TODO!
  kernel_counter : out natural range 0 to KERNELS_PER_PE-1;
  finished: out std_logic
  );

end entity;

architecture arch of index_selection is

   
   
  signal weight_reg, weight_reg_nxt : MEM_BITVEC_KERNEL;
  signal ifmap_reg,ifmap_reg_nxt : MEM_BITVEC_IFMAP;
  signal ifmap_counter_nxt : natural range 0 to IFMAPS_PER_PE; -- TODO!
  signal shift_nxt :natural range 0 to SHIFT_MAX-1;
  signal state,state_nxt : index_select_state;
  signal ifmap_nxt : std_logic_vector(IFMAP_BITVEC_SIZE-1 downto 0);

  signal new_bitvec_nxt,new_bitvec: std_logic;

  signal bitvec_nxt, bitvec: std_logic_vector(EXTRACTION_WIDTH-1 downto 0);


  signal kernel_counter_nxt :natural range 0 to KERNEL_COUNTER_MAX-1;

  signal active_kernels, active_kernels_nxt: ACTIVE_KERNEL_REGS;

    
  constant FINISHED_DELAY_CYCLES : integer := 4;
  type finished_delay_type is array (0 to FINISHED_DELAY_CYCLES-1) of std_logic;
  signal finished_delay, finished_delay_nxt : finished_delay_type;

begin
sync : process(clk,reset)
begin
  if reset = '0' then
    weight_reg <= (others=> (others=> '0'));
    ifmap_reg <= (others=> (others=> '0'));
    ifmap_counter <= 0;
    state <= LOADING_VALUES;
    bitvec <= (others => '0');
    shift <= 0;
    kernel_counter <= 0;
    active_kernels <= (others=> (others=> '0'));
    finished_delay <= (others => '1');
  elsif rising_edge(clk) then
    finished_delay <= finished_delay_nxt;
    weight_reg <= weight_reg_nxt;
    ifmap_reg <= ifmap_reg_nxt;
    ifmap_counter <= ifmap_counter_nxt;
    state <= state_nxt;
    bitvec <= bitvec_nxt;
    shift <= shift_nxt;
    new_bitvec <= new_bitvec_nxt;
    kernel_counter <= kernel_counter_nxt;
    active_kernels <= active_kernels_nxt;
  end if;
end process;


delay_finished: process(all)
begin
    
   case(state) is 
    when LOADING_VALUES =>
        finished <= finished_delay(0);
        if stall = '0' then
            finished_delay_nxt(FINISHED_DELAY_CYCLES-1) <= '1';
            for I in 0 to FINISHED_DELAY_CYCLES-2 loop
                finished_delay_nxt(I) <= finished_delay(I+1);
            end loop;
        end if;
    when others =>
        finished_delay_nxt <= (others => '0');
        finished <= '0';
   end case;     


end process;

extract_index : process(all)
variable bitvec_var: std_logic_vector(EXTRACTION_WIDTH-1 downto 0);
variable valid_var: std_logic;
    variable temp: std_logic_vector(5 downto 0);
begin
  --if comparison is 0 --> shift, however also need to shift preemtively
  --have two calculation registers get new values if new_values and if in the last part of shift 8
  --maybe state get new values -> in that state compute everything directly from the Registers
  --else compute it from the existing REGister

  weight_reg_nxt <= weight_reg;
  ifmap_reg_nxt <= ifmap_reg;
  shift_nxt <= shift;
  state_nxt <= state;
  ifmap_counter_nxt <= ifmap_counter;
  bitvec_nxt <= bitvec;
  valid <= '0';
  index <= 0;
  new_bitvec_nxt <= '0';

  kernel_counter_nxt <= kernel_counter;
  active_kernels_nxt <= active_kernels;
  bitvec_var := bitvec;
  
  case(state) is
    --load new values
    when LOADING_VALUES =>
      if fetch_values_ifmap = '1' then
        for I in 1 to IFMAPS_PER_PE loop
             ifmap_reg_nxt(I-1) <= bitvec_in(VALUES_PER_IFMAP*I-1 downto VALUES_PER_IFMAP*(I-1));
        end loop; 


      elsif fetch_values_kernel = '1' then
       for I in 1 to KERNELS_PER_PE loop
            weight_reg_nxt(I-1) <= bitvec_in(VALUES_PER_KERNEL*I-1 downto VALUES_PER_KERNEL*(I-1));
        end loop;
        state_nxt <= SET_NEW_ACTIVE_KERNEL;
      end if;
      
      
      kernel_counter_nxt <= 0;
   
      shift_nxt <= 0;
      ifmap_counter_nxt <= 0;
      new_bitvec_nxt <= '1';

    when SET_NEW_ACTIVE_KERNEL =>
      state_nxt <= SET_NEW_ACTIVE_KERNEL_2;
      active_kernels_nxt <= set_active_kernels(weight_reg,kernel_counter);

    when SET_NEW_ACTIVE_KERNEL_2 =>
        compute_bitvec(bitvec_var,ifmap_reg,ifmap_counter,active_kernels);

        bitvec_nxt <= bitvec_var;
        state_nxt <= NEW_VALUES;

    when NEW_VALUES =>
      ifmap_nxt <= ifmap_reg(ifmap_counter);
      if new_bitvec = '1' then
        compute_bitvec(bitvec_var,ifmap_reg,ifmap_counter,active_kernels); --should return EXTRACTION WIDTH
      else
        bitvec_var := bitvec;
      end if;
      --shift now!
      if stall = '0' then
        mask_last(bitvec_var, index, valid_var); --masks the last bit in the bitvec and returns valid
      else
        valid_var := '0';
      end if;
      --in the case no valid value will be extracted in the next cycle shift already here
      if valid_var = '0' and stall = '0' then
        shift_nxt <= shift +1;
        new_bitvec_nxt <= '1';
        for I in 0 to SIMULTANEOUS_KERNELS-1 loop
          active_kernels_nxt(I) <= active_kernels(I) srl 1; --weight_reg(0),1)
          active_kernels_nxt(I)(KERNEL_BITVEC_SIZE-1) <= active_kernels(I)(0);
        end loop;

        if shift = 8 then
          shift_nxt <= 0;
          ifmap_counter_nxt <= ifmap_counter + 1;
          if ifmap_counter = IFMAPS_PER_PE-1 then
              kernel_counter_nxt <= kernel_counter +1;
              if kernel_counter = KERNEL_COUNTER_MAX-1 then
                state_nxt <= LOADING_VALUES;
                kernel_counter_nxt <= 0;
              else
                state_nxt <= SET_NEW_ACTIVE_KERNEL;
              end if;
              ifmap_counter_nxt <= 0;
          end if;
        end if;
      end if;

      --the current bitvec gets looked at in the end
      valid <= valid_var;
      bitvec_nxt <= bitvec_var;
      --kernels <=
     when others =>

  end case;

end process;

end architecture;
