----------------------------------------------------------------------------------
-- Company: TU Wien
-- Engineer: Clemens Pircher
--
-- Create Date: 05/14/2018 12:40:37 PM
-- Design Name:
-- Module Name: common_pkg
-- Project Name: SCNN
-- Target Devices:
-- Tool Versions:
-- Description: common types and constants
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package common_pkg is

-- general
constant RESET : std_logic := '0';											-- activity level of reset
  constant PES_PER_GROUP: integer := 8;
  constant BRAMS_PER_ACCUMULATOR: integer := 17;
  constant CROSSBAR_ADDRESS_WIDTH: integer := 5; --derivd from BRAMS_PER_ACCUMULATOR
  constant CROSSBAR_TAG_WIDTH : integer :=9; --512 values = 1 BRAM
  constant DATA_WIDTH_RESULT : integer := (8+1) *2;
  constant FIFO_DEPTH : Integer := 10;
  
--type slv_pair is record
--	slv1 : std_logic_vector;
--	slv2 : std_logic_vector;
--end record;
--type u_pair is record
--	u1 : unsigned;
--	u2 : unsigned;
--end record;
--type slv_array is array(integer range<>) of std_logic_vector;
--type slv_array2 is array(integer range<>) of slv_array;
--type  request_type is array(integer range<>) of std_logic_vector()

--type slv_pair_array is array(integer range<>) of slv_pair;
--type u_array is array(integer range<>) of unsigned;
--type u_array2 is array(integer range<>) of u_array;
--type u_pair_array is array(integer range<>) of u_pair;

end package common_pkg;
