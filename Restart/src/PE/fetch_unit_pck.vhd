library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


use work.core_pck.all;
use work.pe_pack.all;

package fetch_unit_pck is
    type state_type is (LOADING_VALUES,PROCESSING);
    constant SINGLE_BITVEC_WIDTH :natural := VALUES_PER_IFMAP;
    constant COMPARISON_BITVEC_WIDTH :natural := SINGLE_BITVEC_WIDTH*3;


 procedure mask_last (variable bitvec_var: inout std_logic_vector(COMPARISON_BITVEC_WIDTH-1 downto 0);
                    signal index: out natural range 0 to 18-1;
                    variable valid_var: out std_logic);


  procedure shift_regs (signal kernel_bitvecs_reg: in kernel_bitvecs_type;
                        signal kernel_bitvecs_reg_nxt: out kernel_bitvecs_type
  );
end package;



package body fetch_unit_pck is

  procedure mask_last (variable bitvec_var: inout std_logic_vector(COMPARISON_BITVEC_WIDTH-1 downto 0);
                       signal index: out natural range 0 to 18-1;
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

  procedure shift_regs (signal kernel_bitvecs_reg: in kernel_bitvecs_type;
                        signal kernel_bitvecs_reg_nxt: out kernel_bitvecs_type
  ) is
  begin
    --doing a circular right shift
    for I in 0 to kernel_bitvecs_reg'length-1 loop
      kernel_bitvecs_reg_nxt(I)(kernel_bitvecs_reg(I)'length-1) <= kernel_bitvecs_reg(I)(0);
      for J in 1 to kernel_bitvecs_reg(I)'length-1 loop
        kernel_bitvecs_reg_nxt(I)(J-1) <= kernel_bitvecs_reg(I)(J);
      end loop;
    end loop;
  end procedure;
end package body;
