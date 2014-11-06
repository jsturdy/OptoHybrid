library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

library unisim;
use unisim.vcomponents.all;

entity optohybrid_top is
port(

    -- OptoHybrid signals

    fpga_clk_i          : in std_logic;
    fpga_rx_i           : in std_logic;
    fpga_tx_o           : out std_logic;
    enable_gtp_o        : out std_logic; 
    fpga_test_o         : out std_logic_vector(5 downto 0);
    leds_o              : out std_logic_vector(3 downto 0);
    
    -- CDCE signals
    
    cdce_le_o           : out std_logic;
    cdce_miso_i         : in std_logic;
    cdce_mosi_o         : out std_logic;
    cdce_sclk_o         : out std_logic;
    
    cdce_auxout_i       : in std_logic;
    cdce_plllock_i      : in std_logic;
    cdce_powerdown_o    : out std_logic;
    cdce_ref_o          : out std_logic;
    cdce_sync_o         : out std_logic;
    cdce_pri_p_o        : out std_logic;
    cdce_pri_n_o        : out std_logic;
    
    -- IIC signals
    
    sda_io              : inout std_logic_vector(5 downto 0); -- 6 IIC sectors
    scl_o               : inout std_logic_vector(5 downto 0);
    
    -- VFAT2 common lines
    
    vfat2_resets_o      : out std_logic_vector(1 downto 0);
    vfat2_mclk_p_o      : out std_logic;
    vfat2_mclk_n_o      : out std_logic;
    vfat2_t1_p_o        : out std_logic;
    vfat2_t1_n_o        : out std_logic;
    vfat2_dvalid_i      : in std_logic_vector(5 downto 0); -- 6 data_valid sectors
    
    -- VFAT2 signal lines
    
    vfat2_data_0_i      : in std_logic_vector(8 downto 0); -- 7 downto 0 = S bits, 8 = data_out (tracking)
    vfat2_data_1_i      : in std_logic_vector(8 downto 0);
    vfat2_data_2_i      : in std_logic_vector(8 downto 0);
    vfat2_data_3_i      : in std_logic_vector(8 downto 0);
    vfat2_data_4_i      : in std_logic_vector(8 downto 0);
    vfat2_data_5_i      : in std_logic_vector(8 downto 0);
    vfat2_data_6_i      : in std_logic_vector(8 downto 0);
    vfat2_data_7_i      : in std_logic_vector(8 downto 0);
    vfat2_data_8_i      : in std_logic_vector(8 downto 0); 
    vfat2_data_9_i      : in std_logic_vector(8 downto 0);
    vfat2_data_10_i     : in std_logic_vector(8 downto 0);
    vfat2_data_11_i     : in std_logic_vector(8 downto 0);
    vfat2_data_12_i     : in std_logic_vector(8 downto 0);
    vfat2_data_13_i     : in std_logic_vector(8 downto 0);
    vfat2_data_14_i     : in std_logic_vector(8 downto 0);
    vfat2_data_15_i     : in std_logic_vector(8 downto 0);
    vfat2_data_16_i     : in std_logic_vector(8 downto 0);
    vfat2_data_17_i     : in std_logic_vector(8 downto 0);
    vfat2_data_18_i     : in std_logic_vector(8 downto 0);
    vfat2_data_19_i     : in std_logic_vector(8 downto 0);
    vfat2_data_20_i     : in std_logic_vector(8 downto 0);
    vfat2_data_21_i     : in std_logic_vector(8 downto 0);
    vfat2_data_22_i     : in std_logic_vector(8 downto 0);
    vfat2_data_23_i     : in std_logic_vector(8 downto 0);
    
    -- GTP signals
    
    rx_p_i              : in std_logic_vector(3 downto 0);
    rx_n_i              : in std_logic_vector(3 downto 0);
    tx_p_o              : out std_logic_vector(3 downto 0);
    tx_n_o              : out std_logic_vector(3 downto 0);
    
    gtp_refclk_p_i      : in std_logic_vector(3 downto 0);
    gtp_refclk_n_i      : in std_logic_vector(3 downto 0)
    
);
end optohybrid_top;

architecture Behavioral of optohybrid_top is
    
    -- Clocking

    signal fpga_clk         : std_logic := '0';  
    signal clk40MHz         : std_logic := '0';
    signal vfat2_clk        : std_logic := '0';
    signal gtp_clk          : std_logic := '0';
    
    -- Resets
    
    signal reset            : std_logic := '0';
    
    -- GTP
    
    signal rx_error         : std_logic_vector(3 downto 0) := (others => '0');
    signal rx_kchar         : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_data          : std_logic_vector(63 downto 0) := (others => '0');
    signal tx_kchar         : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_data          : std_logic_vector(63 downto 0) := (others => '0');
    
    alias rx_error_0        : std_logic is rx_error(0);
    alias rx_error_1        : std_logic is rx_error(1);
    alias rx_error_2        : std_logic is rx_error(2);
    alias rx_error_3        : std_logic is rx_error(3);
    
    alias rx_kchar_0        : std_logic_vector(1 downto 0) is rx_kchar(1 downto 0);
    alias rx_kchar_1        : std_logic_vector(1 downto 0) is rx_kchar(3 downto 2);
    alias rx_kchar_2        : std_logic_vector(1 downto 0) is rx_kchar(5 downto 4);
    alias rx_kchar_3        : std_logic_vector(1 downto 0) is rx_kchar(7 downto 6);
    
    alias rx_data_0         : std_logic_vector(15 downto 0) is rx_kchar(15 downto 0);
    alias rx_data_1         : std_logic_vector(15 downto 0) is rx_kchar(31 downto 16);
    alias rx_data_2         : std_logic_vector(15 downto 0) is rx_kchar(47 downto 32);
    alias rx_data_3         : std_logic_vector(15 downto 0) is rx_kchar(63 downto 48);
    
    alias tx_kchar_0        : std_logic_vector(1 downto 0) is tx_kchar(1 downto 0);
    alias tx_kchar_1        : std_logic_vector(1 downto 0) is tx_kchar(3 downto 2);
    alias tx_kchar_2        : std_logic_vector(1 downto 0) is tx_kchar(5 downto 4);
    alias tx_kchar_3        : std_logic_vector(1 downto 0) is tx_kchar(7 downto 6);
    
    alias tx_data_0         : std_logic_vector(15 downto 0) is tx_kchar(15 downto 0);
    alias tx_data_1         : std_logic_vector(15 downto 0) is tx_kchar(31 downto 16);
    alias tx_data_2         : std_logic_vector(15 downto 0) is tx_kchar(47 downto 32);
    alias tx_data_3         : std_logic_vector(15 downto 0) is tx_kchar(63 downto 48);
    
    -- VFAT2
    
    signal vfat2_t1         : std_logic := '0';
    
    signal sda_i            : std_logic_vector(5 downto 0) := (others => '0');
    signal sda_o            : std_logic_vector(5 downto 0) := (others => '0');
    signal sda_t            : std_logic_vector(5 downto 0) := (others => '0');
    
begin

    -- OptoHybrid reset
    reset <= '0';
  
    -- T1 line LVDS
    t1_obufds : obufds port map(I => vfat2_t1, O => vfat2_t1_p_o, OB => vfat2_t1_n_o);
    
    --================================--
    -- Clocking
    --================================--
    
    -- FPGA clock used to generate the 40 MHz clock to the CDCE and the VFAT2
    fpga_clk_ibufg : ibufg port map(I => fpga_clk_i, O => fpga_clk);
    
    -- PLL used to generate the 40 MHz clock to the CDCE and the VFAT2 
    fpga_clk_pll_inst : entity work.fpga_clk_pll
    port map(
        clk50MHz_i    => fpga_clk,
        clk40MHz_o    => clk40MHz
    );    
    
    -- Internal 40 MHz clock
    vfat2_clk_bufg : bufg port map(I => clk40MHz, O => vfat2_clk);
    
    -- External 40 MHz clock to the VFAT2
    vfat2_clk_obufds : obufds port map(I => clk40MHz, O => vfat2_mclk_p_o, OB => vfat2_mclk_n_o);
    
    -- CDCE control
    cdce_primary_clk_obufds : obufds port map(I => clk40MHz, O => cdce_pri_p_o, OB => cdce_pri_n_o);
    cdce_ref_o <= '1';
    cdce_powerdown_o <= '1';
    cdce_sync_o <= '1';
       
    --================================--
    -- GTP
    --================================--

    -- Enable the GTP
    enable_gtp_o <= '1';
    
    -- GTP wrapper instance to ease the use of the optical links
    gtp_wrapper_inst : entity work.gtp_wrapper
    port map(
        gtp_clk_o       => gtp_clk,
        reset_i         => reset,
        rx_error_o      => rx_error,
        rx_kchar_o      => rx_kchar,
        rx_data_o       => rx_data,
        tx_kchar_i      => tx_kchar,
        tx_data_i       => tx_data,
        rx_n_i          => rx_n_i,
        rx_p_i          => rx_p_i,
        tx_n_o          => tx_n_o,
        tx_p_o          => tx_p_o,
        gtp_refclk_n_i  => gtp_refclk_n_i,
        gtp_refclk_p_i  => gtp_refclk_p_i
    );   
    
    --================================--
    -- I2C
    --================================--
    
    sda_0_iobuf : iobuf port map (o => sda_i(0), io => sda_io(0), i => sda_o(0), t => sda_t(0));    
    sda_1_iobuf : iobuf port map (o => sda_i(1), io => sda_io(1), i => sda_o(1), t => sda_t(1));    
    sda_2_iobuf : iobuf port map (o => sda_i(2), io => sda_io(2), i => sda_o(2), t => sda_t(2));    
    sda_3_iobuf : iobuf port map (o => sda_i(3), io => sda_io(3), i => sda_o(3), t => sda_t(3));    
    sda_4_iobuf : iobuf port map (o => sda_i(4), io => sda_io(4), i => sda_o(4), t => sda_t(4));    
    sda_5_iobuf : iobuf port map (o => sda_i(5), io => sda_io(5), i => sda_o(5), t => sda_t(5));
    
    --================================--
    -- Tracking Link
    --================================--
    
    link_tracking_1_inst : entity work.link_tracking
    port map(
        gtx_clk_i       => gtp_clk,
        vfat2_clk_i     => vfat2_clk,
        reset_i         => reset,
        rx_error_i      => rx_error_1,
        rx_kchar_i      => rx_kchar_1,
        rx_data_i       => rx_data_1,
        tx_kchar_o      => tx_kchar_1,
        tx_data_o       => tx_data_1,
        sda_i           => sda_i(3 downto 2),
        sda_o           => sda_o(3 downto 2),
        sda_t           => sda_t(3 downto 2),
        scl_o           => scl_o(3 downto 2),
        vfat2_dvalid_i  => vfat2_dvalid_i(3 downto 2),
        vfat2_data_0_i  => vfat2_data_8_i(8),
        vfat2_data_1_i  => vfat2_data_8_i(9),
        vfat2_data_2_i  => vfat2_data_8_i(10),
        vfat2_data_3_i  => vfat2_data_8_i(11),
        vfat2_data_4_i  => vfat2_data_8_i(12),
        vfat2_data_5_i  => vfat2_data_8_i(13),
        vfat2_data_6_i  => vfat2_data_8_i(14),
        vfat2_data_7_i  => vfat2_data_8_i(15)
    );
      
end Behavioral;