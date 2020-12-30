library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.core_pck.all;
use work.pe_pack.all;
--use work.core_pack.all;

entity value_extraction is
  port (
  clk : in std_logic;
  reset: in std_logic;
  --index xtraction info
  addr_kernel: in natural range 0 to MAX_ADDR_KERNEL-1;
  addr_ifmap: in natural range 0 to MAX_ADDR_IFMAP-1;
  addr_kernel_zero : in natural range 0 to KERNELS_PER_PE-1;
  valid: in std_logic;
  values_in: in std_logic_vector(MAX_MEM_WIDTH-1 downto 0);
  zeroes: in std_logic_vector(ZERO_WIDTH_KERNEL-1 downto 0);
  --value_type: in value_type;
  fetch_kernel: in std_logic;
  fetch_ifmap: in std_logic;
  ifmap_value : out std_logic_vector(DATA_WIDTH-1 downto 0);
  weight_value: out std_logic_vector(DATA_WIDTH-1 downto 0);
  zero_ifmap_out: out std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);
  zero_kernel_out: out std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0)
  );
end entity;


architecture arch of value_extraction is
type state is (LOADING_VALUES,STATIONARY);

signal ena_ifmap, ena_kernel, ena_ifmap_nxt, ena_kernel_nxt: std_logic;
signal wea_ifmap, wea_kernel,wea_ifmap_nxt, wea_kernel_nxt: std_logic_vector(0 downto 0);

signal addra_ifmap, addra_kernel,addra_ifmap_nxt, addra_kernel_nxt, write_addr, write_addr_nxt : std_logic_vector(5 downto 0);
signal dina_ifmap, dina_kernel: std_logic_vector(255 downto 0);
constant DELAY_CYCLES :Integer := 1;
--signal douta_ifmap, douta_kernel: std_logic_vector(DATA_WIDTH-1 downto 0);

TYPE WRITE_STATE_TYPE is (write_lower, write_upper);
signal write_state,write_state_nxt: WRITE_STATE_TYPE
;
constant MEM_WIDTH_IN : integer := MAX_MEM_WIDTH;
constant MEM_VALUES_IN : integer := MEM_WIDTH_IN/DATA_WIDTH;
constant IFMAP_DATA_OFFSET: integer := IFMAP_BITVEC_SIZE*IFMAPS_PER_BUS_ACCESS;
constant KERNEL_DATA_OFFSET: integer := KERNEL_BITVEC_SIZE*KERNELS_PER_BUS_ACCESS;
constant ADDR_PER_ACCESS : integer := MEM_WIDTH_IN/DATA_WIDTH;


signal zero_ifmap_nxt, zero_ifmap : std_logic_vector(DATA_WIDTH-1 downto 0);
type zero_kernel_type is ARRAY (0 to KERNELS_PER_PE-1) of std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);  

signal zero_kernel, zero_kernel_nxt : zero_kernel_type;

type zero_ifmap_delay_type is ARRAY (0 to DELAY_CYCLES) of std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);
type zero_kernel_delay_type is ARRAY (0 to DELAY_CYCLES) of std_logic_vector(DATA_WIDTH_ZEROS-1 downto 0);
 
 signal zero_ifmap_delay, zero_ifmap_delay_nxt: zero_ifmap_delay_type;
 signal zero_kernel_delay, zero_kernel_delay_nxt: zero_kernel_delay_type;
type ifmap_reg_type is ARRAY (0 to VALUES_PER_IFMAP*IFMAPS_PER_PE) of std_logic_vector(DATA_WIDTH-1 downto 0);
type kernel_reg_type is ARRAY (0 to VALUES_PER_KERNEL*KERNELS_PER_PE) of std_logic_vector(DATA_WIDTH-1 downto 0);

signal ifmap_reg, ifmap_reg_nxt: ifmap_reg_type;
signal kernel_reg, kernel_reg_nxt : kernel_reg_type;
 
 
begin



  process(clk,reset)
  begin
  if reset= '0' then
    write_addr <= (others =>'0');
    ifmap_reg <= (others => (others => '0'));
    kernel_reg <= (others => (others => '0'));
    zero_ifmap <= (others => '0');
    zero_kernel <= (others => (others => '0'));
    zero_ifmap_delay <= (others => (others => '0'));
    zero_kernel_delay <= (others => (others =>'0'));
  elsif rising_edge(clk) then
    write_addr <= write_addr_nxt;
    ifmap_reg <= ifmap_reg_nxt;
    kernel_reg <= kernel_reg_nxt;
    zero_ifmap <= zero_ifmap_nxt;
    zero_kernel <= zero_kernel_nxt;
    zero_ifmap_delay <= zero_ifmap_delay_nxt;
    zero_kernel_delay <= zero_kernel_delay_nxt;
    ifmap_reg <= ifmap_reg_nxt;
    kernel_reg <= kernel_reg_nxt;
  end if;
  end process;
  
  zeros : process(all)
  begin
    zero_kernel_nxt <= zero_kernel;
    zero_ifmap_nxt <= zero_ifmap;

    zero_ifmap_out <= zero_ifmap; --needs to be delayed for one more cycle to sync up
    zero_kernel_out <= zero_kernel(addr_kernel_zero);
    --addr_kernel_zeroaddr_kernel_zero;
    if fetch_ifmap = '1' then
        zero_ifmap_nxt <= zeroes(DATA_WIDTH_ZEROS-1 downto 0);
    end if;
    if fetch_kernel = '1' then
        for I in 1 to KERNELS_PER_PE loop 
            zero_kernel_nxt(I-1) <= zeroes(DATA_WIDTH_ZEROS*I-1 downto DATA_WIDTH_ZEROS*(I-1));
        end loop;
    end if;
    
  
  end process;

  calc_next_addr : process(all)
  begin
 
    ifmap_reg_nxt <= ifmap_reg;
    kernel_reg_nxt <= kernel_reg;
    ifmap_value <= (others => '0');
    weight_value <= (others=> '0');
    if fetch_ifmap = '1' then
       for I in 1 to IFMAPS_PER_PE*VALUES_PER_IFMAP loop
            ifmap_reg_nxt(I-1) <= values_in(DATA_WIDTH*I-1 downto DATA_WIDTH*(I-1));
       end loop;
      
     -- 
    elsif fetch_kernel = '1' then
        for I in 1 to KERNELS_PER_PE*VALUES_PER_KERNEL loop
            kernel_reg_nxt(I-1) <= values_in(DATA_WIDTH*I-1 downto DATA_WIDTH*(I-1));
       end loop;
      --write_addr <= std_logic_vector(to_unsigned(to_integer(unsigned(write_addr)) + 1,write_addr'length));
    else
      ifmap_value <= ifmap_reg(addr_ifmap);--std_logic_vector(to_unsigned(to_integer(ifmap_index) + to_integer(OFFSET_IFMAP_AR(to_integer(current_ifmap))),addra_ifmap'length));
      weight_value <= kernel_reg(addr_kernel);--std_logic_vector(to_unsigned( to_integer(weight_index) + to_integer(OFFSET_KERNEL_AR(to_integer(current_kernel))),addra_kernel'length));
    end if;
  end process;
end architecture;
