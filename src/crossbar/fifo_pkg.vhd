----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/25/2018 11:50:27 AM
-- Design Name:
-- Module Name: fifo_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: FIFO package
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

package fifo_pkg is

	component fifo is
		generic
		(
			DATA_WIDTH : natural;	-- bitwidth of fifo entry
			FIFO_DEPTH : natural;	-- number of fifo entries
			FIFO_ALMOST_FULL: natural;
			PASS_THROUGH : boolean	-- whether pass-through is available
		);
		port
		(
			clk : in std_logic;
			res : in std_logic;
			wr_en : in std_logic;										-- write to fifo
			wr_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);		-- data to be written
			rd_en : in std_logic;										-- acknowledge output (fwft)
			rd_data : out std_logic_vector(DATA_WIDTH - 1 downto 0);	-- current data in fifo
			full : out std_logic;										-- asserts whether fifo is full
			empty : out std_logic;                                       -- asserts whether fifo is empty
			stall_en : out std_logic										-- asserts fifo threshold meet
		);
	end component fifo;

end fifo_pkg;
