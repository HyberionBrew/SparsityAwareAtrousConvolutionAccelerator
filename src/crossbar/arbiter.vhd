----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/23/2018 04:12:36 PM
-- Design Name:
-- Module Name: arbiter - beh
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: Wavefront arbiter for crossbars with #inputs <= #outputs
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

use work.arbiter_cell_pkg.all;
use work.arbiter_pkg.all;
use work.common_pkg.all;

entity arbiter is
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
end arbiter;

architecture beh of arbiter is

	signal x_connectors :slv_out_type(NUM_INPUTS - 1 downto 0);
	signal y_connectors : slv_out_type(NUM_INPUTS - 1 downto 0);

begin

	assert NUM_INPUTS <= NUM_OUTPUTS report "NUM_INPUTS must not be larger than NUM_OUTPUTS" severity failure;

	in_index : for i in 0 to NUM_INPUTS - 1 generate
		out_index : for o in 0 to NUM_OUTPUTS - 1 generate
			cells : if i = o generate
				inst : arbiter_cell			-- first wave, feed inputs with constant '1'
				port map
				(
					x_in => x_connectors(i)(o),
					y_in => y_connectors(i)(o),
					request => requests(i)(o),
					ready => ready_in(o),
					x_out => x_connectors((i + NUM_INPUTS - 1) mod NUM_INPUTS)(o),
					y_out => y_connectors(i)((o + 1) mod NUM_OUTPUTS),
					grant => grants(i)(o)
				);
				x_connectors(i)(o) <= '1';
				y_connectors(i)(o) <= '1';
			elsif i = (o + 1) mod NUM_OUTPUTS generate
				inst : arbiter_cell			-- last wave, ignore outputs
				port map
				(
					x_in => x_connectors(i)(o),
					y_in => y_connectors(i)(o),
					request => requests(i)(o),
					ready => ready_in(o),
					x_out => open,
					y_out => open,
					grant => grants(i)(o)
				);
			else generate
				cutoff : if i = 0 and o >= NUM_INPUTS - 1 generate
					inst : arbiter_cell		-- lower extension, do not wrap x_out around
					port map
					(
						x_in => x_connectors(i)(o),
						y_in => y_connectors(i)(o),
						request => requests(i)(o),
						ready => ready_in(o),
						x_out => open,
						y_out => y_connectors(i)((o + 1) mod NUM_OUTPUTS),
						grant => grants(i)(o)
					);
				elsif i = NUM_INPUTS - 1 and o > NUM_INPUTS - 1 generate
					inst : arbiter_cell		-- upper extension, set x_in to cosntant '1'
					port map
					(
						x_in => x_connectors(i)(o),
						y_in => y_connectors(i)(o),
						request => requests(i)(o),
						ready => ready_in(o),
						x_out => x_connectors((i + NUM_INPUTS - 1) mod NUM_INPUTS)(o),
						y_out => y_connectors(i)((o + 1) mod NUM_OUTPUTS),
						grant => grants(i)(o)
					);
					x_connectors(i)(o) <= '1';
				else generate
					inst : arbiter_cell		-- normal arbiter cell
					port map
					(
						x_in => x_connectors(i)(o),
						y_in => y_connectors(i)(o),
						request => requests(i)(o),
						ready => ready_in(o),
						x_out => x_connectors((i + NUM_INPUTS - 1) mod NUM_INPUTS)(o),
						y_out => y_connectors(i)((o + 1) mod NUM_OUTPUTS),
						grant => grants(i)(o)
					);
				end generate;

			end generate;

		end generate;
	end generate;

end beh;
