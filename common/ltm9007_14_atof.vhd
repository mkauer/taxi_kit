----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:18:20 03/27/2017 
-- Design Name: 
-- Module Name:    ltm9007_14 - Behavioral 
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
use IEEE.numeric_std.all;
use work.types.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ltm9007_14 is
	port(
		enc_p_0 : out std_logic;
		enc_n_0 : out std_logic;
		adcDataA_p_0 : in std_logic_vector(7 downto 0);
		adcDataA_n_0 : in std_logic_vector(7 downto 0);
		notChipSelectA_0 : out std_logic;
		notChipSelectB_0 : out std_logic;
		
		enc_p_1 : out std_logic;
		enc_n_1 : out std_logic;
		adcDataA_p_1 : in std_logic_vector(7 downto 0);
		adcDataA_n_1 : in std_logic_vector(7 downto 0);
		notChipSelectA_1 : out std_logic;
		notChipSelectB_1 : out std_logic;
		
		enc_p_2 : out std_logic;
		enc_n_2 : out std_logic;
		adcDataA_p_2 : in std_logic_vector(7 downto 0);
		adcDataA_n_2 : in std_logic_vector(7 downto 0);
		notChipSelectA_2 : out std_logic;
		notChipSelectB_2 : out std_logic;
		
		
		mosi : out std_logic;
		sclk : out std_logic;
		
		drs4_to_ltm9007_14 : in drs4_to_ltm9007_14_t;
		--drs4Clocks : in drs4Clocks_t;
		--adcFifo : out adcFifo_t;
		ltm9007_14_to_eventFifoSystem : out ltm9007_14_to_eventFifoSystem_t;
		adcClocks : in adcClocks_t;
		
		registerRead : out ltm9007_14_registerRead_t;
		registerWrite : in ltm9007_14_registerWrite_t	
	);
end ltm9007_14;

architecture Behavioral of ltm9007_14 is
	attribute keep : string;
	
	signal ioClockA_p : std_logic := '0';
	signal ioClockA_n : std_logic := '0';
	signal ioClockB_p : std_logic := '0';
	signal ioClockB_n : std_logic := '0';
	--signal serdesStrobeA : std_logic := '0';
	--signal serdesStrobeB : std_logic := '0';
	--signal serdesDivClockA : std_logic := '0';
	--signal serdesDivClockB : std_logic := '0';
	signal frameOutGroupA : std_logic_vector(7-1 downto 0) := (others=>'0');
	signal frameOutGroupB : std_logic_vector(7-1 downto 0) := (others=>'0');
	signal dataOutGroupA : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	signal dataOutGroupB : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	signal dataOutGroupC : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	signal dataOutGroupD : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	signal dataOutGroupE : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	signal dataOutGroupF : std_logic_vector(7*4-1 downto 0) := (others=>'0');
	--type adcDataGroup_t is array (0 to 2) of std_logic_vector(3 downto 0);
	--signal adcDataGroupA_p : adcDataGroup_t;
	--signal adcDataGroupA_n : adcDataGroup_t;
	--signal adcDataGroupB_p : adcDataGroup_t;
	--signal adcDataGroupB_n : adcDataGroup_t;
	signal adcDataGroupA_n : std_logic_vector(3 downto 0);
	signal adcDataGroupB_n : std_logic_vector(3 downto 0);
	signal adcDataGroupC_n : std_logic_vector(3 downto 0);
	signal adcDataGroupD_n : std_logic_vector(3 downto 0);
	signal adcDataGroupE_n : std_logic_vector(3 downto 0);
	signal adcDataGroupF_n : std_logic_vector(3 downto 0);
	signal adcDataGroupA_p : std_logic_vector(3 downto 0);
	signal adcDataGroupB_p : std_logic_vector(3 downto 0);
	signal adcDataGroupC_p : std_logic_vector(3 downto 0);
	signal adcDataGroupD_p : std_logic_vector(3 downto 0);
	signal adcDataGroupE_p : std_logic_vector(3 downto 0);
	signal adcDataGroupF_p : std_logic_vector(3 downto 0);
	signal dataOutGroupA_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal dataOutGroupB_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal dataOutGroupC_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal dataOutGroupD_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal dataOutGroupE_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal dataOutGroupF_buffer : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutA : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutB : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutC : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutD : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutE : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoOutF : std_logic_vector(14*4-1 downto 0) := (others=>'0');
	signal fifoWordsA : std_logic_vector(4 downto 0) := (others=>'0');
	signal fifoReadClock : std_logic := '0';
	signal enc : std_logic := '0';
	signal reset : std_logic := '0';
	
	type stateAdcFifoData_t is (idle, skip, valid1, valid2);
	signal stateAdcFifoData : stateAdcFifoData_t := idle;
	type stateAdcFifo_t is (sync1, sync2, sample1, sample2);
	signal stateAdcFifo : stateAdcFifo_t := sync1;

	signal fifoWriteEnableAtoF : std_logic := '0';
	signal fifoReadEnableAtoF : std_logic := '0';
	signal fifoReset : std_logic := '0';
	signal fifoReset_TPTHRU_TIG : std_logic := '0';
	attribute keep of fifoReset_TPTHRU_TIG: signal is "true";
	signal fifoReset_sync : std_logic := '0';
	--signal fifoResetB : std_logic := '0';
	
	signal fifoEmptyA : std_logic := '0';
	signal fifoEmptyB : std_logic := '0';

	signal eventFifoOverflowA : std_logic := '0';
	signal eventFifoOverflowA_66 : std_logic := '0';
	--signal eventFifoOverflowB : std_logic := '0';
	signal eventFifoUnderflowA : std_logic := '0';
	--signal eventFifoUnderflowB : std_logic := '0';
	signal eventFifoFullA : std_logic := '0';
	signal eventFifoFullA_TPTHRU_TIG : std_logic := '0';
	
	signal eventFifoFullA_old : std_logic := '0';
	signal eventFifoOverflowA_old : std_logic := '0';
	signal eventFifoUnderflowA_old : std_logic := '0';
	signal eventFifoOverflowCounterA : unsigned(15 downto 0) := (others=>'0');
	signal eventFifoUnderflowCounterA : unsigned(15 downto 0) := (others=>'0');
	signal eventFifoFullCounterA : unsigned(15 downto 0) := (others=>'0');

	constant spiNumberOfBits : integer := 8;
	constant sclkDivisor : unsigned(3 downto 0) := x"3"; -- ((systemClock / spiClock) / 2) ... 2=~29.7MHz@118.75MHz
	constant sclkDefaultLevel : std_logic := '0';
	constant mosiDefaultLevel : std_logic := '0';
	signal spiBusy : std_logic := '0';
	signal spiTransfer : std_logic := '0';
	signal spiTransfer_old : std_logic := '0';
	signal spiCounter : integer range 0 to spiNumberOfBits := 0;
	signal sclkDivisorCounter : unsigned (3 downto 0) := x"0";
	signal sclk_i : std_logic := '0';
	signal sclkEnable : std_logic := '0';
	signal sclkEdgeRising : std_logic := '0';
	signal sclkEdgeFalling : std_logic := '0';
	signal txBuffer : std_logic_vector(15 downto 0);
	type stateSpi_t is (idle,transfer,transferEnd);
	signal stateSpi : stateSpi_t := idle;

	type spiTransferMode_t is (sampleNormalMode, sampleTransparentMode, standby, regionOfIntrest, fullReadout, readShiftRegister_write, writeShiftRegister_write, configRegister_write, writeConfigRegister_write);
	signal spiTransferMode : spiTransferMode_t := sampleNormalMode;
	signal bitCounter : integer range 0 to 31 := 0;
	signal spiDone : std_logic := '0';

	signal notChipSelect : std_logic_vector(5 downto 0);
	signal message : std_logic_vector(notChipSelect'length+15 downto 0);
	constant MSG_write_softReset : std_logic_vector(15 downto 0) := "0" & "0000000" & x"80";
	constant MSG_write_formatAndPower : std_logic_vector(15 downto 0) := "0" & "0000001" & x"00"; -- "20" for 2'compliment
	constant MSG_write_outputMode : std_logic_vector(15 downto 0) := "0" & "0000010" & x"85"; -- "85" 3.0mA + X
	constant MSG_write_testPatternOffHigh : std_logic_vector(15 downto 0) := "0" & "0000011" & "00000000";
	constant MSG_write_testPatternOffLow : std_logic_vector(15 downto 0) := "0" & "0000011" & "00000000";
	--constant MSG_write_testPatternOnHigh : std_logic_vector(15 downto 0) := "0" & "0000011" & "10000011";
	--constant MSG_write_testPatternLow : std_logic_vector(15 downto 0) := "0" & "0000100" & "11001101";
	constant MSG_write_testPattern1High : std_logic_vector(15 downto 0) := "0" & "0000011" & "10010101";
	constant MSG_write_testPattern1Low : std_logic_vector(15 downto 0) := "0" & "0000100" & "01010101";
	constant MSG_write_testPattern2High : std_logic_vector(15 downto 0) := "0" & "0000011" & "10000000";
	constant MSG_write_testPattern2Low : std_logic_vector(15 downto 0) := "0" & "0000100" & "00000001";
	constant MSG_write_testPattern3High : std_logic_vector(15 downto 0) := "0" & "0000011" & "10111111";
	constant MSG_write_testPattern3Low : std_logic_vector(15 downto 0) := "0" & "0000100" & "11111111";
	constant MSG_write_testPattern4High : std_logic_vector(15 downto 0) := "0" & "0000011" & "10000000";
	constant MSG_write_testPattern4Low : std_logic_vector(15 downto 0) := "0" & "0000100" & "00000000";
	constant MSG_write_testPatternBitslipHigh : std_logic_vector(15 downto 0) := "0" & "0000011" & "10101001";
	constant MSG_write_testPatternBitslipLow : std_logic_vector(15 downto 0) := "0" & "0000100" & "11010011";
	constant MSG_write_testPatternXHigh : std_logic_vector(9 downto 0) := "0" & "0000011" & "10";
	constant MSG_write_testPatternXLow : std_logic_vector(7 downto 0) := "0" & "0000100";
	type stateAdc_t is (idle,init1,init2,init3,init4,init5,init6,init7,init8,init9,init10,init11,init12,init13,init14,init15,init16,init17);
	signal stateAdc : stateAdc_t := init1;
	
	signal bitslipStart1 : std_logic := '0';
	signal bitslipStartLatched : std_logic := '0';
	signal bitslipStartLatched_TPTHRU_TIG : std_logic := '0';
	attribute keep of bitslipStartLatched_TPTHRU_TIG: signal is "true";
	signal bitslipStartLatched_sync : std_logic := '0';
	signal bitslipStart2 : std_logic := '0';
	signal bitslipFailed : std_logic_vector(1 downto 0) := (others=>'0');
	signal bitslipFailed_TPTHRU_TIG : std_logic_vector(1 downto 0) := (others=>'0');
	attribute keep of bitslipFailed_TPTHRU_TIG: signal is "true";
	signal bitslipFailed_sync : std_logic_vector(1 downto 0) := (others=>'0');
	signal bitslipPattern : std_logic_vector(6 downto 0);
	signal bitslipPattern_TPTHRU_TIG : std_logic_vector(6 downto 0);
	signal bitslipPatternOverride :  std_logic := '0';
	signal bitslipDone : std_logic_vector(5 downto 0) := (others=>'0');
	signal bitslipDone_TPTHRU_TIG : std_logic_vector(5 downto 0) := (others=>'0');
	attribute keep of bitslipDone_TPTHRU_TIG: signal is "true";
	--signal bitslipDone_sync : std_logic_vector(1 downto 0) := (others=>'0');
	signal bitslipDoneSync1 : std_logic_vector(4 downto 0);
	signal bitslipDoneSync2 : std_logic_vector(4 downto 0);
	signal bitslipDoneSyncLatched1 : std_logic := '0';
	signal bitslipDoneSyncLatched2 : std_logic := '0';
	signal bitslipDoneSync : std_logic := '0';
	signal timeoutBitslip : unsigned(15 downto 0) := x"ffff";
	
	signal adcDataValid : std_logic := '0';
	signal adcDataSkipCounter : integer range 0 to 31 := 0;
	signal adcDataValidCounter : unsigned(15 downto 0) := (others=>'0');
	signal adcDataStart_old : std_logic := '0';
	
	signal numberOfSamplesToRead : std_logic_vector(15 downto 0);
	signal numberOfSamplesToRead_TPTHRU_TIG : std_logic_vector(15 downto 0);
	attribute keep of numberOfSamplesToRead_TPTHRU_TIG: signal is "true";
	signal numberOfSamplesToRead_sync : std_logic_vector(15 downto 0);
--	signal numberOfSamplesToRead2 : std_logic_vector(15 downto 0);
	signal numberOfSamplesToReadLatched : std_logic_vector(15 downto 0);
	signal adcDataFifoCounter : unsigned(15 downto 0) := (others=>'0');
	
	signal offsetCorrectionRamAddress : std_logic_vector(9 downto 0);
	signal offsetCorrectionRamData_0 : data8x16Bit_t;
	signal offsetCorrectionRamData_1 : data8x16Bit_t;
	signal offsetCorrectionRamData_2 : data8x16Bit_t;
	
	type stateFifoRead_t is (idle,read1,read2,done);
	signal stateFifoRead : stateFifoRead_t := idle;
	
	signal adcDataStartSync : std_logic_vector(3 downto 0);
	signal adcDataStartLatched : std_logic := '0';
	signal roiBufferReadyLatched : std_logic := '0';
	signal adcDataStart : std_logic := '0';
	signal adcDataStart_66 : std_logic := '0';
	signal adcDataStart_66_TPTHRU_TIG : std_logic := '0';
	attribute keep of adcDataStart_66_TPTHRU_TIG: signal is "true";
	
	signal chargeBuffer : data8x24Bit_t;
	signal baselineBuffer : data8x24Bit_t;
	signal baselineStart : std_logic_vector(9 downto 0);
	signal baselineEnd : std_logic_vector(9 downto 0);
	
begin

	process (registerWrite.clock) begin
	if rising_edge(registerWrite.clock) then
	numberOfSamplesToRead_TPTHRU_TIG <= registerWrite.numberOfSamplesToRead;
	end if;
	end process;
	numberOfSamplesToRead_sync <= numberOfSamplesToRead_TPTHRU_TIG;

	fifoReset_TPTHRU_TIG <= fifoReset; 
	fiforeset_sync <= fifoReset_TPTHRU_TIG; 
	
	bitslipFailed_TPTHRU_TIG <= bitslipFailed;
	bitslipFailed_sync <= bitslipFailed_TPTHRU_TIG;
	
	bitslipDone_TPTHRU_TIG <= bitslipDone; 
	--bitslipDone_sync <= bitslipDone_TPTHRU_TIG; 
	
	bitslipStartLatched_TPTHRU_TIG <= bitslipStartLatched;
	bitslipStartLatched_sync <= bitslipStartLatched_TPTHRU_TIG;

	adcDataStart_66_TPTHRU_TIG <= drs4_to_ltm9007_14.adcDataStart_66;
	adcDataStart_66 <= drs4_to_ltm9007_14.adcDataStart_66;
	
	adcDataGroupA_p <= adcDataA_p_0(7) & adcDataA_p_0(4) & adcDataA_p_0(3) & adcDataA_p_0(0);
	adcDataGroupA_n <= adcDataA_n_0(7) & adcDataA_n_0(4) & adcDataA_n_0(3) & adcDataA_n_0(0);
	adcDataGroupB_p <= adcDataA_p_0(6) & adcDataA_p_0(5) & adcDataA_p_0(2) & adcDataA_p_0(1);
	adcDataGroupB_n <= adcDataA_n_0(6) & adcDataA_n_0(5) & adcDataA_n_0(2) & adcDataA_n_0(1);
	
	adcDataGroupC_p <= adcDataA_p_1(7) & adcDataA_p_1(4) & adcDataA_p_1(3) & adcDataA_p_1(0);
	adcDataGroupC_n <= adcDataA_n_1(7) & adcDataA_n_1(4) & adcDataA_n_1(3) & adcDataA_n_1(0);
	adcDataGroupD_p <= adcDataA_p_1(6) & adcDataA_p_1(5) & adcDataA_p_1(2) & adcDataA_p_1(1);
	adcDataGroupD_n <= adcDataA_n_1(6) & adcDataA_n_1(5) & adcDataA_n_1(2) & adcDataA_n_1(1);
	
	adcDataGroupE_p <= adcDataA_p_2(7) & adcDataA_p_2(4) & adcDataA_p_2(3) & adcDataA_p_2(0);
	adcDataGroupE_n <= adcDataA_n_2(7) & adcDataA_n_2(4) & adcDataA_n_2(3) & adcDataA_n_2(0);
	adcDataGroupF_p <= adcDataA_p_2(6) & adcDataA_p_2(5) & adcDataA_p_2(2) & adcDataA_p_2(1);
	adcDataGroupF_n <= adcDataA_n_2(6) & adcDataA_n_2(5) & adcDataA_n_2(2) & adcDataA_n_2(1);

	reset <= registerWrite.reset;
	bitslipPattern <= registerWrite.bitslipPattern when (bitslipPatternOverride = '0') else "1100101";
	bitslipStart1 <= registerWrite.bitslipStart or bitslipStart2;
	--registerRead.bitslipFailed <= bitslipFailed; -- ## sync
	registerRead.bitslipPattern <= registerWrite.bitslipPattern;
	
	registerRead.testMode <= registerWrite.testMode;
	registerRead.testPattern <= registerWrite.testPattern;
	
	registerRead.offsetCorrectionRamAddress <= registerWrite.offsetCorrectionRamAddress;
	registerRead.offsetCorrectionRamWrite <= registerWrite.offsetCorrectionRamWrite;
	
	ltm9007_14_to_eventFifoSystem.roiBuffer <= drs4_to_ltm9007_14.roiBuffer;
	ltm9007_14_to_eventFifoSystem.roiBufferReady <= drs4_to_ltm9007_14.roiBufferReady;
	ltm9007_14_to_eventFifoSystem.realTimeCounter_latched <= drs4_to_ltm9007_14.realTimeCounter_latched;
	
	ltm9007_14_to_eventFifoSystem.maxValue <= (others=>(others=>'0'));

	sclk <= sclk_i;

	x6a: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupA_p, adcDataGroupA_n, adcClocks, bitslipStartLatched_sync, bitslipDone(0), open, "1100101", "00", dataOutGroupA, open);
	x7a: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupB_p, adcDataGroupB_n, adcClocks, bitslipStartLatched_sync, bitslipDone(1), open, "1100101", "00", dataOutGroupB, open);
	x6b: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupC_p, adcDataGroupC_n, adcClocks, bitslipStartLatched_sync, bitslipDone(2), open, "1100101", "00", dataOutGroupC, open);
	x7b: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupD_p, adcDataGroupD_n, adcClocks, bitslipStartLatched_sync, bitslipDone(3), open, "1100101", "00", dataOutGroupD, open);
	x6c: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupE_p, adcDataGroupE_n, adcClocks, bitslipStartLatched_sync, bitslipDone(4), open, "1100101", "00", dataOutGroupE, open);
	x7c: entity work.serdesIn_1to7 generic map(7,4,true,"PER_CHANL") port map('1', adcDataGroupF_p, adcDataGroupF_n, adcClocks, bitslipStartLatched_sync, bitslipDone(5), open, "1100101", "00", dataOutGroupF, open);

	x107a: OBUFDS port map(O => enc_p_0, OB => enc_n_0, I => enc);
	x107b: OBUFDS port map(O => enc_p_1, OB => enc_n_1, I => enc);
	x107c: OBUFDS port map(O => enc_p_2, OB => enc_n_2, I => enc);
	
	x108: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync, -- 66 ??
		wr_clk => adcClocks.serdesDivClock, -- 66 ok --serdesDivClockA,
		rd_clk => fifoReadClock, -- 125 ok
		din => dataOutGroupA_buffer, -- 66 ok
		wr_en => fifoWriteEnableAtoF, -- 66 ok
		rd_en => fifoReadEnableAtoF, -- 125 ok
		dout => fifoOutA, -- 125 ok 
		full => eventFifoFullA_TPTHRU_TIG, -- 125 xx
		overflow => eventFifoOverflowA_66, -- 125 xx
		empty => fifoEmptyA, -- 125 ok
		valid => fifoValidA, -- 125 ok
		underflow => eventFifoUnderflowA, -- 125 ok
		rd_data_count => fifoWordsA(3 downto 0), -- 125 ok
		wr_data_count => open --registerRead.fifoWordsA2(3 downto 0) -- 125 xx
	);
	x109: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync,
		wr_clk => adcClocks.serdesDivClock, --serdesDivClockB,
		rd_clk => fifoReadClock,
		din => dataOutGroupB_buffer,
		wr_en => fifoWriteEnableAtoF,
		rd_en => fifoReadEnableAtoF,
		dout => fifoOutB,
		full => open,
		overflow => open, --eventFifoOverflowB,
		empty => open,
		valid => open,
		underflow => open, --eventFifoUnderflowB,
		rd_data_count => open,
		wr_data_count => open
	);

	x108b: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync,
		wr_clk => adcClocks.serdesDivClock,
		rd_clk => fifoReadClock,
		din => dataOutGroupC_buffer,
		wr_en => fifoWriteEnableAtoF,
		rd_en => fifoReadEnableAtoF,
		dout => fifoOutC,
		full => open,
		overflow => open,
		empty => open,
		valid => open,
		underflow => open,
		rd_data_count => open,
		wr_data_count => open
	);
	x109b: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync,
		wr_clk => adcClocks.serdesDivClock,
		rd_clk => fifoReadClock,
		din => dataOutGroupD_buffer,
		wr_en => fifoWriteEnableAtoF,
		rd_en => fifoReadEnableAtoF,
		dout => fifoOutD,
		full => open,
		overflow => open,
		empty => open,
		valid => open,
		underflow => open,
		rd_data_count => open,
		wr_data_count => open
	);

	x108c: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync,
		wr_clk => adcClocks.serdesDivClock,
		rd_clk => fifoReadClock,
		din => dataOutGroupE_buffer,
		wr_en => fifoWriteEnableAtoF,
		rd_en => fifoReadEnableAtoF,
		dout => fifoOutE,
		full => open,
		overflow => open,
		empty => open,
		valid => open,
		underflow => open,
		rd_data_count => open,
		wr_data_count => open
	);
	x109c: entity work.drs4FrontEndFifo port map(
		rst => fifoReset_sync,
		wr_clk => adcClocks.serdesDivClock,
		rd_clk => fifoReadClock,
		din => dataOutGroupF_buffer,
		wr_en => fifoWriteEnableAtoF,
		rd_en => fifoReadEnableAtoF,
		dout => fifoOutF,
		full => open,
		overflow => open,
		empty => open,
		valid => open,
		underflow => open,
		rd_data_count => open,
		wr_data_count => open
	);





	fifoReadClock <= registerWrite.clock;
	--adcFifo.fifoOutA <= fifoOutA;
	--adcFifo.fifoOutB <= fifoOutB;
	fifoWordsA(4) <= eventFifoFullA_TPTHRU_TIG;
	--adcFifo.fifoWordsA <= fifoWordsA;
	--adcFifo.fifoWordsB <= fifoWordsB;
	registerRead.fifoValidA <= fifoValidA;
	registerRead.fifoEmptyA <= fifoEmptyA;
	registerRead.baselineStart <= registerWrite.baselineStart;
	registerRead.baselineEnd <= registerWrite.baselineEnd;

	--registerRead.fifoWordsA <= "000" & fifoWordsA; -- now sync

	--process (registerWrite.clock)
	--begin
	--	if rising_edge(registerWrite.clock) then
	--		fiforeset_sync <= fifoReset_TPTHRU_TIG; 
	--	end if;
	--end process;

	g110: for i in 0 to 7 generate
		x110: entity work.drs4OffsetCorrectionRam port map(
			registerWrite.clock,
			registerWrite.reset,
			registerWrite.offsetCorrectionRamWrite(i downto i),
			registerWrite.offsetCorrectionRamAddress,
			registerWrite.offsetCorrectionRamData,
			registerRead.offsetCorrectionRamData(i), -- ## implement mux here....
			registerWrite.clock,
			'0',
			"0",
			offsetCorrectionRamAddress,
			x"0000",
			offsetCorrectionRamData(i)
		);
	end generate;

	notChipSelectA_0 <= notChipSelect(0);
	notChipSelectB_0 <= notChipSelect(1);
	notChipSelectA_1 <= notChipSelect(2);
	notChipSelectB_1 <= notChipSelect(3);
	notChipSelectA_2 <= notChipSelect(4);
	notChipSelectB_2 <= notChipSelect(5);

	P0:process (registerWrite.clock)
	begin
		if rising_edge(registerWrite.clock) then
			sclkEdgeRising <= '0'; -- autoreset
			sclkEdgeFalling <= '0'; -- autoreset
			sclkEnable <= '0'; -- autoreset
			spiDone <= '0'; -- autoreset
			spiBusy <= '0'; -- autoreset
			registerRead.fifoWordsA <= "000" & fifoWordsA;
			registerRead.bitslipFailed <= bitslipFailed_sync;
			if (registerWrite.reset = '1') then
				sclkDivisorCounter <= to_unsigned(0, sclkDivisorCounter'length);
				sclk_i <= sclkDefaultLevel;
				stateSpi <= idle;
				notChipSelect <= (others=>'1');
			else
				if (sclkEnable = '1') then
					if (sclkDivisorCounter = sclkDivisor) then
						sclkDivisorCounter <= to_unsigned(0, sclkDivisorCounter'length);
						
						sclk_i <= not sclk_i;
						if ((sclk_i = '0')) then
							sclkEdgeRising <= '1'; -- autoreset
						end if;
						if ((sclk_i = '1')) then
							sclkEdgeFalling <= '1'; -- autoreset
						end if;
					else
						sclkDivisorCounter <= sclkDivisorCounter + 1;
					end if;
				else
					sclk_i <= sclkDefaultLevel;
					sclkDivisorCounter <= to_unsigned(0, sclkDivisorCounter'length);
				end if;

				spiTransfer_old <= spiTransfer;
				
				case stateSpi is	
					when idle =>
						--notChipSelectA <= '1';
						--notChipSelectB <= '1';
						notChipSelect <= (others=>'1');
						if((spiTransfer_old = '0') and (spiTransfer = '1')) then							
							txBuffer <= message(15 downto 0);
							notChipSelect <= message(21 downto 16);
							--if(message(16) = '0') then
							--	notChipSelectA <= '0';
							--else
							--	notChipSelectB <= '0';
							--end if;
							stateSpi <= transfer;
							bitCounter <= 15;
						end if;

					when transfer =>
						sclkEnable <= '1'; -- autoreset
						spiBusy <= '1'; -- autoreset

						--if (sclkEdgeRising = '1') then
						if (sclkEdgeFalling = '1') then
							--if((bitCounter /= 0) and (bitCounter /= 16)) then
								txBuffer <= txBuffer(txBuffer'length-2 downto 0) & mosiDefaultLevel;
							--end if;
							bitCounter <= bitCounter - 1;
							if (bitCounter = 0) then
								stateSpi <= transferEnd;
								bitCounter <= 0;
							end if;
						end if;
						
					when transferEnd =>
						spiBusy <= '1'; -- autoreset
						bitCounter <= bitCounter + 1;
						if(bitCounter >= 4) then -- ## may be we dont have to wait at all ...
						--if (sclkEdgeRising = '1') then
							--registerRead.regionOfInterest <= roiBuffer;
							stateSpi <= idle;
							txBuffer <= (others=>'0');
							spiDone <= '1'; -- autoreset
						end if;		
						
					when others => null;
				end case;
			end if;
		end if;
	end process P0;

	mosi <= txBuffer(txBuffer'length-1);

	P1:process (registerWrite.clock)
	begin
		if rising_edge(registerWrite.clock) then
			spiTransfer <= '0'; -- autoreset
			bitslipStart2 <= '0'; -- autoreset	
			bitslipStartLatched <= bitslipStart1;
			bitslipPattern_TPTHRU_TIG <= bitslipPattern;
			if (registerWrite.reset = '1') then				
				stateAdc <= init1;
				message <= (others=>'0');
				bitslipDoneSync1 <= (others=>'0');
				bitslipDoneSync2 <= (others=>'0');
				bitslipDoneSync <= '0';
				bitslipDoneSyncLatched1 <= '0';
				bitslipDoneSyncLatched2 <= '0';
				bitslipPatternOverride <= '0';
			else
				bitslipDoneSync1 <= bitslipDone_TPTHRU_TIG(0) & bitslipDoneSync1(bitslipDoneSync1'length-1 downto 1); <== 2..5
				bitslipDoneSync2 <= bitslipDone_TPTHRU_TIG(1) & bitslipDoneSync2(bitslipDoneSync2'length-1 downto 1);
				
				bitslipDoneSyncLatched1 <= bitslipDoneSync1(0) or bitslipDoneSyncLatched1;
				bitslipDoneSyncLatched2 <= bitslipDoneSync2(0) or bitslipDoneSyncLatched2;
				bitslipDoneSync <= bitslipDoneSyncLatched1 and bitslipDoneSyncLatched2;

				case stateAdc is
					when idle =>
						if(registerWrite.init = '1') then
							stateAdc <= init1;
						end if;

					when init1 =>
						if(spiBusy = '0') then
							stateAdc <= init2;
						end if;
						
					when init2 =>
						message <= "111111" & MSG_write_softReset;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= init3;
							spiTransfer <= '0'; -- autoreset
						end if;
					
					when init3 =>
						message <= "111111" & MSG_write_formatAndPower;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= init4;
							spiTransfer <= '0'; -- autoreset
						end if;
						
					when init4 =>
						message <= "111111" & MSG_write_outputMode;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= init5;
							spiTransfer <= '0'; -- autoreset
						end if;
						
					when init5 =>
						if(registerWrite.testMode = x"1") then
							message <= "111111" & MSG_write_testPatternXLow & registerWrite.testPattern(7 downto 0);
						else
							--message <= "0" & MSG_write_testPatternOffLow;
							message <= "111111" & MSG_write_testPatternBitslipLow;
						end if;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= init6;
							spiTransfer <= '0'; -- autoreset
						end if;

					when init6 =>
						if(registerWrite.testMode = x"1") then
							message <= "111111" & MSG_write_testPatternXHigh & registerWrite.testPattern(13 downto 8);
						else
							--message <= "0" & MSG_write_testPatternOffHigh;
							message <= "111111" & MSG_write_testPatternBitslipHigh;
						end if;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= init7;
							spiTransfer <= '0'; -- autoreset
						end if;

					when init7 =>
						if(registerWrite.testMode = x"1") then
							stateAdc <= idle;
						else
							stateAdc <= init13;
							timeoutBitslip <= x"0000";
						end if;
					
					when init13 =>
						timeoutBitslip <= timeoutBitslip + 1;
						if(timeoutBitslip = x"ffff") then
							stateAdc <= init14;
							timeoutBitslip <= x"0000";
						end if;
						if(timeoutBitslip > x"fff0") then
							bitslipStart2 <= '1'; -- autoreset	
						end if;
					
					when init14 =>
						bitslipStart2 <= '1'; -- autoreset
						bitslipDoneSync <= '0';
						bitslipPatternOverride <= '1';
						bitslipDoneSyncLatched1 <= '0';
						bitslipDoneSyncLatched2 <= '0';
						stateAdc <= init15;
						
					when init15 =>
						timeoutBitslip <= timeoutBitslip + 1;
						if(timeoutBitslip = x"ffff") then
							stateAdc <= init13;
							timeoutBitslip <= x"0000";
						end if;
						if(bitslipDoneSync = '1') then
							bitslipPatternOverride <= '0';
							stateAdc <= init16;
							timeoutBitslip <= x"0000";
						end if;

					when init16 =>
						message <= "111111" & MSG_write_testPatternOffHigh;
						spiTransfer <= '1'; -- autoreset
						if(spiDone = '1') then
							stateAdc <= idle;
							spiTransfer <= '0'; -- autoreset
						end if;
						
					when others => stateAdc <= idle;
				end case;	
			end if;
		end if;
	end process P1;
	
	P02:process (registerWrite.clock)
	begin
		if rising_edge(registerWrite.clock) then
			adcDataStartSync <= adcDataStart_66_TPTHRU_TIG & adcDataStartSync(adcDataStartSync'length-1 downto 1);
			if (registerWrite.reset = '1') then
				adcDataStart <= '0';
			else
				if((adcDataStartSync(1) = '1') and (adcDataStartSync(0) = '0')) then
					adcDataStart <= '1';
				else
					adcDataStart <= '0';
				end if;
			end if;
		end if;
	end process P02;

P9:process (adcClocks.serdesDivClock) -- ~66 MHz
begin
	if rising_edge(adcClocks.serdesDivClock) then
		adcDataValid <= '0'; -- autoreset
		--if (registerWrite.reset = '1') then -- ## sync?!
		if (adcClocks.serdesDivClockReset = '1') then
			stateAdcFifoData <= idle;
			adcDataStart_old <= '0';
			numberOfSamplesToRead <= (others=>'0'); 
			--numberOfSamplesToRead2 <= (others=>'0'); 
		else
			adcDataStart_old <= adcDataStart_66;
			numberOfSamplesToRead <= numberOfSamplesToRead_sync; -- ## inconsistent naming... 
			--numberOfSamplesToRead2 <= numberOfSamplesToRead1;
			
			case stateAdcFifoData is
				when idle =>
					adcDataSkipCounter <= 1;
					if(adcDataStart_old = '0' and adcDataStart_66 = '1') then
						stateAdcFifoData <= skip;
					end if;
					
				when skip =>
					adcDataSkipCounter <= adcDataSkipCounter + 1;
					if(adcDataSkipCounter >= 6) then
						stateAdcFifoData <= valid1;
						adcDataValidCounter <= unsigned(numberOfSamplesToRead); 
					end if;

				when valid1 =>
					adcDataValid <= '1'; -- autoreset
					stateAdcFifoData <= valid2;
					adcDataValidCounter <= adcDataValidCounter - 1;
				
				when valid2 =>
					adcDataValid <= '1'; -- autoreset
					--fifoWriteEnableAtoF <= adcDataValid; -- autoreset		
					stateAdcFifoData <= valid1;
					if(adcDataValidCounter = 0) then
						stateAdcFifoData <= idle;
					end if;

				when others => null;
			end case;
		end if;
	end if;
end process P9;

P10:process (adcClocks.serdesDivClock) -- ~66 MHz
begin
	if rising_edge(adcClocks.serdesDivClock) then
		fifoWriteEnableAtoF <= '0'; -- autoreset
		fifoReset <= '0'; -- autoreset
		--fifoResetB <= '0'; -- autoreset
		--if (registerWrite.reset = '1') then -- ## sync?!
		if (adcClocks.serdesDivClockReset = '1') then
			stateAdcFifo <= sync1;
		else
			case stateAdcFifo is				
				when sync1 =>
					-- set testbytes in adc ?!
					-- find start of values ?!
					fifoReset <= '1'; -- autoreset
					--fifoResetB <= '1'; -- autoreset
					stateAdcFifo <= sync2;
					
				when sync2 =>
					-- timeout for fifo reset...
					stateAdcFifo <= sample1;
				
				when sample1 =>
					stateAdcFifo <= sample2;
					for i in 0 to 3 loop
						dataOutGroupA_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupA(6+i*7 downto 0+i*7));	
						dataOutGroupB_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupB(6+i*7 downto 0+i*7));	
						dataOutGroupC_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupC(6+i*7 downto 0+i*7));	
						dataOutGroupD_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupD(6+i*7 downto 0+i*7));	
						dataOutGroupE_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupE(6+i*7 downto 0+i*7));	
						dataOutGroupF_buffer(13+i*14 downto 7+i*14) <= reverse_vector(dataOutGroupF(6+i*7 downto 0+i*7));	
					end loop;

				when sample2 =>
					stateAdcFifo <= sample1;
					for i in 0 to 3 loop
						dataOutGroupA_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupA(6+i*7 downto 0+i*7));
						dataOutGroupB_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupB(6+i*7 downto 0+i*7));
						dataOutGroupC_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupC(6+i*7 downto 0+i*7));
						dataOutGroupD_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupD(6+i*7 downto 0+i*7));
						dataOutGroupE_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupE(6+i*7 downto 0+i*7));
						dataOutGroupF_buffer(6+i*14 downto 0+i*14) <= reverse_vector(dataOutGroupF(6+i*7 downto 0+i*7));
					end loop;
					fifoWriteEnableAtoF <= adcDataValid; -- autoreset		
					
				when others => null;
			end case;
		end if;
	end if;
end process P10;

P4:process (registerWrite.clock)
	variable sampleBuffer_0 : data8x16Bit_t; 
	variable sampleBuffer_1 : data8x16Bit_t; 
	variable sampleBuffer_2 : data8x16Bit_t; 
begin
	if rising_edge(registerWrite.clock) then
		fifoReadEnableAtoF <= '0'; -- autoreset
		ltm9007_14_to_eventFifoSystem.newData <= '0'; -- autoreset
		ltm9007_14_to_eventFifoSystem.samplingDone <= '0'; -- autoreset
		ltm9007_14_to_eventFifoSystem.chargeDone <= '0'; -- autoreset
		ltm9007_14_to_eventFifoSystem.baselineDone <= '0'; -- autoreset
		if (registerWrite.reset = '1') then
			eventFifoFullCounterA <= to_unsigned(0,eventFifoFullCounterA'length);
			eventFifoOverflowCounterA <= to_unsigned(0,eventFifoOverflowCounterA'length);
			eventFifoUnderflowCounterA <= to_unsigned(0,eventFifoUnderflowCounterA'length);
			eventFifoOverflowA_old <= '0';
			eventFifoUnderflowA_old <= '0';
			eventFifoFullA_old <= '0';
			stateFifoRead <= idle;
			adcDataStartLatched <= '0';
			roiBufferReadyLatched <= '0';
		else
			eventFifoOverflowA <= eventFifoOverflowA_66;
			eventFifoOverflowA_old <= eventFifoOverflowA;
			eventFifoUnderflowA_old <= eventFifoUnderflowA;
			eventFifoFullA <= eventFifoFullA_TPTHRU_TIG;
			eventFifoFullA_old <= eventFifoFullA;
			
			if((eventFifoOverflowA_old = '0') and (eventFifoOverflowA = '1')) then
				eventFifoOverflowCounterA <= eventFifoOverflowCounterA + 1;
			end if;
			
			if((eventFifoUnderflowA_old = '0') and (eventFifoUnderflowA = '1')) then
				eventFifoUnderflowCounterA <= eventFifoUnderflowCounterA + 1;
			end if;
			
			if((eventFifoFullA_old = '0') and (eventFifoFullA = '1')) then
				eventFifoFullCounterA <= eventFifoFullCounterA + 1;
			end if;

			--if(fifoWordsA > "11100") then
			--	fifoReadEnableA <= '1'; -- autoreset
			--	fifoReadEnableB <= '1'; -- autoreset
			--	-- error++
			--end if;
			--
			--if(drs4_to_ltm9007_14.drs4RoiValid = '1') then
			--	fifoReadEnableA <= '1'; -- autoreset
			--	fifoReadEnableB <= '1'; -- autoreset
			--end if;

			--debugA <= fifoReadEnableA;
			--debugB <= debugA;
			--debugC <= debugB;

			registerRead.fifoA <= fifoOutA;
			registerRead.fifoB <= fifoOutB;

			adcDataStartLatched <= adcDataStartLatched or adcDataStart;
			roiBufferReadyLatched <= roiBufferReadyLatched or drs4_to_ltm9007_14.roiBufferReady;

			case stateFifoRead is				
				when idle =>
					if((adcDataStartLatched = '1') and (roiBufferReadyLatched = '1')) then
						stateFifoRead <= read1;
						numberOfSamplesToReadLatched <= registerWrite.numberOfSamplesToRead;
						offsetCorrectionRamAddress <= drs4_to_ltm9007_14.roiBuffer;
						adcDataFifoCounter <= (others=>'0');
						chargeBuffer <= (others=>(others=>'0'));
						baselineBuffer <= (others=>(others=>'0'));
						baselineStart <= registerWrite.baselineStart;
						baselineEnd <= registerWrite.baselineEnd;
					end if;

				when read1 =>
					--if(fifoWordsA /= "00000") then
					if(fifoEmptyA = '0') then
						fifoReadEnableAtoF <= '1'; -- autoreset
						stateFifoRead <= read2;
					end if;
					
					if(adcDataFifoCounter >= unsigned(numberOfSamplesToReadLatched)) then
						stateFifoRead <= done;
					end if;
					
					--if(adcDataFifoCounter > unsigned(baselineEnd)) then
					--	ltm9007_14_to_eventFifoSystem.baseline <= baselineBuffer;
					--	ltm9007_14_to_eventFifoSystem.baselineDone <= '1'; -- autoreset
					--end if;	
			
				when read2 =>
					if(fifoValidA = '1') then -- ## fifo B is allways the same...
						--l0: for i in 0 to 3 loop
						--	sampleBuffer(i*2) := std_logic_vector(resize(unsigned(fifoOutA(13+i*14 downto 0+i*14)),16) + resize(unsigned(offsetCorrectionRamData(i)),16));
						--	sampleBuffer(i*2+1) := std_logic_vector(resize(unsigned(fifoOutB(13+i*14 downto 0+i*14)),16) + resize(unsigned(offsetCorrectionRamData(i+4)),16));
						--end loop;
							sampleBuffer_0(0) := std_logic_vector(resize(unsigned(fifoOutA(13+0*14 downto 0+0*14)),16) + resize(unsigned(offsetCorrectionRamData(0)),16));
							sampleBuffer_0(3) := std_logic_vector(resize(unsigned(fifoOutA(13+1*14 downto 0+1*14)),16) + resize(unsigned(offsetCorrectionRamData(3)),16));
							sampleBuffer_0(4) := std_logic_vector(resize(unsigned(fifoOutA(13+2*14 downto 0+2*14)),16) + resize(unsigned(offsetCorrectionRamData(4)),16));
							sampleBuffer_0(7) := std_logic_vector(resize(unsigned(fifoOutA(13+3*14 downto 0+3*14)),16) + resize(unsigned(offsetCorrectionRamData(7)),16));
							sampleBuffer_0(1) := std_logic_vector(resize(unsigned(fifoOutB(13+0*14 downto 0+0*14)),16) + resize(unsigned(offsetCorrectionRamData(1)),16));
							sampleBuffer_0(2) := std_logic_vector(resize(unsigned(fifoOutB(13+1*14 downto 0+1*14)),16) + resize(unsigned(offsetCorrectionRamData(2)),16));
							sampleBuffer_0(5) := std_logic_vector(resize(unsigned(fifoOutB(13+2*14 downto 0+2*14)),16) + resize(unsigned(offsetCorrectionRamData(5)),16));
							sampleBuffer_0(6) := std_logic_vector(resize(unsigned(fifoOutB(13+3*14 downto 0+3*14)),16) + resize(unsigned(offsetCorrectionRamData(6)),16));
							
							sampleBuffer_1(0) := std_logic_vector(resize(unsigned(fifoOutC(13+0*14 downto 0+0*14)),16) + resize(unsigned(offsetCorrectionRamData_1(0)),16));
							sampleBuffer_1(3) := std_logic_vector(resize(unsigned(fifoOutC(13+1*14 downto 0+1*14)),16) + resize(unsigned(offsetCorrectionRamData_1(3)),16));
							sampleBuffer_1(4) := std_logic_vector(resize(unsigned(fifoOutC(13+2*14 downto 0+2*14)),16) + resize(unsigned(offsetCorrectionRamData_1(4)),16));
							sampleBuffer_1(7) := std_logic_vector(resize(unsigned(fifoOutC(13+3*14 downto 0+3*14)),16) + resize(unsigned(offsetCorrectionRamData_1(7)),16));
							sampleBuffer_1(1) := std_logic_vector(resize(unsigned(fifoOutD(13+0*14 downto 0+0*14)),16) + resize(unsigned(offsetCorrectionRamData_1(1)),16));
							sampleBuffer_1(2) := std_logic_vector(resize(unsigned(fifoOutD(13+1*14 downto 0+1*14)),16) + resize(unsigned(offsetCorrectionRamData_1(2)),16));
							sampleBuffer_1(5) := std_logic_vector(resize(unsigned(fifoOutD(13+2*14 downto 0+2*14)),16) + resize(unsigned(offsetCorrectionRamData_1(5)),16));
							sampleBuffer_1(6) := std_logic_vector(resize(unsigned(fifoOutD(13+3*14 downto 0+3*14)),16) + resize(unsigned(offsetCorrectionRamData_1(6)),16));

						l1: for i in 0 to 7 loop							
							ltm9007_14_to_eventFifoSystem.channel(i) <= sampleBuffer_0(i);
							chargeBuffer(i) <= std_logic_vector(unsigned(chargeBuffer(i)) + unsigned(sampleBuffer_0(i)));
						end loop;

						if((adcDataFifoCounter >= unsigned(baselineStart)) and (adcDataFifoCounter <= unsigned(baselineEnd))) then
							l2: for i in 0 to 7 loop							
								baselineBuffer(i) <= std_logic_vector(unsigned(baselineBuffer(i)) + unsigned(sampleBuffer_0(i)));
							end loop;
						end if;
					
						ltm9007_14_to_eventFifoSystem.newData <= '1'; -- autoreset
						offsetCorrectionRamAddress <= std_logic_vector(unsigned(offsetCorrectionRamAddress) + 1);
						adcDataFifoCounter <= adcDataFifoCounter + 1;
						stateFifoRead <= read1;
					end if;

					--if(adcDataFifoCounter >= unsigned(numberOfSamplesToReadLatched)) then
					--	stateFifoRead <= done;
					--end if;
					
				when done =>
					stateFifoRead <= idle;
					adcDataStartLatched <= '0';
					roiBufferReadyLatched <= '0';
					ltm9007_14_to_eventFifoSystem.samplingDone <= '1'; -- autoreset
					ltm9007_14_to_eventFifoSystem.charge <= chargeBuffer;
					ltm9007_14_to_eventFifoSystem.chargeDone <= '1'; -- autoreset
					ltm9007_14_to_eventFifoSystem.baseline <= baselineBuffer;
					ltm9007_14_to_eventFifoSystem.baselineDone <= '1'; -- autoreset
					
				when others => null;
			end case;
			
		end if;
	end if;
end process P4;


P5:process (adcClocks.serdesDivClock) -- 66MHz
begin
	if rising_edge(adcClocks.serdesDivClock) then
		if (adcClocks.serdesDivClockReset = '1') then -- ## sync?!
			enc <= '0';
		else
			enc <= not(enc);
		end if;
	end if;
end process P5;

end Behavioral;

