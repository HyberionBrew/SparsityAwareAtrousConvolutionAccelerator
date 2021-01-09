library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package acc_bank_pkg is
	constant ADDR_WIDTH: integer:= 9; --for 72 max  --TODO IMPORT FROM PARENT
	constant ACC_WIDTH: integer := 24;		
	type addr_array is array(1 downto 0) of std_logic_vector(ADDR_WIDTH-1 downto 0);
	type data_array is array(1 downto 0) of std_logic_vector(ACC_WIDTH-1 downto 0);



    component accumulator_bank
    generic (
      ADDR_WIDTH   : natural;
      RESULT_WIDTH : natural
    );
    port (
      clk       : in  std_logic;
      res       : in  std_logic;
      valid_in  : in  std_logic;
      switch    : in  std_logic;
      wr_addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      wr_data   : in  std_logic_vector(18-1 downto 0);
      zero      : in  std_logic;
      rd_en     : in  std_logic_vector(1 downto 0);
      rd_addr   : in  addr_array;
      ready_out : out std_logic;
      rd_data   : out data_array
    );
    end component accumulator_bank;
    
end package;