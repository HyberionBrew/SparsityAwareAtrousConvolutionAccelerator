library ieee;
use ieee.std_logic_1164.all; --do I need this?
use ieee.numeric_std.all;
use work.pe_pack.all;
use std.textio.all;


entity val_tb is
end entity;

architecture arch of val_tb is
  constant CLK_PERIOD : time := 5 ns;
  signal clk,reset            : std_logic;
  signal current_ifmap  : unsigned(CONCURRENT_IFMAPS_BITSIZE-1 downto 0);
  signal current_kernel : unsigned(CONCURRENT_KERNELS_BITSIZE-1 downto 0);
  signal valid          : std_logic;
  signal weight_index   : unsigned(INDEX_SIZE-1 downto 0);
  signal ifmap_index    : unsigned(INDEX_SIZE-1 downto 0);
  signal ifmap_values   : std_logic_vector(144-1 downto 0);
  signal kernel_values  : std_logic_vector(144-1 downto 0);
  signal write_enable   : std_logic;
  signal ifmap_value    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal weight_value   : std_logic_vector(DATA_WIDTH-1 downto 0);


begin
  clock : process
  begin
    clk <= '1';
    wait for CLK_PERIOD/2;
    clk <= '0';
    wait for CLK_PERIOD/2;
  end process;

  value_extraction_i : entity work.value_extraction
  port map (
    reset          => reset,
    clk            => clk,
    current_ifmap  => current_ifmap,
    current_kernel => current_kernel,
    valid          => valid,
    weight_index   => weight_index,
    ifmap_index    => ifmap_index,
    ifmap_values   => ifmap_values,
    kernel_values  => kernel_values,
    write_enable   => write_enable,
    ifmap_value    => ifmap_value,
    weight_value   => weight_value
  );

  stimulus : process
  --file infile : text open read_mode is "mult.txt";
  --file outfile : text open write_mode is "/home/fabian/Documents/Bachelorarbeit/VHDL/tb/testdata/outmult.txt";
  --variable inline, outline : line;
  
  begin
    --first load something into the value value_extraction
    reset <= '0';
    write_enable <= '0';

    wait for CLK_PERIOD/2; --falling
    reset <= '1';
    valid <= '1';
    current_ifmap <= (others => '0');
    current_kernel <= (others => '0');
    valid <= '1';
    weight_index <= (others => '0');
    ifmap_index <= (others => '0');
    write_enable <= '1';

    ifmap_values <= "001000001000000010110011100100101110101011000010001111011010000111010001110010111010011110010000010111100110110101001001001100110000010001011001"; -- need to be laid onto for at least one additional cycle
    kernel_values <= "111100001000000000100110010110001111100011000010101100100000011101001011111100100010010000000100001110101101110010001010011011010010001101011100";
    --kernel_values <= "111100001000000000100110010110001111100011000010101100100000011101001011111100100010010000000100001110101101110010001010011011010010001101011100";
    wait for CLK_PERIOD;
    kernel_values <= (others => '1');
    write_enable <= '1';
    wait for CLK_PERIOD; --falling
    write_enable <= '0';

    --kernel_values <= (others=> '1');
    wait for CLK_PERIOD*2;
    write_enable <= '0';
    --weight_index <= to_unsigned(1,weight_index'length);
    ifmap_index <= to_unsigned(0,ifmap_index'length);
    wait for CLK_PERIOD;
    weight_index <= to_unsigned(2,weight_index'length);
    current_kernel <= to_unsigned(0,current_kernel'length);
    current_kernel <= to_unsigned(1,current_kernel'length);
    for I in 0 to 15 loop
        weight_index <= to_unsigned(I,weight_index'length);
        wait for CLK_PERIOD;
    end loop;

     weight_index <= to_unsigned(0,weight_index'length);
    wait for CLK_PERIOD;                    
    weight_index <= to_unsigned(8,weight_index'length);
        wait for CLK_PERIOD;                    
    weight_index <= to_unsigned(9,weight_index'length);
    
    wait;
  end process;


end architecture;
