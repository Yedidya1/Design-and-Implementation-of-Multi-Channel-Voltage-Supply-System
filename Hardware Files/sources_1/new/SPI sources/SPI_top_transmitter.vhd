library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.SPI_package.all;

entity SPI_top_transmitter is
    generic(length: integer range 0 to 64 := 8;
            freq_M: integer range 1 to 100 := 1;
            mode: integer range 0 to 3 := 0;
            slave_num: integer := 4             );
       port(clk100M,rst,send: in std_logic;
            data_in: in std_logic_vector(length-1 downto 0);
            slave_sel: in std_logic_vector(log2_int(slave_num)-1 downto 0); 
            mosi,ready,sclk: out std_logic;
            cs_vector: out std_logic_vector(slave_num-1 downto 0));
end SPI_top_transmitter;

architecture Behavioral of SPI_top_transmitter is

component SPI_clock_divider is
    generic(freq_M: integer range 1 to 100 := 1);
    port   (clk100M,rst: in std_logic;
            clk_out: out std_logic);
end component;

signal clk_spi: std_logic;  -- the system general clock

component SPI_PISO_reg is
    generic(length: integer range 0 to 64 := 8);
       port(clk100M,clk,rst,enb: in std_logic;
            par_in: in std_logic_vector(length-1 downto 0);
            count: in integer range 0 to length;
            ser_out: out std_logic );
end component;

signal enb: std_logic;
signal count: integer range 0 to length;

component SPI_counter is
    generic(length: integer range 0 to 64 := 10;
            mode: integer range 0 to 3 := 3  );
       port(clk,rst,enb: in std_logic;
            count: out integer range 0 to length;
            reset_state: out std_logic;
            sclk_enb: out std_logic             );
end component;

signal reset_state, sclk_enb,FSM_rst: std_logic;

component SPI_state_machine is
    generic(mode: integer range 0 to 3 := 0);
       port(clk,rst,send: in std_logic;
            state_out: out std_logic);
end component;

component SPI_cs_decoder is
    generic( slave_num: integer := 4 );
       port( slave_sel: in std_logic_vector(log2_int(slave_num)-1 downto 0);
             enb: in std_logic;
             cs_vector: out std_logic_vector(slave_num-1 downto 0));
end component;

begin

clk_gen: SPI_clock_divider generic map(  freq_M => freq_M   )
                          port map( clk100M => clk100M,
                                        rst => rst,
                                    clk_out => clk_spi  );
                                
SHIFT_REG: SPI_PISO_reg generic map   (  length => length   )
                          port map( clk100M => clk100M,
                                        clk => clk_spi,
                                        rst => rst,
                                        enb => enb,
                                     par_in => data_in,
                                      count => count,
                                    ser_out => mosi     );
                                
CTR: SPI_counter generic map (       length => length,
                                   mode => mode         )
                 port map(          clk => clk_spi,
                                    rst => rst,
                                    enb => enb,
                                  count => count,
                            reset_state => reset_state,
                               sclk_enb => sclk_enb     );
                        
FSM: SPI_state_machine generic map (     mode => mode     )
                      port map (      clk => clk_spi,
                                      rst => FSM_rst,
                                     send => send,
                                state_out => enb      );      

CS_DEC: SPI_cs_decoder generic map ( slave_num => slave_num )
                      port map ( slave_sel => slave_sel,
                                       enb => enb,
                                 cs_vector => cs_vector );

                           
ready <= (not enb); --and (not send);
sclk <= clk_spi and sclk_enb;
FSM_rst <= reset_state or rst;
                                                     
end Behavioral;
