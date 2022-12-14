
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

entity AHB_bridge is
 port(
 -- Clock and Reset -----------------
 clkm : in std_logic;
 rstn : in std_logic;
 -- AHB Master records --------------
 ahbmi : in ahb_mst_in_type;
 ahbmo : out ahb_mst_out_type;
 -- ARM Cortex-M0 AHB-Lite signals -- 
 HADDR : in std_logic_vector (31 downto 0); -- AHB transaction address
 HSIZE : in std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
 HTRANS : in std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
 HWDATA : in std_logic_vector (31 downto 0); -- AHB write-data
 HWRITE : in std_logic; -- AHB write control
 HRDATA : out std_logic_vector (31 downto 0); -- AHB read-data
 HREADY : out std_logic -- AHB stall signal
 );
end;

architecture structural of AHB_bridge is
  
signal sig_dmai : ahb_dma_in_type;
signal sig_dmao : ahb_dma_out_type;
  
  component state_machine --declare a component for state machine	component ahbmst
    port(
      clkm : in std_logic;
      rstn: in std_logic;
      HADDR    		: in std_logic_vector(31 downto 0);
   			HSIZE			: in std_logic_vector(2 downto 0);
			HTRANS   		: in std_logic_vector(1 downto 0);
			HWDATA   		: in std_logic_vector(31 downto 0);
			HWRITE  		: in std_logic;
			HREADY   		: out std_logic;
			dmai			: out ahb_dma_in_type;
			dmao			: in ahb_dma_out_type );
	end component;
			
      
 

  component ahbmst --declare a component for ahbmst	component ahbmst
		generic (
		hindex  : integer := 0;
		hirq    : integer := 0;
		venid   : integer := VENDOR_GAISLER;
		devid   : integer := 0;
		version : integer := 0;
		chprot  : integer := 3;
		incaddr : integer := 0); 
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			dmai		: in ahb_dma_in_type;
			dmao		: out ahb_dma_out_type;
			ahbo		: out ahb_mst_out_type;
			ahbi		: in ahb_mst_in_type
		);
	end component;

component data_swapper
  port(
    HRDATA : out std_logic_vector(31 downto 0);
    dmao : in ahb_dma_out_type
    );
end component;
	 
 


begin
--instantiate state_machine component and make the connections
  statemachine:state_machine
  port map(
  		clkm  => clkm, 
		rstn  => rstn,
		HADDR 	=> HADDR,   
		HSIZE	=> HSIZE,
		HTRANS   => HTRANS,
		HWDATA   => HWDATA,
		HWRITE  => HWRITE,
		HREADY   => HREADY,
		dmai	=>	sig_dmai,
		dmao	=>	sig_dmao
	);
    


--instantiate the ahbmst component and make the connections 
 	ahb_mst: ahbmst
	port map(
		clk => clkm,
		rst => rstn,
		dmao => sig_dmao,
		dmai => sig_dmai,
		ahbo => ahbmo,
		ahbi => ahbmi
	);


--instantiate the data_swapper component and make the connections
dataswapper: data_swapper
  port map(
    dmao => sig_dmao,
    HRDATA => HRDATA

		
		--Only rdata from the dmao signal is needed
	);
	
end structural;