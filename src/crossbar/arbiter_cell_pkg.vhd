----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/23/2018 04:12:36 PM
-- Design Name:
-- Module Name: arbiter_cell_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Arbiter cell package
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

package arbiter_cell_pkg is

	component arbiter_cell is
		port
		(
			x_in : in std_logic;		-- input priority
			y_in : in std_logic;		-- output priority
			request : in std_logic;		-- request flag
			ready : in std_logic;		-- output ready flag
			x_out : out std_logic;		-- next input priority
			y_out : out std_logic;		-- next output priority
			grant : out std_logic		-- access grant flag
		);
	end component arbiter_cell;

end arbiter_cell_pkg;
