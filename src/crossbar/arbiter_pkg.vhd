----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/23/2018 11:59:12 AM
-- Design Name:
-- Module Name: arbiter_cell_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Wavefront arbiter package
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.common_pkg.all;
--use work.crossbar_pkg.all;

package arbiter_pkg is
  

    constant NUM_OUTPUTS : integer := BRAMS_PER_ACCUMULATOR;
    constant DATA_WIDTH : integer := DATA_WIDTH_RESULT;
    constant ADDR_WIDTH : integer :=CROSSBAR_ADDRESS_WIDTH ;
    constant TAG_WIDTH : integer := CROSSBAR_TAG_WIDTH;

    type slv_out_type is array (Integer range<>) of std_logic_vector(NUM_OUTPUTS - 1 downto 0);
	type data_address_tag_type is array (Integer range<>) of std_logic_vector(DATA_WIDTH + ADDR_WIDTH + TAG_WIDTH - 1 downto 0);
	type data_type is array (Integer range<>) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type address_type is array (Integer range<>) of std_logic_vector(ADDR_WIDTH - 1 downto 0);
	type tag_type is array (Integer range<>) of std_logic_vector(TAG_WIDTH - 1 downto 0);
    
    
	component arbiter is
		generic
		(
			NUM_INPUTS : natural;	-- number of inputs
			NUM_OUTPUTS : natural	-- number of outputs
		);
		port
		(
			ready_in : in std_logic_vector(NUM_OUTPUTS - 1 downto 0);						-- ready signals from outputs
			requests : in slv_out_type(NUM_INPUTS - 1 downto 0);		-- request signals from inputs
			grants : out slv_out_type(NUM_INPUTS - 1 downto 0)		-- grant signals for crosspoints
		);
	end component arbiter;

end arbiter_pkg;
