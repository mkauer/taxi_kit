-------------------------------------------------------
-- Design Name      : taxi_003_top
-- File Name        : taxi_003_top.vhd
-- Device           : Spartan 6, XC6SLX45FGG484-2
-- Migration Device : Spartan 6, XC6SLX100FGG484-2
-- Function         : taxi top level test design rev-005
-- Coder(s)         : K.-H. Sulanke & S. Kunwar & M. Kossatz, DESY, 2016
-------------------------------------------------------
-- compiling duration = min
-- QOSC1_OUT, 25 MHz, 3.3V CMOS 2.5 ppm

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.types_platformSpecific.all;

library unisim;
use unisim.vcomponents.all;

entity taxiTop_iceScint is
	port
	(
		PON_RESETn      : in std_logic ;   -- 2.5V CMOS with pullup, reset (active low, by power monitor LTC2903-A1)
										   -- 200 ms after all power lines are settled, might be useless due to race condition
										   -- with FPGA configuration time
		QOSC1_OUT       : in std_logic ;   -- 2.5V CMOS, local CMOS clock osc.
		QOSC1_DAC_SYNCn : out std_logic ;  -- 2.5V CMOS, local CMOS clock

		QOSC2_OUT       : in std_logic ;   -- 2.5V CMOS, local CMOS clock osc.
		QOSC2_ENA       : out std_logic ;  -- 2.5V CMOS, local CMOS clock
		QOSC2_DAC_SYNCn : out std_logic ;  -- 2.5V CMOS,
		QOSC2_DAC_SCKL  : out std_logic ;  -- 2.5V CMOS,
		QOSC2_DAC_SDIN  : out std_logic ;  -- 2.5V CMOS,

		EXT_CLK_P       : in std_logic;    -- LVDS
		EXT_CLK_N       : in std_logic;    -- LVDS
		EXT_PPS_P       : in std_logic;    -- LVDS
		EXT_PPS_N       : in std_logic;    -- LVDS
		EXT_TRIG_OUT_P  : out std_logic;   -- LVDS
		EXT_TRIG_OUT_N  : out std_logic;   -- LVDS
		EXT_TRIG_IN_P   : in std_logic;    -- LVDS
		EXT_TRIG_IN_N   : in std_logic;    -- LVDS

		-- Discriminator output signals
--		DISCR_OUT_1P  : in std_logic_vector(7 downto 0); -- LVDS, discriminator outputs
--		DISCR_OUT_1N  : in std_logic_vector(7 downto 0);
		DISCR_OUT     : in std_logic_vector(7 downto 0);
		--DISCR_OUT_2P  : in std_logic_vector(7 downto 0); -- LVDS, discriminator outputs
		--DISCR_OUT_2N  : in std_logic_vector(7 downto 0);
		--DISCR_OUT_3P  : in std_logic_vector(7 downto 0); -- LVDS, discriminator outputs
		--DISCR_OUT_1N  : in std_logic_vector(7 downto 0);
		DISCR_OUT_Dummy : in std_logic_vector(11 downto 0);
--		NOT_USED_GND  : out std_logic_vector(7 downto 0); -- DISCR_OUT_2P + DISCR_OUT_3P
		PANEL_NP24V_ON  : out std_logic_vector(7 downto 0); -- DISCR_OUT_2N + DISCR_OUT_3N
--		PANEL_RS485_D : inout std_logic_vector(7 downto 0); -- DISCR_OUT_2N + DISCR_OUT_3N
		PANEL_RS485_RX : in std_logic_vector(7 downto 0); 
		PANEL_RS485_TX : out std_logic_vector(7 downto 0); 
		PANEL_RS485_DE : out std_logic_vector(7 downto 0); -- DISCR_OUT_2P + DISCR_OUT_3P

		-- trigger to be used by the AERA board
		AERA_TRIG_P   : out std_logic;    -- LVDS
		AERA_TRIG_N   : out std_logic;    -- LVDS

		-- ADC #1..3, LTM9007-14, 8 channel, ser out, 40 MSPS max., LVDS outputs
		-- the direction used for the pins is (0 to 7) but will be assigned to a (7 downto 0)
		-- we do this to compensate the non logical order in the pcb
		ADC_OUTA_1P   : in  std_logic_vector(0 to 7); -- LVDS, iserdes inputs
		ADC_OUTA_1N   : in  std_logic_vector(0 to 7);
		ADC_OUTA_2P   : in  std_logic_vector(0 to 7); -- LVDS, iserdes inputs
		ADC_OUTA_2N   : in  std_logic_vector(0 to 7);
		ADC_OUTA_3P   : in  std_logic_vector(0 to 7); -- LVDS, iserdes inputs
		ADC_OUTA_3N   : in  std_logic_vector(0 to 7);

		ADC_FRA_P    : in  std_logic_vector(1 to 3); -- Frame Start for Channels 1, 4, 5 and 8
		ADC_FRA_N    : in  std_logic_vector(1 to 3);
		ADC_FRB_P    : in  std_logic_vector(1 to 3); -- Frame Start for Channels 2, 3, 6 and 7
		ADC_FRB_N    : in  std_logic_vector(1 to 3);
		ADC_DCOA_P   : in  std_logic_vector(1 to 3); -- Data Clock for Channels 1, 4, 5 and 8
		ADC_DCOA_N   : in  std_logic_vector(1 to 3);
		ADC_DCOB_P   : in  std_logic_vector(1 to 3); -- Data Clock for Channels 2, 3, 6 and 7
		ADC_DCOB_N   : in  std_logic_vector(1 to 3);
		ADC_ENC_P    : out std_logic_vector(1 to 3); -- LVDS, conversion clock, conversion starts at rising edge
		ADC_ENC_N    : out std_logic_vector(1 to 3);
		ADC_PAR_SERn : out std_logic; -- Incorrect signal removed completely from design. This Should be tied to ground.
		ADC_SDI      : out std_logic; -- shared serial interface data input
		ADC_SCK      : out std_logic; -- shared serial interface clock input
		ADC_CSA      : out std_logic_vector(1 to 3); -- serial interfacechip select, channels 1, 4, 5 and 8
		ADC_CSB      : out std_logic_vector(1 to 3); -- serial interfacechip select, channels 2, 3, 6 and 7

		-- ADC LTC2173-14, 4 channel, ser out, 80 MSPS max., LVDS outputs
		ADC_OUTA_4P   : in  std_logic_vector(0 to 3); -- LVDS, oserdes data outputs
		ADC_OUTA_4N   : in  std_logic_vector(0 to 3);
		ADC_FR_4P     : in  std_logic;
		ADC_FR_4N     : in  std_logic;
		ADC_DCO_4P    : in  std_logic; -- Data Clock Outputs
		ADC_DCO_4N    : in  std_logic;
		ADC_ENC_4P    : out std_logic; -- LVDS, conversion clock, conversion starts at rising edge
		ADC_ENC_4N    : out std_logic;
		ADC_CS_4      : out std_logic; -- serial interfacechip select
		ADC_SDO_4     : in  std_logic; -- serial interface data readback output

		-- Stamp9G45 1.8V signals
		EBI1_ADDR    : in std_logic_vector(20 downto 0); -- up to 21 memory bus address signals
		EBI1_D       : inout std_logic_vector(15 downto 0); -- memory bus data signals
		EBI1_NWE     : in std_logic; --EBI1_NWE/NWR0/CFWE, low active write strobe
		EBI1_NCS2    : in std_logic; --PC13/NCS2,             address (hex) 3000 0000, low active Chip Select 2
		EBI1_NRD     : in std_logic; --EBI1_NRD/CFOE, low active read strobe
		EBI1_MCK     : in std_logic; --PB31/ISI_MCK/PCK1, might be used as clock
		EBI1_NWAIT    : out std_logic; --PC15/NWAIT, low active
									   -- Stamp9G45 3.3V signals
		PC1_ARM_IRQ0  : out std_logic; -- PIO port PC1, used as edge (both) triggered interrupt signal
		ADDR_64BIT    : inout std_logic; -- one wire serial EPROM DS2431P

		-- DRS4 (Domino Ring Sampler) chips #1..3, 2.5V CMOS outputs
		DRS4_SROUT   : in  std_logic_vector(1 to 3); -- Multiplexed Shift Register Output
													 -- Output if DWRITE=1, Read Shift Register Output if DWRITE=0
		DRS4_DTAP    : in  std_logic_vector(1 to 3); -- Domino Tap Signal Output toggling on each domino revolution
		DRS4_PLLLCK  : in  std_logic_vector(1 to 3); -- PLL Lock Indicator Output
													 -- DRS4 (Domino Ring Sampler) chips #1..3, 2.5V CMOS inputs
		DRS4_RESETn  : out std_logic_vector(1 to 3); -- external Reset, leave open when using internal ..
		DRS4_A       : out std_logic_vector(3 downto 0); -- shared address bits
		DRS4_SRIN    : out std_logic_vector(1 to 3);  -- Shared Shift Register Input
		DRS4_SRCLK   : out std_logic_vector(1 to 3);  -- Multiplexed Shift Register Clock Input
		DRS4_RSLOAD  : out std_logic_vector(1 to 3);  -- Read Shift Register Load Input
		DRS4_DWRITE  : out std_logic_vector(1 to 3);  -- Domino Write Input. Connects the Domino Wave Circuit to the
													  -- Sampling Cells to enable sampling if high
		DRS4_DENABLE : out std_logic_vector(1 to 3);  -- Domino Enable Input. A low-to-high transition starts the Domino
													  -- Wave. Setting this input low stops the Domino Wave
													  -- DRS4 clock, LVDS
		DRS4_REFCLK_P : out std_logic_vector(1 to 3);  -- Reference Clock Input LVDS (+)
		DRS4_REFCLK_N : out std_logic_vector(1 to 3);  -- Reference Clock Input LVDS (-)

		-- serial DAC to set the Discriminator thresholds
		DAC_DIN      : out std_logic_vector(3 downto 1);   -- 2.5V CMOS, serial DAC (discr. threshold)
		DAC_SCLK     : out std_logic_vector(3 downto 1);   -- 2.5V CMOS
		DAC_SYNCn    : out std_logic_vector(3 downto 1);    -- 2.5V CMOS, low active
		--DAC_DOUT     : in  std_logic_vector(1 to 3);    -- 2.5V CMOS

		-- paddle #1..3 control
		I2C_CLK      : inout std_logic_vector(3 downto 1);   -- I2C clock
		I2C_DATA     : inout std_logic_vector(3 downto 1); -- SN65HVD1782D, bidirectional data
		CBL_PLGDn    : in  std_logic_vector(1 to 3);    -- cable plugged, low active, needs pullup activated
		PON_PADDLEn  : out std_logic_vector(1 to 3);    -- Paddle power on signal
		POW_SW_SCL   : out std_logic;   -- paddle power switch monitoring ADC control
		POW_SW_SDA   : out std_logic;   -- paddle power switch monitoring ADC control
		POW_ALERT    : in  std_logic;   -- ADC AD7997 open drain output, needs pullup,

		-- RS232 / RS485 ports
		RS232_TXD    : out std_logic;   -- 3.3V CMOS
		RS232_RXD    : in std_logic;    -- 3.3V CMOS

		RS485_PV     : out std_logic;   -- 3.3V CMOS
		RS485_DE     : out std_logic;   -- 3.3V CMOS
		RS485_REn    : out std_logic;   -- 3.3V CMOS
		RS485_TXD    : out std_logic;   -- 3.3V CMOS
		RS485_RXD    : in std_logic;    -- 3.3V CMOS

		-- GPS module LEA-6T ?? check wether this is really 3.3V ..
		GPS_RESET_N    : out std_logic;   -- 3.3V CMOS, GPS-module reset
		GPS_EXTINT0    : out std_logic;   -- 3.3V CMOS, interrupt signal for time stamping an event
		GPS_TIMEPULSE  : in std_logic;    -- 3.3V CMOS, typical used as PPS pulse
		GPS_TIMEPULSE2 : in std_logic;    -- 3.3V CMOS, configurable, clock from 0.25 Hz to 10 MHz
		GPS_RXD1       : out std_logic;   -- 3.3V CMOS,
		GPS_TXD1       : in std_logic;    -- 3.3V CMOS,

		-- test signals DACs
		TEST_DAC_SCL   : inout std_logic;  -- 2.5V CMOS, DAC for test pulse (chain saw) generation
		TEST_DAC_SDA   : inout std_logic;  -- 2.5V CMOS,
		TEST_GATE      : out std_logic_vector(1 to 3);    -- 2.5V CMOS, to discharge the capacitor used for the chain saw signal
		TEST_PDn       : out std_logic;    -- 2.5V CMOS, to power down the test circuitry

		TEMPERATURE    : inout std_logic;    -- bidir, tmp05 sensor

		sda				: inout std_logic; 
		scl				: inout std_logic; 
		-- test signals, NOT AVAILABLE for XC6SLX100FGG484-2 !!!
		LVDS_IO_P    : inout std_logic_vector(5 downto 0); -- LVDS bidir. test port
		LVDS_IO_N    : inout std_logic_vector(5 downto 0)  -- LVDS bidir. test port
		--LVDS_IN_P    : in std_logic_vector(5 downto 5) -- LVDS bidir. test port
	);
end taxiTop_iceScint;

architecture behaviour of taxiTop_iceScint is

	attribute keep : string;

	--signal asyncAddressAndControlBus : std_logic_vector(27 downto 0);
	signal addressAndControlBus : std_logic_vector(31 downto 0);
	signal clockValid : std_logic;
	signal asyncReset : std_logic;

	signal ebiNotWrite : std_logic;
	signal ebiNotRead : std_logic;
	signal ebiNotChipSelect : std_logic;
	signal ebiAddress : std_logic_vector(23 downto 0);
	signal ebiDataIn : std_logic_vector(15 downto 0);
	signal ebiDataOut : std_logic_vector(15 downto 0);

	constant numberOfDsr : integer := 3;
	type drsChannel_t is array(0 to numberOfDsr-1) of std_logic_vector(7 downto 0);
	signal discriminator : drsChannel_t;

	--type adcData_t is array(0 to 6) of std_logic_vector(11 downto 0); --adc4channel_r;
	--signal adcData : adcData_t;

	signal discriminatorSerdes : std_logic_vector(8*8-1 downto 0);
	signal discriminatorSerdesDelayed : std_logic_vector(discriminatorSerdes'length-1 downto 0);
	signal discriminatorSerdesDelayed2 : std_logic_vector(discriminatorSerdes'length-1 downto 0);
	attribute keep of discriminatorSerdes : signal is "true";
	signal drs4RefClock : std_logic;

	signal lvdsDebugOut : std_logic_vector(5 downto 0);

	signal edgeData : std_logic_vector(8*16-1 downto 0);
	signal edgeDataReady : std_logic;

	signal triggerTimeToRisingEdge_0r : triggerTimeToRisingEdge_registerRead_t;
	signal triggerTimeToRisingEdge_0w : triggerTimeToRisingEdge_registerWrite_t;
	signal eventFifoSystem_0r : eventFifoSystem_registerRead_t;
	signal eventFifoSystem_0w : eventFifoSystem_registerWrite_t;
	signal triggerDataDelay_0r : triggerDataDelay_registerRead_t;
	signal triggerDataDelay_0w : triggerDataDelay_registerWrite_t;
	signal triggerDataDelay_1r : triggerDataDelay_registerRead_t;
	signal triggerDataDelay_1w : triggerDataDelay_registerWrite_t;
	signal pixelRateCounter_0r : pixelRateCounter_registerRead_t;
	signal pixelRateCounter_0w : pixelRateCounter_registerWrite_t;
	signal dac088s085_x3_0r: dac088s085_x3_registerRead_t;
	signal dac088s085_x3_0w: dac088s085_x3_registerWrite_t;
	signal gpsTiming_0r : gpsTiming_registerRead_t;
	signal gpsTiming_0w : gpsTiming_registerWrite_t;
	signal internalTiming_0r : internalTiming_registerRead_t;
	signal internalTiming_0w : internalTiming_registerWrite_t;
	signal whiteRabbitTiming_0r : whiteRabbitTiming_registerRead_t;
	signal whiteRabbitTiming_0w : whiteRabbitTiming_registerWrite_t;
	signal ad56x1_0r : ad56x1_registerRead_t;
	signal ad56x1_0w : ad56x1_registerWrite_t;
	signal drs4_0r : drs4_registerRead_t;
	signal drs4_0w : drs4_registerWrite_t;
	signal drs4_1r : drs4_registerRead_t;
	signal drs4_1w : drs4_registerWrite_t;
	signal drs4_2r : drs4_registerRead_t;
	signal drs4_2w : drs4_registerWrite_t;
	signal ltm9007_14r : ltm9007_14_registerRead_t;
	signal ltm9007_14_0r : ltm9007_14_registerRead_t;
	signal ltm9007_14_0w : ltm9007_14_registerWrite_t;
	signal ltm9007_14_1r : ltm9007_14_registerRead_t;
	signal ltm9007_14_1w : ltm9007_14_registerWrite_t;
	signal ltm9007_14_2r : ltm9007_14_registerRead_t;
	signal ltm9007_14_2w : ltm9007_14_registerWrite_t;
	signal triggerLogic_0r : triggerLogic_registerRead_t;
	signal triggerLogic_0w : triggerLogic_registerWrite_t;
	signal iceTad_0r : iceTad_registerRead_t;
	signal iceTad_0w : iceTad_registerWrite_t;
	signal panelPower_0r : panelPower_registerRead_t;
	signal panelPower_0w : panelPower_registerWrite_t;
	signal tmp05_0r : tmp05_registerRead_t;
	signal tmp05_0w : tmp05_registerWrite_t;
	signal i2c_control_r : i2c_registerRead_t;
	signal i2c_control_w : i2c_registerWrite_t;
	signal triggerSerdesClocks : triggerSerdesClocks_t;
	signal triggerTiming : triggerTiming_t;
	signal adcData : ltm9007_14_to_eventFifoSystem_old_t;
	signal adcData2 : ltm9007_14_to_eventFifoSystem_old_t;
	signal adcData3 : ltm9007_14_to_eventFifoSystem_old_t;
	signal gpsTiming : gpsTiming_t;
	signal internalTiming : internalTiming_t;
	signal whiteRabbitTiming : whiteRabbitTiming_t;
	--signal drs4Clocks : drs4Clocks_t;
	signal adcFifo : adcFifo_t;
	signal adcClocks : adcClocks_t;
	signal trigger : triggerLogic_t;
	signal triggerDRS4 : std_logic;
	signal pixelRates : pixelRateCounter_t;
	signal clockConfig_debug : clockConfig_debug_t;

	signal dacMosi : std_logic_vector(2 downto 0);
	signal dacSclk : std_logic_vector(2 downto 0);
	signal dacNSync : std_logic_vector(2 downto 0);

	signal gpsPps : std_logic;
	signal gpsTimePulse2 : std_logic;
	signal gpsRx : std_logic;
	signal gpsTx : std_logic;
	signal gpsNotReset : std_logic;
	signal gpsIrq : std_logic;

	signal vcxoQ1DacNotSync : std_logic;
	signal vcxoQ3DacNotSync : std_logic;
	signal vcxoQ13DacSclk : std_logic;
	signal vcxoQ13DacMosi : std_logic;
	signal vcxoQ2Enable : std_logic;

	signal drs4NotReset : std_logic; -- := '1';
	signal drs4Address : std_logic_vector(3 downto 0); -- := "1111";
	signal drs4Srin : std_logic_vector(2 downto 0);
	signal drs4Srclk : std_logic_vector(2 downto 0);
	signal drs4Rsrload : std_logic_vector(2 downto 0);
	signal drs4Dwrite : std_logic_vector(2 downto 0);
	signal drs4DwriteSerdes : drsChannel_t;
	signal drs4Denable : std_logic_vector(2 downto 0);
	signal drs4Srout : std_logic_vector(2 downto 0);
	signal drs4Dtap : std_logic_vector(2 downto 0);
	signal drs4Plllck : std_logic_vector(2 downto 0);

	signal adcSdi : std_logic;
	signal adcSck : std_logic;
	signal drs4_to_ltm9007_14 : drs4_to_ltm9007_14_old_t;
	--signal drs4_to_ltm9007_14_vector : drs4_to_ltm9007_14_vector_t;

	signal rs485DataIn : std_logic_vector(7 downto 0);
	signal rs485DataOut : std_logic_vector(7 downto 0);
	signal rs485DataTristate : std_logic_vector(7 downto 0);
	signal rs485DataEnable : std_logic_vector(7 downto 0);
	signal nP24VOn : std_logic_vector(7 downto 0);
	signal nP24VOnTristate : std_logic_vector(7 downto 0); -- := (others=>'1');

	signal nPanelPowerOn : std_logic; --_vector(2 downto 0);
	signal irq2arm : std_logic;
	signal whiteRabbitPpsIregbIn : std_logic;
	signal whiteRabbitPpsIregbInX : std_logic;
	signal whiteRabbitPpsIregbInZ : std_logic;
	signal whiteRabbitClockIn : std_logic;

	signal deadTime : std_logic;
	signal rateCounterTimeOut : std_logic;

	signal drs4AndAdcData : drs4AndAdcData_vector_t;
	--signal drs4AndAdcData : drs4AndAdcData_t;
	--signal drs4_to_eventFifoSystem : drs4_to_eventFifoSystem_vector_t;
	signal drs4_to_eventFifoSystem : drs4_to_eventFifoSystem_t;


	signal notReset : std_logic;
	signal denable : std_logic;
	signal dwrite : std_logic;
	signal rsrload : std_logic;
	signal mosi : std_logic;
	signal miso,miso2,miso3 : std_logic;
	signal srclk : std_logic;
	signal dtap,dtap2,dtap3 : std_logic;
	signal plllck,plllck2,plllck3 : std_logic;
	signal address : std_logic_vector(3 downto 0);
	signal notChipSelectA : std_logic;
	signal notChipSelectB : std_logic;
	signal enc : std_logic;
	signal sdaout,sdaint,sclint : std_logic;
	signal fifo : std_logic_vector(5 downto 0);




	COMPONENT I2CModule
	PORT(
		clk : IN std_logic;
		sdaint : IN std_logic;
		registerWrite : IN i2c_registerwrite_t;          
		scl : OUT std_logic;
		sdaout : OUT std_logic;
		registerRead : OUT i2c_registerread_t
		);
	END COMPONENT;

begin

	g0a: for i in 0 to 3 generate
		i1: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_OUTA_4P(i), IB => ADC_OUTA_4N(i), O => open);
	end generate;

	g0: for i in 0 to 7 generate
		--i1: IBUFDS generic map(DIFF_TERM => true) port map (I => DISCR_OUT_1P(i), IB => DISCR_OUT_1N(i), O => discriminator(0)(i));
		--i4: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_OUTA_1P(i), IB => ADC_OUTA_1N(i), O => open); --adcData(0)(i));
		i1: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_OUTA_2P(i), IB => ADC_OUTA_2N(i), O => open);
		i2: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_OUTA_3P(i), IB => ADC_OUTA_3N(i), O => open);

		--i2: IBUFDS generic map(DIFF_TERM => true) port map (I => DISCR_OUT_2P(i), IB => DISCR_OUT_2N(i), O => discriminator(1)(i));
		--i3: IBUFDS generic map(DIFF_TERM => true) port map (I => DISCR_OUT_3P(i), IB => DISCR_OUT_3N(i), O => discriminator(2)(i));

--		j0: OBUF port map (O => NOT_USED_GND(i), I => '0');
		j1: OBUFT port map (O => PANEL_NP24V_ON(i), I => nP24VOn(i), T => nP24VOnTristate(i));
--		j2: IOBUF port map (IO => PANEL_RS485_D(i), I => rs485DataOut(i), O => rs485DataIn(i), T => rs485DataTristate(i));
		j2a: IBUF port map(I => PANEL_RS485_RX(i), O => rs485DataIn(i));
		j2b: OBUF port map(O => PANEL_RS485_TX(i), I => rs485DataOut(i));
		j3: OBUF port map (O => PANEL_RS485_DE(i), I => rs485DataEnable(i));
	end generate;

	g2: for i in 0 to 2 generate
		i1: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_FRA_P(i+1), IB => ADC_FRA_N(i+1), O => open);
		i2: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_FRB_P(i+1), IB => ADC_FRB_N(i+1), O => open);
		i3: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_DCOA_P(i+1), IB => ADC_DCOA_N(i+1), O => open);
		i4: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_DCOB_P(i+1), IB => ADC_DCOB_N(i+1), O => open);
	end generate;

	i25: OBUF port map(O => ADC_SDI, I => adcSdi);
	i26: OBUF port map(O => ADC_SCK, I => adcSck);
	i27: OBUF port map(O => ADC_PAR_SERn, I => '0'); -- ## if gnd: enable serial mode


	i1: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_FR_4P, IB => ADC_FR_4N, O => open);
	i2: IBUFDS generic map(DIFF_TERM => true) port map (I => ADC_DCO_4P, IB => ADC_DCO_4N, O => open);

	i3: IBUFDS generic map(DIFF_TERM => true) port map (I => EXT_CLK_P, IB => EXT_CLK_N, O => whiteRabbitClockIn);
	i4: IBUFDS generic map(DIFF_TERM => true) port map (I => EXT_PPS_P, IB => EXT_PPS_N, O => whiteRabbitPpsIregbIn);
	i5: IBUFDS generic map(DIFF_TERM => true) port map (I => EXT_TRIG_IN_P, IB => EXT_TRIG_IN_N, O => open);

	i6: OBUFDS port map(O => EXT_TRIG_OUT_P, OB => EXT_TRIG_OUT_N, I => '0');
	i7: OBUFDS port map(O => AERA_TRIG_P, OB => AERA_TRIG_N, I => '0');
	i8: OBUFDS port map(O => ADC_ENC_4P, OB => ADC_ENC_4N, I => '0');
	i9a: OBUF port map(O => ADC_CS_4, I => '0');
	i9b: IBUF port map(I => ADC_SDO_4, O => open);

	--i10: OBUFDS port map(O => LVDS_IO_P(0), OB => LVDS_IO_N(0), I => lvdsDebugOut(0));
	--i11: OBUFDS port map(O => LVDS_IO_P(1), OB => LVDS_IO_N(1), I => lvdsDebugOut(1));
	--i12: OBUFDS port map(O => LVDS_IO_P(2), OB => LVDS_IO_N(2), I => lvdsDebugOut(2));
	--i13: OBUFDS port map(O => LVDS_IO_P(3), OB => LVDS_IO_N(3), I => lvdsDebugOut(3));
	--i14: OBUFDS port map(O => LVDS_IO_P(4), OB => LVDS_IO_N(4), I => lvdsDebugOut(4));
	--i15: OBUFDS port map(O => LVDS_IO_P(5), OB => LVDS_IO_N(5), I => lvdsDebugOut(5));

	i10a: IBUF port map(I => LVDS_IO_P(0), O => whiteRabbitPpsIregbInZ);
	i11a: OBUFT port map(O => LVDS_IO_N(0), I => '0', T => '1');
	
	i10b: OBUFT port map(O => LVDS_IO_P(1), I => '0', T => '1');
	i11b: OBUFT port map(O => LVDS_IO_N(1), I => '0', T => '1');

	i10c: OBUFT port map(O => LVDS_IO_P(2), I => '0', T => '1');
	i11c: OBUFT port map(O => LVDS_IO_N(2), I => '0', T => '1'); -- taxiIo in_2
	
	i10d: OBUFT port map(O => LVDS_IO_P(3), I => '0', T => '1');
	i11d: OBUFT port map(O => LVDS_IO_N(3), I => '0', T => '1'); -- taxiIo in_1
	
	i10e: OBUFT port map(O => LVDS_IO_P(4), I => '0', T => '1');
	i11e: OBUFT port map(O => LVDS_IO_N(4), I => '0', T => '1'); -- taxiIo out_2
	
	--i10f: OBUFT port map(O => LVDS_IO_P(5), I => '0', T => '1');
	i10f: IBUF port map(I => LVDS_IO_P(5), O => whiteRabbitPpsIregbInX); -- old patch (used at KIT and PSL?) 
	i11f: OBUFT port map(O => LVDS_IO_N(5), I => '0', T => '1'); -- taxiIo out_1
	
	i15: IBUF port map(I => EBI1_MCK, O => open);
	i16: IBUF port map(I => EBI1_NWE, O => ebiNotWrite);
	i17: IBUF port map(I => EBI1_NCS2, O => ebiNotChipSelect);
	i18: IBUF port map(I => EBI1_NRD, O => ebiNotRead);
	g4: for i in 0 to 20 generate
		k: IBUF port map(I => EBI1_ADDR(i), O => ebiAddress(i));
	end generate;
	ebiAddress(23 downto 21) <= "000";

	g5: for i in 0 to 15 generate
		k: IOBUF generic map(DRIVE => 2, IBUF_DELAY_VALUE => "0", IFD_DELAY_VALUE => "AUTO", IOSTANDARD => "DEFAULT", SLEW => "SLOW")
			port map(O => ebiDataIn(i), IO => EBI1_D(i), I => ebiDataOut(i), T => ebiNotRead);
	end generate;

	i20: OBUF port map(O => QOSC1_DAC_SYNCn, I => vcxoQ3DacNotSync);
	i21: OBUF port map(O => QOSC2_ENA, I => vcxoQ2Enable);
	i22: OBUF port map(O => QOSC2_DAC_SYNCn, I => vcxoQ1DacNotSync);
	i23: OBUF port map(O => QOSC2_DAC_SCKL, I => vcxoQ13DacSclk);
	i24: OBUF port map(O => QOSC2_DAC_SDIN, I => vcxoQ13DacMosi);

	i28: OBUF port map(O => EBI1_NWAIT, I => '1');
	i29: OBUF port map(O => PC1_ARM_IRQ0, I => irq2arm);

--	g7: for i in 1 to 3 generate k: OBUF port map(O => DRS4_RESETn(i), I => drs4NotReset); end generate;
--	g8: for i in 0 to 3 generate k: OBUF port map(O => DRS4_A(i), I => drs4Address(i)); end generate;
	g9: for i in 1 to 3 generate k: OBUFDS port map(O => DRS4_REFCLK_P(i), OB => DRS4_REFCLK_N(i), I => drs4RefClock); end generate;
--	g10: for i in 1 to 3 generate
--		k1: OBUF port map(O => DRS4_SRIN(i), I => drs4Srin(i-1));
--		k2: OBUF port map(O => DRS4_SRCLK(i), I => drs4Srclk(i-1));
--		k3: OBUF port map(O => DRS4_RSLOAD(i), I => drs4Rsrload(i-1));
--		k4: OBUF port map(O => DRS4_DWRITE(i), I => drs4Dwrite(i-1));
--		k5: OBUF port map(O => DRS4_DENABLE(i), I => drs4Denable(i-1));
--		k6: IBUF port map(I => DRS4_SROUT(i), O => drs4Srout(i-1));
--		k7: IBUF port map(I => DRS4_DTAP(i), O => drs4Dtap(i-1));
--		k8: IBUF port map(I => DRS4_PLLLCK(i), O => drs4Plllck(i-1));
--	end generate;
	--g10_a: OBUF port map(O => DRS4_DWRITE(2), I => drs4Dwrite(1));
	--g10_b: OBUF port map(O => DRS4_DWRITE(3), I => drs4Dwrite(2));

-------------------
--	g10: for i in 2 to 3 generate
--		k0: OBUF port map(O => DRS4_RESETn(i), I => '0');
--		k1: OBUF port map(O => DRS4_SRIN(i), I => '0');
--		k2: OBUF port map(O => DRS4_SRCLK(i), I => '0');
--		k3: OBUF port map(O => DRS4_RSLOAD(i), I => '0');
--		k4: OBUF port map(O => DRS4_DWRITE(i), I => '0');
--		k5: OBUF port map(O => DRS4_DENABLE(i), I => '0');
--		k6: IBUF port map(I => DRS4_SROUT(i), O => open);
--		k7: IBUF port map(I => DRS4_DTAP(i), O => open);
--		k8: IBUF port map(I => DRS4_PLLLCK(i), O => open);
--	end generate;
	--g10_a: OBUF port map(O => DRS4_DWRITE(2), I => drs4Dwrite(1));
	--g10_b: OBUF port map(O => DRS4_DWRITE(3), I => drs4Dwrite(2));
-------------------


	g11: for i in 1 to 3 generate
		k1: OBUF port map(O => DAC_DIN(i), I => dacMosi(i-1));
		k2: OBUF port map(O => DAC_SCLK(i), I => dacSclk(i-1));
		k3: OBUF port map(O => DAC_SYNCn(i), I => dacNSync(i-1));
	end generate;

	g12: for i in 1 to 3 generate
		k1: IOBUF port map(O => open, IO => I2C_CLK(i), I => '0', T => '1');
		k2: IOBUF port map(O => open, IO => I2C_DATA(i), I => '0', T => '1');
	end generate;

	g13: for i in 1 to 3 generate k: OBUF port map(O => PON_PADDLEn(i), I => nPanelPowerOn); end generate;
	i30: OBUF port map(O => POW_SW_SCL, I => '0');
	i31: OBUF port map(O => POW_SW_SDA, I => '0');

	i32a: IBUF port map(I => RS232_RXD, O => open);
	i32b: OBUF port map(O => RS232_TXD, I => '0');
	i33: OBUF port map(O => RS485_PV, I => '0');
	i34: OBUF port map(O => RS485_DE, I => '0');
	i35: OBUF port map(O => RS485_REn, I => '0');
	i36a: IBUF port map(I => RS485_RXD, O => open);
	i36b: OBUF port map(O => RS485_TXD, I => '0');

	i37: OBUF port map(O => GPS_RESET_N, I => gpsNotReset);
	i38: OBUF port map(O => GPS_EXTINT0, I => gpsIrq);
	i39: OBUF port map(O => GPS_RXD1, I => gpsTx);
	i40: IBUF port map(I => GPS_TIMEPULSE, O => gpsPps);
	i41: IBUF port map(I => GPS_TIMEPULSE2, O => gpsTimePulse2);
	i42: IBUF port map(I => GPS_TXD1, O => gpsRx);

	g14: for i in 1 to 3 generate k: OBUF port map(O => TEST_GATE(i), I => '0'); end generate;
	i43: OBUF port map(O => TEST_PDn, I => '0');
	--i44: IBUF port map(I => TEMPERATURE, O => tmp05In);

	i45: IOBUF port map(O => open, IO => ADDR_64BIT, I => '0', T => '1');

--	i46: IOBUF port map(O => open, IO => TEST_DAC_SCL, I => '0', T => '1');
--	i47: IOBUF port map(O => open, IO => TEST_DAC_SDA, I => '0', T => '1');

	i48: IBUF port map(I => QOSC1_OUT, O => open);
	i49: IBUF port map(I => POW_ALERT, O => open);
	i50a: IBUF port map(I => CBL_PLGDn(1), O => open);
	i50b: IBUF port map(I => CBL_PLGDn(2), O => open);
	i50c: IBUF port map(I => CBL_PLGDn(3), O => open);

	asyncReset <= not(PON_RESETn and clockValid);

	-- whiteRabbitPpsIregbIn <= whiteRabbitPpsIregbInX or whiteRabbitPpsIregbInZ;

	vcxoQ2Enable <= '0'; -- Q2 not mounted

	x0: entity work.clockConfig port map(QOSC2_OUT, "not"(PON_RESETn), triggerSerdesClocks, adcClocks, open, clockValid, clockConfig_debug, drs4RefClock );
	
	x1: entity work.smcBusWrapper port map("not"(ebiNotChipSelect), ebiAddress, "not"(ebiNotRead), "not"(ebiNotWrite), triggerSerdesClocks.serdesDivClockReset, triggerSerdesClocks.serdesDivClock, addressAndControlBus);
	--x2: entity work.smcBusEntry port map(triggerSerdesClocks.serdesDivClock, asyncAddressAndControlBus, addressAndControlBus);

--	x6: entity work.serdesIn_1to8 port map('0', DISCR_OUT_1P, DISCR_OUT_1N, triggerSerdesClocks, '0', "00", discriminatorSerdes, open);
	x6: entity work.serdesIn_1to8 port map('0', DISCR_OUT, triggerSerdesClocks, '0', "00", discriminatorSerdes, open);

--	x7a: entity work.serdesOut_8to1 port map(triggerSerdesClocks.serdesIoClock, triggerSerdesClocks.serdesStrobe, reset, triggerSerdesClocks.serdesDivClock, discriminatorSerdes(7 downto 0), LVDS_IO_P(5 downto 5), LVDS_IO_N(5 downto 5));
--	x7b: entity work.serdesOut_8to1 port map(triggerSerdesClocks.serdesIoClock, triggerSerdesClocks.serdesStrobe, reset, triggerSerdesClocks.serdesDivClock, discriminatorSerdes(15 downto 8), LVDS_IO_P(0 downto 0), LVDS_IO_N(0 downto 0));

	x8: entity work.triggerLogic generic map(8) port map(discriminatorSerdes, deadTime, internalTiming, trigger, triggerLogic_0r, triggerLogic_0w);

	x9a: entity work.triggerDataDelay port map(discriminatorSerdes, discriminatorSerdesDelayed, triggerDataDelay_0r, triggerDataDelay_0w);
	x9b: entity work.triggerDataDelay port map(discriminatorSerdes, discriminatorSerdesDelayed2, triggerDataDelay_1r, triggerDataDelay_1w);

	x10: entity work.triggerTimeToRisingEdge generic map(8) port map(discriminatorSerdesDelayed, trigger.triggerNotDelayed, edgeData, edgeDataReady, triggerTimeToRisingEdge_0r, triggerTimeToRisingEdge_0w, triggerTiming);

	x12: entity work.pixelRateCounter port map(discriminatorSerdesDelayed2, deadTime, trigger.sumTriggerSameEvent, rateCounterTimeOut, pixelRates, internalTiming, pixelRateCounter_0r, pixelRateCounter_0w);

	x11: entity work.eventFifoSystem port map(trigger, rateCounterTimeOut, irq2arm, triggerTiming, drs4AndAdcData, internalTiming,gpsTiming,whiteRabbitTiming,pixelRates,eventFifoSystem_0r,eventFifoSystem_0w);

	--drs4Denable(1) <= drs4Denable(0);
	--drs4Dwrite(1) <= drs4Dwrite(0);
	--drs4Rsrload(1) <= drs4Rsrload(0);
	--drs4Srin(1) <= drs4Srin(0);
	--drs4Srclk(1) <= drs4Srclk(0);
	--drs4Denable(2) <= drs4Denable(0);
	--drs4Dwrite(2) <= drs4Dwrite(0);
	--drs4Rsrload(2) <= drs4Rsrload(0);
	--drs4Srin(2) <= drs4Srin(0);
	--drs4Srclk(2) <= drs4Srclk(0);

	lvdsDebugOut(1) <= trigger.triggerDelayed;
	lvdsDebugOut(2) <= trigger.triggerNotDelayed;

	x14a: entity work.internalTiming generic map(globalClockRate_kHz) port map(internalTiming, internalTiming_0r, internalTiming_0w);
	x14b: entity work.gpsTiming port map(gpsPps, gpsTimePulse2, gpsRx, gpsTx, gpsIrq, gpsNotReset, internalTiming, gpsTiming, gpsTiming_0r, gpsTiming_0w);
	x14c: entity work.whiteRabbitTiming port map(whiteRabbitPpsIregbIn, whiteRabbitClockIn, internalTiming, whiteRabbitTiming, whiteRabbitTiming_0r, whiteRabbitTiming_0w);
	
	triggerDRS4 <= trigger.triggerDelayed or trigger.softTrigger;

--	x16: entity work.drs4_x3 generic map(
--		drs4_type=>"one_channel")
--	port map(drs4Address, 
--		DRS4_RESETn(1), DRS4_DENABLE(1), DRS4_DWRITE(1), DRS4_RSLOAD(1), DRS4_SROUT(1), DRS4_SRIN(1), DRS4_SRCLK(1), DRS4_DTAP(1), DRS4_PLLLCK(1),
--		DRS4_RESETn(2), DRS4_DENABLE(2), DRS4_DWRITE(2), DRS4_RSLOAD(2), DRS4_SROUT(2), DRS4_SRIN(2), DRS4_SRCLK(2), DRS4_DTAP(2), DRS4_PLLLCK(2),
--		DRS4_RESETn(3), DRS4_DENABLE(3), DRS4_DWRITE(3), DRS4_RSLOAD(3), DRS4_SROUT(3), DRS4_SRIN(3), DRS4_SRCLK(3), DRS4_DTAP(3), DRS4_PLLLCK(3),
--		--deadTime, triggerDRS4, internalTiming, adcClocks, drs4_to_ltm9007_14, drs4_0r, drs4_0w);
--		deadTime, triggerDRS4, internalTiming, adcClocks, drs4_to_ltm9007_14_vector, drs4AndAdcData(0).drs4Data, drs4_0r, drs4_0w);
--	
--	--x17: entity work.ltm9007_14 port map(
--	--	ADC_ENC_P(1), ADC_ENC_N(1), ADC_OUTA_1P, ADC_OUTA_1N, adcNcsA(0), adcNcsB(0), 
--	--	adcSdi, adcSck, drs4_to_ltm9007_14, drs4AndAdcData.adcData, adcClocks, ltm9007_14_0r, ltm9007_14_0w);
--
--
--	x17: entity work.ltm9007_14_icescint generic map(
--		system_type=>"ICE_SCINT")
--	port map(
--		ADC_ENC_P(1), ADC_ENC_N(1), ADC_OUTA_1P, ADC_OUTA_1N, ADC_CSA(1), ADC_CSB(1), 
--		ADC_ENC_P(2), ADC_ENC_N(2), ADC_OUTA_2P, ADC_OUTA_2N, ADC_CSA(2), ADC_CSB(2), 
--		ADC_ENC_P(3), ADC_ENC_N(3), ADC_OUTA_3P, ADC_OUTA_3N, ADC_CSA(3), ADC_CSB(3), 
--		adcSdi, adcSck, drs4_to_ltm9007_14_vector, drs4AndAdcData(0).adcData, adcClocks, ltm9007_14_0r, ltm9007_14_0w);


	
	z10: OBUF port map(O => DRS4_RESETn(1), I => notReset);
	z11: OBUF port map(O => DRS4_DENABLE(1), I => denable);
	z12: OBUF port map(O => DRS4_DWRITE(1), I => dwrite);
	z13: OBUF port map(O => DRS4_RSLOAD(1), I => rsrload);
	z14: OBUF port map(O => DRS4_SRIN(1), I => mosi);
	z15: IBUF port map(I => DRS4_SROUT(1), O => miso);
	z16: OBUF port map(O => DRS4_SRCLK(1), I => srclk);
	z17: IBUF port map(I => DRS4_DTAP(1), O => dtap);
	z18: IBUF port map(I => DRS4_PLLLCK(1), O => plllck);
	z19: for i in 0 to 3 generate k: OBUF port map(O => DRS4_A(i), I => address(i)); end generate;
	
	z20: OBUF port map(O => DRS4_RESETn(2), I => notReset);
	z21: OBUF port map(O => DRS4_DENABLE(2), I => denable);
	z22: OBUF port map(O => DRS4_DWRITE(2), I => dwrite);
	z23: OBUF port map(O => DRS4_RSLOAD(2), I => rsrload);
	z24: OBUF port map(O => DRS4_SRIN(2), I => mosi);
	z25: IBUF port map(I => DRS4_SROUT(2), O => miso2);
	z26: OBUF port map(O => DRS4_SRCLK(2), I => srclk);
	z27: IBUF port map(I => DRS4_DTAP(2), O => dtap2);
	z28: IBUF port map(I => DRS4_PLLLCK(2), O => plllck2);
	
	z30: OBUF port map(O => DRS4_RESETn(3), I => notReset);
	z31: OBUF port map(O => DRS4_DENABLE(3), I => denable);
	z32: OBUF port map(O => DRS4_DWRITE(3), I => dwrite);
	z33: OBUF port map(O => DRS4_RSLOAD(3), I => rsrload);
	z34: OBUF port map(O => DRS4_SRIN(3), I => mosi);
	z35: IBUF port map(I => DRS4_SROUT(3), O => miso3);
	z36: OBUF port map(O => DRS4_SRCLK(3), I => srclk);
	z37: IBUF port map(I => DRS4_DTAP(3), O => dtap3);
	z38: IBUF port map(I => DRS4_PLLLCK(3), O => plllck3);
		
	l00: OBUF port map(O => ADC_CSA(1), I => notChipSelectA);
	l01: OBUF port map(O => ADC_CSB(1), I => notChipSelectB);
	l10: OBUF port map(O => ADC_CSA(2), I => notChipSelectA);
	l11: OBUF port map(O => ADC_CSB(2), I => notChipSelectB);
	l20: OBUF port map(O => ADC_CSA(3), I => notChipSelectA);
	l21: OBUF port map(O => ADC_CSB(3), I => notChipSelectB);
	
	w00: OBUFDS port map(O => ADC_ENC_P(1), OB => ADC_ENC_N(1), I => enc);
	w10: OBUFDS port map(O => ADC_ENC_P(2), OB => ADC_ENC_N(2), I => enc);
	w20: OBUFDS port map(O => ADC_ENC_P(3), OB => ADC_ENC_N(3), I => enc);

	x16: entity work.drs4adc port map(
		address, notReset, denable, dwrite, rsrload, miso, mosi, srclk, dtap, plllck,
		deadTime, triggerDRS4, internalTiming, adcClocks, drs4_0r, drs4_0w,
		notChipSelectA, notChipSelectB, adcSdi, adcSck, enc, ADC_OUTA_1P, ADC_OUTA_1N,
		drs4AndAdcData(0),	
		"00",
		fifo(1 downto 0),
		fifo(3 downto 2),
		fifo(5 downto 4),
		ltm9007_14_0r, ltm9007_14_0w
		);
	
	x16b: entity work.drs4adc port map(
		open, open, open, open, open, miso2, open, open, dtap2, plllck2,
		open, triggerDRS4, internalTiming, adcClocks, drs4_1r, drs4_0w,
		open, open, open, open, open, ADC_OUTA_2P, ADC_OUTA_2N,
		drs4AndAdcData(1),	
		"01",
		fifo(3 downto 2),
		fifo(1 downto 0),
		fifo(5 downto 4),
		ltm9007_14_1r, ltm9007_14_0w
		);
	
	x16c: entity work.drs4adc port map(
		open, open, open, open, open, miso3, open, open, dtap3, plllck3,
		open, triggerDRS4, internalTiming, adcClocks, drs4_2r, drs4_0w,
		open, open, open, open, open, ADC_OUTA_3P, ADC_OUTA_3N,
		drs4AndAdcData(2),	
		"10",
		fifo(5 downto 4),
		fifo(3 downto 2),
		fifo(1 downto 0),
		ltm9007_14_2r, ltm9007_14_0w
		);



--	x16a: entity work.drs4_pole port map(notReset, address, denable, dwrite, rsrload, miso, mosi, srclk, dtap, plllck, deadTime, triggerDRS4, internalTiming, adcClocks, drs4_to_ltm9007_14, drs4_0r, drs4_0w);
--	x16b: entity work.ltm9007_14_pole port map(ADC_ENC_P(1), ADC_ENC_N(1), ADC_OUTA_1P, ADC_OUTA_1N, notChipSelectA, notChipSelectB, adcSdi, adcSck, drs4_to_ltm9007_14, adcData, adcClocks, ltm9007_14_0r, ltm9007_14_0w);
--	
--	x16c: entity work.drs4_pole port map(open, open, open, open, open, miso, open, open, dtap, plllck, open, triggerDRS4, internalTiming, adcClocks, open, open, drs4_0w);
--	x16d: entity work.ltm9007_14_pole port map(ADC_ENC_P(2), ADC_ENC_N(2), ADC_OUTA_2P, ADC_OUTA_2N, open, open, open, open, drs4_to_ltm9007_14, adcData2, adcClocks, open, ltm9007_14_0w);
--	
--	x16e: entity work.drs4_pole port map(open, open, open, open, open, miso, open, open, dtap, plllck, open, triggerDRS4, internalTiming, adcClocks, open, open, drs4_0w);
--	x16f: entity work.ltm9007_14_pole port map(ADC_ENC_P(3), ADC_ENC_N(3), ADC_OUTA_3P, ADC_OUTA_3N, open, open, open, open, drs4_to_ltm9007_14, adcData3, adcClocks, open, ltm9007_14_0w);
--	
--	
--	drs4AndAdcData.adcData.channel <= adcData.channel; -- or adcData2.channel or adcData3.channel;
--	drs4AndAdcData.adcData.newData <= adcData.newData; -- or adcData2.newData or adcData3.newData;
--	drs4AndAdcData.adcData.samplingDone <= adcData.samplingDone; -- or adcData2.samplingDone or adcData3.samplingDone;
--	drs4AndAdcData.adcData.charge <= adcData.charge; -- or adcData2.charge or adcData3.charge;
--	drs4AndAdcData.adcData.maxValue <= adcData.maxValue; -- or adcData2.maxValue or adcData3.maxValue;
--	drs4AndAdcData.adcData.chargeDone <= adcData.chargeDone; -- or adcData2.chargeDone or adcData3.chargeDone;
--	drs4AndAdcData.adcData.baseline <= adcData.baseline; -- or adcData2.baseline or adcData3.baseline;
--	drs4AndAdcData.adcData.baselineDone <= adcData.baselineDone; -- or adcData2.baselineDone or adcData3.baselineDone;
--	drs4AndAdcData.drs4Data.realTimeCounter_latched <= adcData.realTimeCounter_latched; -- or adcData2.realTimeCounter_latched or adcData3.realTimeCounter_latched;
--	drs4AndAdcData.drs4Data.regionOfInterest <= adcData.roiBuffer; -- or adcData2.roiBuffer or adcData3.roiBuffer;
--	drs4AndAdcData.drs4Data.regionOfInterestReady <= adcData.roiBufferReady; -- or adcData2.roiBufferReady or adcData3.roiBufferReady;


	x13: entity work.dac088s085_x3 port map(dacNSync(0), dacMosi(0), dacSclk(0), dac088s085_x3_0r, dac088s085_x3_0w);
	
	x15: entity work.ad56x1 port map(vcxoQ3DacNotSync, vcxoQ1DacNotSync, vcxoQ13DacMosi, vcxoQ13DacSclk, ad56x1_0r, ad56x1_0w);
	
	x18: entity work.iceTad port map(nP24VOn, nP24VOnTristate, rs485DataIn, rs485DataOut, rs485DataTristate, rs485DataEnable, iceTad_0r, iceTad_0w);
	
	x19: entity work.panelPower port map(nPanelPowerOn, panelPower_0r, panelPower_0w);
	
	x20: entity work.tmp05 port map(TEMPERATURE, tmp05_0r, tmp05_0w);


---  Read fast aller daten von Kanal 0 
	ltm9007_14r.testMode <= ltm9007_14_0r.testMode;
	ltm9007_14r.testPattern <= ltm9007_14_0r.testPattern;
	ltm9007_14r.bitslipPattern <= ltm9007_14_0r.bitslipPattern;
	ltm9007_14r.bitslipFailed <= ltm9007_14_0r.bitslipFailed or ltm9007_14_1r.bitslipFailed or ltm9007_14_2r.bitslipFailed;-- alle 3 Kan?le verodert...
	ltm9007_14r.offsetCorrectionRamAddress <= ltm9007_14_0r.offsetCorrectionRamAddress;
	ltm9007_14r.offsetCorrectionRamData <= ltm9007_14_0r.offsetCorrectionRamData;
	ltm9007_14r.offsetCorrectionRamWrite <= ltm9007_14_0r.offsetCorrectionRamWrite;
	ltm9007_14r.fifoEmptyA <= ltm9007_14_0r.fifoEmptyA;
	ltm9007_14r.fifoValidA <= ltm9007_14_0r.fifoValidA;
	ltm9007_14r.fifoWordsA <= ltm9007_14_0r.fifoWordsA;
	ltm9007_14r.baselineStart <= ltm9007_14_0r.baselineStart;
	ltm9007_14r.baselineEnd <= ltm9007_14_0r.baselineEnd;
	ltm9007_14r.debugChannelSelector <= ltm9007_14_0r.debugChannelSelector;
	ltm9007_14r.debugFifoControl <= ltm9007_14_0r.debugFifoControl; 
	ltm9007_14r.testMode <= ltm9007_14_0r.testMode;
	ltm9007_14r.debugFifoOut <= ltm9007_14_0r.debugFifoOut;


	x3: entity work.registerInterface_iceScint port map(addressAndControlBus, ebiDataIn, ebiDataOut,
		triggerTimeToRisingEdge_0r,
		triggerTimeToRisingEdge_0w,
		eventFifoSystem_0r,
		eventFifoSystem_0w,
		triggerDataDelay_0r,
		triggerDataDelay_0w,
		triggerDataDelay_1r,
		triggerDataDelay_1w,
		pixelRateCounter_0r,
		pixelRateCounter_0w,
		dac088s085_x3_0r,
		dac088s085_x3_0w,
		gpsTiming_0r,
		gpsTiming_0w,
		whiteRabbitTiming_0r,
		whiteRabbitTiming_0w,
		internalTiming_0r,
		internalTiming_0w,
		ad56x1_0r,
		ad56x1_0w,
		drs4_0r,
		drs4_0w,
--		ltm9007_14_0r,
		ltm9007_14r,
		ltm9007_14_0w,
		triggerLogic_0r,
		triggerLogic_0w,
		iceTad_0r,
		iceTad_0w,
		panelPower_0r,
		panelPower_0w,
		tmp05_0r,
		tmp05_0w,
		i2c_control_r,
		i2c_control_w,
		clockConfig_debug
	);
	
	Inst_I2CModule: I2CModule PORT MAP(
		clk => triggerSerdesClocks.serdesDivClock,
		scl => sclint,
		sdaout => sdaout,
		sdaint => sdaint,
		registerRead => i2c_control_r,
		registerWrite => i2c_control_w
	);

--	sda <= '0' when sdaout = '0' else 'Z';
--	sdaint <= sda; 
--- zweites paralelles i2c Interface:
--clocks:
scl 					<= sclint;
test_dac_scl 		<= sclint;
--sdaout
sda 					<= '0' when sdaout = '0' else 'Z';
test_dac_sda 		<= '0' when sdaout = '0' else 'Z';
-- sda in:
sdaint <= sda and test_dac_sda; 



end behaviour;
