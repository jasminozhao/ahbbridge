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

entity cm0_wrapper is
  port(
   -- Clock and Reset -----------------
    clkm : in std_logic;
    rstn : in std_logic;
    ahbmi : in ahb_mst_in_type;
    ahbmo : out ahb_mst_out_type;
    led_blink : out std_logic
  );
end;

architecture structral of cm0_wrapper is
  component CORTEXM0DS is
    port(
      HCLK : in std_logic;
      HRESETn : in std_logic;
      HREADY : in std_logic;
      HRDATA : in std_logic_vector (31 downto 0);
      HWRITE : out std_logic;
      HWDATA : out std_logic_vector (31 downto 0);
      HTRANS : out std_logic_vector (1 downto 0);
      HSIZE : out std_logic_vector (2 downto 0);
      HADDR : out std_logic_vector (31 downto 0);
      HRESP: in std_logic;
      NMI : in std_logic;
      IRQ : in std_logic_vector(15 downto 0);
      RXEV : in std_logic
    );
  end component;
 
  component AHB_bridge is
    port(
      clkm : in std_logic;
      rstn : in std_logic;
      HREADY : out std_logic;
      HRDATA : out std_logic_vector (31 downto 0);
      HWRITE : in std_logic;
      HWDATA : in std_logic_vector (31 downto 0);
      HTRANS : in std_logic_vector (1 downto 0);
      HSIZE : in std_logic_vector (2 downto 0);
      HADDR : in std_logic_vector (31 downto 0);
      ahbmi : in ahb_mst_in_type;
      ahbmo : out ahb_mst_out_type
    );
 end component;


signal sig_HREADY : std_logic;
signal sig_HRDATA : std_logic_vector (31 downto 0);
signal sig_HWRITE : std_logic;
signal sig_HWDATA : std_logic_vector (31 downto 0);
signal sig_HTRANS : std_logic_vector (1 downto 0);
signal sig_HSIZE : std_logic_vector (2 downto 0);
signal sig_HADDR : std_logic_vector (31 downto 0);
signal ledblink : std_logic;




begin
  
process (clkm, sig_HRDATA, ledblink)
begin
  if (falling_edge(clkm)) then
    if (sig_HRDATA(31 downto 0) = "00001110000011100000111000001110") then
      ledblink <= '1';
    else 
      ledblink <= '0';
    end if;
  end if;
end process;
led_blink <= ledblink;

      
  cortexm0:CORTEXM0DS
  port map(
    HCLK => clkm,
    HRESETn => rstn,
    HREADY => sig_HREADY,
    HRDATA => sig_HRDATA,
    HWRITE => sig_HWRITE,
    HWDATA => sig_HWDATA,
    HTRANS => sig_HTRANS,
    HSIZE => sig_HSIZE,
    HADDR => sig_HADDR,
    HRESP => '0',
    NMI => '0',
    IRQ => (others=>'0'),
    RXEV => '0'
  );
 
  ahbbridge:AHB_bridge
  port map(
    clkm => clkm,
    rstn => rstn,
    ahbmo => ahbmo,
    ahbmi => ahbmi,
    HREADY => sig_HREADY,
    HRDATA => sig_HRDATA,
    HWRITE => sig_HWRITE,
    HWDATA => sig_HWDATA,
    HTRANS => sig_HTRANS,
    HSIZE => sig_HSIZE,
    HADDR => sig_HADDR
  );
end;
