----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/22/2018 02:31:59 PM
-- Design Name:
-- Module Name: arbiter_cell - beh
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Arbiter cell for wavefront arbiter
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

entity arbiter_cell is
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
end arbiter_cell;

architecture beh of arbiter_cell is

begin

	grant <= x_in and y_in and request and ready;
	x_out <= x_in and not grant;
	y_out <= y_in and not grant;

end beh;
