----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 07/04/2018 12:55:31 PM
-- Design Name:
-- Module Name: block_ram_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Block RAM package
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

package block_ram_pkg is

	component block_ram is
		generic
		(
			ADDR_WIDTH : natural;	-- bitwidth of address
			DATA_WIDTH : natural	-- bitwidth of data
		);
		port
		(
			clk : in std_logic;
			addr_a : in std_logic_vector(ADDR_WIDTH - 1 downto 0);	-- port a address
			addr_b : in std_logic_vector(ADDR_WIDTH - 1 downto 0);	-- port b address
			din_a : in std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port a write data
			din_b : in std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port b write data
			en_a : in std_logic;									-- port a enable
			en_b : in std_logic;									-- port b enable
			we_a : in std_logic;									-- port a write-enable
			we_b : in std_logic;									-- port b write-enable
			dout_a : out std_logic_vector(DATA_WIDTH - 1 downto 0);	-- port a read data
			dout_b : out std_logic_vector(DATA_WIDTH - 1 downto 0)	-- port b read data
		);
	end component block_ram;

end block_ram_pkg;
