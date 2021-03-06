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

entity smcBusWrapper is 
	generic (
		addressBitsUsed : integer range 0 to 31 := 16
	);

	port (
		chipSelect : in std_logic;
		addressAsync : in std_logic_vector(23 downto 0);
		controlRead : in std_logic;
		controlWrite : in std_logic;
		reset : in std_logic; -- syncron
		busClock : in std_logic;
		addressAndControlBus : out std_logic_vector(31 downto 0)
	);
end smcBusWrapper;

architecture behaviour of smcBusWrapper is
	signal controlBus : smc_bus;
	signal readSR : std_logic_vector(2 downto 0) := (others=>'0');
	signal writeSR : std_logic_vector(2 downto 0) := (others=>'0');
	signal address : std_logic_vector(23 downto 0) := (others=>'0');
begin
	addressAndControlBus <= smc_busToVector(controlBus);
	controlBus.address(23 downto 0) <= std_logic_vector(to_unsigned(0, controlBus.address'length-addressBitsUsed)) & address(addressBitsUsed-1 downto 0);
	controlBus.read <= controlRead;
	--controlBus.write <= controlWrite;
	controlBus.chipSelect <= '1' when ((chipSelect = '1') and (address(address'length-1 downto addressBitsUsed) = std_logic_vector(to_unsigned(0, address'length-addressBitsUsed)) )) else '0';
	controlBus.reset <= reset;
	controlBus.clock <= busClock;

	P2:process (busClock)
	begin
		if rising_edge(busClock) then
	-- additionomal multiplexing for even-only accsess: 	
--			if addressAsync(15 downto 14)="01" then  --modified addresse 4000 to 7fff
--				address(15 downto 0) <= "00" & addressAsync(13 downto 1) & "1";
--			elsif addressAsync(15 downto 14)="10" then  --modified addresse 8000 to bfff
--				address(15 downto 0) <= "11" & addressAsync(13 downto 1) & "1";
--			else
--				address(15 downto 0) <= addressAsync(15 downto 0);
--			end if;
		-- this is the same as above:
			if addressAsync(15)=addressAsync(14) then  -- addresse 0000 to 3fff or c000 to ffff -- normal adresses
--				address(0) <= addressAsync(0);
				address(0) <= '0'; -- only 16Bit aligned 
			else --modified addresse 4000 to bfff
				address(0) <= '1';
			end if;
			address(23 downto 1) <= addressAsync(23 downto 15) & addressAsync(15) & addressAsync(13 downto 1);
--			address(23 downto 0) <= addressAsync(23 downto 0);
			controlBus.writeStrobe <= '0'; -- autoreset
			controlBus.readStrobe <= '0'; -- autoreset
			if(reset = '1') then
				readSR <= (others=>'0');
				writeSR <= (others=>'0');
			else
				readSR(2 downto 0) <= readSR(1 downto 0) & controlRead;
				writeSR(2 downto 0) <= writeSR(1 downto 0) & controlWrite;
				if ((readSR(1)='1') and (readSR(2)='0')) then
					controlBus.readStrobe <= '1'; -- autoreset
				end if;
				if ((writeSR(1)='1') and (writeSR(2)='0')) then
					controlBus.writeStrobe <= '1'; -- autoreset
				end if;
			end if;
		end if;  
	end process P2;

end behaviour;
