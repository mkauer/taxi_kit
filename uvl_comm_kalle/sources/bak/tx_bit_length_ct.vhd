-- megafunction wizard: %LPM_COUNTER%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_counter 

-- ============================================================
-- File Name: tx_bit_length_ct.vhd
-- Megafunction Name(s):
-- 			lpm_counter
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 5.0 Build 171 11/03/2005 SP 2 SJ Full Version
-- ************************************************************


--Copyright (C) 1991-2005 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic       
--functions, and any output files any of the foregoing           
--(including device programming or simulation files), and any    
--associated documentation or information are expressly subject  
--to the terms and conditions of the Altera Program License      
--Subscription Agreement, Altera MegaCore Function License       
--Agreement, or other applicable license agreement, including,   
--without limitation, that your use is for the sole purpose of   
--programming logic devices manufactured by Altera and sold by   
--Altera or its authorized distributors.  Please refer to the    
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY lpm;
USE lpm.lpm_components.all;

ENTITY tx_bit_length_ct IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		sload		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
		cout		: OUT STD_LOGIC 
	);
END tx_bit_length_ct;


ARCHITECTURE SYN OF tx_bit_length_ct IS

	SIGNAL sub_wire0	: STD_LOGIC ;
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (4 DOWNTO 0);



	COMPONENT lpm_counter
	GENERIC (
		lpm_width		: NATURAL;
		lpm_type		: STRING;
		lpm_direction		: STRING
	);
	PORT (
			sload	: IN STD_LOGIC ;
			sclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			cout	: OUT STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			data	: IN STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	cout    <= sub_wire0;
	q    <= sub_wire1(4 DOWNTO 0);

	lpm_counter_component : lpm_counter
	GENERIC MAP (
		lpm_width => 5,
		lpm_type => "LPM_COUNTER",
		lpm_direction => "DOWN"
	)
	PORT MAP (
		sload => sload,
		sclr => sclr,
		clock => clock,
		data => data,
		cout => sub_wire0,
		q => sub_wire1
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: nBit NUMERIC "5"
-- Retrieval info: PRIVATE: Direction NUMERIC "1"
-- Retrieval info: PRIVATE: CLK_EN NUMERIC "0"
-- Retrieval info: PRIVATE: CNT_EN NUMERIC "0"
-- Retrieval info: PRIVATE: ModulusCounter NUMERIC "0"
-- Retrieval info: PRIVATE: ModulusValue NUMERIC "0"
-- Retrieval info: PRIVATE: CarryIn NUMERIC "0"
-- Retrieval info: PRIVATE: CarryOut NUMERIC "1"
-- Retrieval info: PRIVATE: SCLR NUMERIC "1"
-- Retrieval info: PRIVATE: SLOAD NUMERIC "1"
-- Retrieval info: PRIVATE: SSET NUMERIC "0"
-- Retrieval info: PRIVATE: SSET_ALL1 NUMERIC "1"
-- Retrieval info: PRIVATE: SSETV NUMERIC "0"
-- Retrieval info: PRIVATE: ACLR NUMERIC "0"
-- Retrieval info: PRIVATE: ALOAD NUMERIC "0"
-- Retrieval info: PRIVATE: ASET NUMERIC "0"
-- Retrieval info: PRIVATE: ASET_ALL1 NUMERIC "1"
-- Retrieval info: PRIVATE: ASETV NUMERIC "0"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "5"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_COUNTER"
-- Retrieval info: CONSTANT: LPM_DIRECTION STRING "DOWN"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: q 0 0 5 0 OUTPUT NODEFVAL q[4..0]
-- Retrieval info: USED_PORT: cout 0 0 0 0 OUTPUT NODEFVAL cout
-- Retrieval info: USED_PORT: sclr 0 0 0 0 INPUT NODEFVAL sclr
-- Retrieval info: USED_PORT: sload 0 0 0 0 INPUT NODEFVAL sload
-- Retrieval info: USED_PORT: data 0 0 5 0 INPUT NODEFVAL data[4..0]
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 5 0 @q 0 0 5 0
-- Retrieval info: CONNECT: cout 0 0 0 0 @cout 0 0 0 0
-- Retrieval info: CONNECT: @sclr 0 0 0 0 sclr 0 0 0 0
-- Retrieval info: CONNECT: @sload 0 0 0 0 sload 0 0 0 0
-- Retrieval info: CONNECT: @data 0 0 5 0 data 0 0 5 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct.inc TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct.cmp FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct.bsf TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct_inst.vhd FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct_waveforms.html TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL tx_bit_length_ct_wave*.jpg FALSE
