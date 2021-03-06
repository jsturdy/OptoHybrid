library ieee;
use ieee.std_logic_1164.all;

library work;
use work.user_package.all;

entity gtp_rx_mux is
port(

    gtp_clk_i   : in std_logic;
    reset_i     : in std_logic;
    
    vi2c_en_o   : out std_logic;
    vi2c_data_o : out std_logic_vector(31 downto 0);
    
    regs_en_o   : out std_logic;
    regs_data_o : out std_logic_vector(47 downto 0);
  
    rx_kchar_i  : in std_logic_vector(1 downto 0);
    rx_data_i   : in std_logic_vector(15 downto 0)
    
);
end gtp_rx_mux;

architecture Behavioral of gtp_rx_mux is
begin

    process(gtp_clk_i) 
    
        -- State machine
        variable state          : integer range 0 to 3 := 0;
    
        -- Incomming data
        variable data           : std_logic_vector(47 downto 0) := (others => '0');
        variable data_cnt       : integer range 0 to 15 := 0;
        
        -- Output slave
        variable selected_core  : integer range 0 to 3 := 0;    -- 1 = VFAT2 I2C
                                                                -- 2 = Registers
    
    begin
    
        if (rising_edge(gtp_clk_i)) then
        
            -- Reset
            if (reset_i = '1') then
                
                vi2c_en_o <= '0';
                
                regs_en_o <= '0';
                
                state := 0;
                
            else
                    
                -- Wait for packet
                if (state = 0) then
                    
                    vi2c_en_o <= '0';
                    
                    regs_en_o <= '0';
                
                    -- Detect data package
                    if (rx_kchar_i = "01") then
                    
                        -- VFAT2 I2C data packet
                        if (rx_data_i = def_gtp_vi2c & x"BC") then
                        
                            selected_core := 1;
                            
                            data_cnt := 2;
                            
                            state := 1;
                            
                        -- Registers data packet
                        elsif (rx_data_i = def_gtp_regs & x"BC") then
                        
                            selected_core := 2;
                            
                            data_cnt := 3;
                            
                            state := 1;
                            
                        end if; 
                        
                    end if;
                   
                -- Receive data
                elsif (state = 1) then
                
                    -- This condition allows a fast command to be inserted in the data stream (ignore that packet and resume afterwards)
                    if (rx_kchar_i = "00") then
                
                        -- Receive data
                        data((data_cnt * 16 - 1) downto ((data_cnt - 1) * 16)) := rx_data_i;
                        
                        if (data_cnt = 1) then
                        
                            state := 2;
                            
                        else
                            
                            data_cnt := data_cnt - 1;
                            
                        end if;
                    
                    end if;
                   
                -- Acknowledge the selected core     
                elsif (state = 2) then
                
                    if (selected_core = 1) then
                    
                        -- Set the data
                        vi2c_data_o <= data(31 downto 0);
                    
                        -- Storbe
                        vi2c_en_o <= '1';
                
                    elsif (selected_core = 2) then
                    
                        -- Set the data
                        regs_data_o <= data(47 downto 0);
                    
                        -- Storbe
                        regs_en_o <= '1';
                    
                    end if;
                    
                    state := 0;
                    
                -- Out of FSM
                else
                
                    vi2c_en_o <= '0';
                    
                    regs_en_o <= '0';
                
                    state := 0;
                    
                end if;
                
            end if;
                
            
        end if;
        
    end process;
    
end Behavioral;

