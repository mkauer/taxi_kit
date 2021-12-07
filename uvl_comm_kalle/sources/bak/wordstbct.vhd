-- megafunction wizard: %LPM_COUNTER%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: lpm_counter 

-- ============================================================
-- File Name: wordstbct.vhd
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

ENTITY wordstbct IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		clk_en		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END wordstbct;


ARCHITECTURE SYN OF wordstbct IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (3 DOWNTO 0);



	COMPONENT lpm_counter
	GENERIC (
		lpm_width		: NATURAL;
		lpm_type		: STRING;
		lpm_direction		: STRING;
		lpm_modulus		: NATURAL
	);
	PORT (
			clk_en	: IN STD_LOGIC ;
			sclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	q    <= sub_wire0(3 DOWNTO 0);

	lpm_counter_component : lpm_counter
	GENERIC MAP (
		lpm_width => 4,
		lpm_type => "LPM_COUNTER",
		lpm_direction => "UP",
		lpm_modulus => 10
	)
	PORT MAP (
		clk_en => clk_en,
		sclr => sclr,
		clock => clock,
		q => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: nBit NUMERIC "4"
-- Retrieval info: PRIVATE: Direction NUMERIC "0"
-- Retrieval info: PRIVATE: CLK_EN NUMERIC "1"
-- Retrieval info: PRIVATE: CNT_EN NUMERIC "0"
-- Retrieval info: PRIVATE: ModulusCounter NUMERIC "1"
-- Retrieval info: PRIVATE: ModulusValue NUMERIC "10"
-- Retrieval info: PRIVATE: CarryIn NUMERIC "0"
-- Retrieval info: PRIVATE: CarryOut NUMERIC "0"
-- Retrieval info: PRIVATE: SCLR NUMERIC "1"
-- Retrieval info: PRIVATE: SLOAD NUMERIC "0"
-- Retrieval info: PRIVATE: SSET NUMERIC "0"
-- Retrieval info: PRIVATE: SSET_ALL1 NUMERIC "1"
-- Retrieval info: PRIVATE: SSETV NUMERIC "0"
-- Retrieval info: PRIVATE: ACLR NUMERIC "0"
-- Retrieval info: PRIVATE: ALOAD NUMERIC "0"
-- Retrieval info: PRIVATE: ASET NUMERIC "0"
-- Retrieval info: PRIVATE: ASET_ALL1 NUMERIC "1"
-- Retrieval info: PRIVATE: ASETV NUMERIC "0"
-- Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "4"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_COUNTER"
-- Retrieval info: CONSTANT: LPM_DIRECTION STRING "UP"
-- Retrieval info: CONSTANT: LPM_MODULUS NUMERIC "10"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: q 0 0 4 0 OUTPUT NODEFVAL q[3..0]
-- Retrieval info: USED_PORT: clk_en 0 0 0 0 INPUT NODEFVAL clk_en
-- Retrieval info: USED_PORT: sclr 0 0 0 0 INPUT NODEFVAL sclr
-- Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 4 0 @q 0 0 4 0
-- Retrieval info: CONNECT: @clk_en 0 0 0 0 clk_en 0 0 0 0
-- Retrieval info: CONNECT: @sclr 0 0 0 0 sclr 0 0 0 0
-- Retrieval info: LIBRARY: lpm lpm.lpm_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct.inc TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct.cmp FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct.bsf TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct_inst.vhd FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct_waveforms.html TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL wordstbct_wave*.jpg FALSE
