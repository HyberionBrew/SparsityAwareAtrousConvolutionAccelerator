library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.core_pck.all;
use work.pe_pack.all;

package index_selection_pck is
    type index_select_state is (LOADING_VALUES,NEW_VALUES,SET_NEW_ACTIVE_KERNEL,SET_NEW_ACTIVE_KERNEL_2);
    
    TYPE MEM_BITVEC_KERNEL is ARRAY (0 to KERNELS_PER_PE-1) of std_logic_vector(KERNEL_BITVEC_SIZE-1 downto 0);
    TYPE MEM_BITVEC_IFMAP is ARRAY (0 to IFMAPS_PER_PE-1) of std_logic_vector(IFMAP_BITVEC_SIZE-1 downto 0);
    TYPE ACTIVE_KERNEL_REGS is ARRAY (0 to SIMULTANEOUS_KERNELS-1) of std_logic_vector(KERNEL_BITVEC_SIZE-1 downto 0);

    constant KERNEL_COUNTER_MAX : integer := KERNELS_PER_PE/SIMULTANEOUS_KERNELS;
 
 function TO_MEM_WEIGHT(v : std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0); fetch_count: integer) return MEM_BITVEC_KERNEL;

 function TO_MEM_IFMAP(v : std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0); fetch_count: integer) return MEM_BITVEC_IFMAP ;



 
 procedure mask_last (variable bitvec_var: inout std_logic_vector(EXTRACTION_WIDTH-1 downto 0);
                    signal index: out natural range 0 to EXTRACTION_WIDTH-1;
                    variable valid_var: out std_logic);


 --procedure compute_bitvec(variable bitvec_var: out std_logic_vector(EXTRACTION_WIDTH-1 downto 0);
   --                       signal ifmap_reg : in MEM_BITVEC_IFMAP;
    --                      signal ifmap_counter: in integer range 0 to IFMAPS_PER_PE-1;
     --                     signal active_kernels: in ACTIVE_KERNEL_REGS);

 function set_active_kernels (weight_reg: MEM_BITVEC_KERNEL;
                                  kernel_counter : natural range 0 to KERNEL_COUNTER_MAX-1
                                  ) return ACTIVE_KERNEL_REGS;



end package;



package body index_selection_pck is













  procedure mask_last (variable bitvec_var: inout std_logic_vector(EXTRACTION_WIDTH-1 downto 0);
                       signal index: out natural range 0 to EXTRACTION_WIDTH-1;
                       variable valid_var: out std_logic) is
  begin
    valid_var := '0';
    for I in bitvec_var'low to bitvec_var'high loop
        if bitvec_var(I)= '1' then
            valid_var := '1';
            index <= I;
            bitvec_var(I) := '0';
            exit;
        end if;
    end loop;
  end procedure;



function TO_MEM_WEIGHT(v : std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0); fetch_count: integer) return MEM_BITVEC_KERNEL is
    variable mem : MEM_BITVEC_KERNEL := (others=> (others=> '0'));
        begin
        for I in 1 to SIMULTANEOUS_KERNELS loop
          mem(I-1+fetch_count*SIMULTANEOUS_KERNELS) := v((I*9)-1 downto (I-1)*9);
        end loop;
    return mem;
end function;

    function TO_MEM_IFMAP(v : std_logic_vector(MAX_BITVECS_WIDTH-1 downto 0); fetch_count: integer) return MEM_BITVEC_IFMAP is
      variable mem : MEM_BITVEC_IFMAP := (others=> (others=> '0'));
      begin
        for I in 1 to SIMULTANEOUS_KERNELS loop
          mem(I-1+ fetch_count * SIMULTANEOUS_KERNELS) := v((I*6)-1 downto  (I-1)*6);
        end loop;
        return mem;
      end function;

      function set_active_kernels (weight_reg: MEM_BITVEC_KERNEL;
                                  kernel_counter : natural range 0 to KERNEL_COUNTER_MAX-1
                                  ) return ACTIVE_KERNEL_REGS is
        variable active_kernel_regs : ACTIVE_KERNEL_REGS;
        begin
          for I in active_kernel_regs'range loop
            active_kernel_regs(I) := weight_reg(I + (kernel_counter*SIMULTANEOUS_KERNELS)); --TODO!!! CHANGE TO STATIC ARRAY
          end loop;
          return active_kernel_regs;
        end function;


end package body;
