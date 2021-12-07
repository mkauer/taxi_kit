----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:18:09 03/01/2017 
-- Design Name: 
-- Module Name:    smcBusEntry - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
use work.types.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity I2CModule is
   port (clk     : in     std_logic; 
	--I2C Port:
	      scl: out STD_LOGIC;
			sdaout :			out  STD_LOGIC;
			sdaint :			in  STD_LOGIC;
-- Regs:
			registerRead : out i2c_registerRead_t;
			registerWrite : in i2C_registerWrite_t
);

end I2CModule;

architecture Behavioral of I2CModule is
signal timer: std_logic_vector(23 downto 0);
signal comand : std_logic_vector(47 downto 0);
signal idle       : std_logic_vector(3 downto 0);
signal data       : std_logic_vector(7 downto 0);
signal newcomand : std_logic;
	
	COMPONENT I2CMaster
	PORT(
		clk : IN std_logic;
		comand : IN std_logic_vector(47 downto 0);
		i2crxreg : out std_logic_vector(15 downto 0);    
		newcomand : in std_logic;
		idle : OUT std_logic;
		sdaout :			out  STD_LOGIC;
		sdaint :			in  STD_LOGIC;
		scl : OUT std_logic
		);
	END COMPONENT;


begin

	Inst_I2CMaster: I2CMaster PORT MAP(
		clk => clk,
		comand => registerWrite.comand,
		newcomand => registerWrite.start,
		i2crxreg => registerRead.readdata,
		idle => registerRead.idle,
		scl => scl,
		sdaint => sdaint,
		sdaout => sdaout
	);

end Behavioral;

