library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.SPI_package.all;

entity top is
   port(clk100M: in std_logic;
            rst: in std_logic;
            rx: in std_logic;
            rst_DAC: out std_logic;
            mosi: out std_logic;
            sclk: out std_logic;
            cs: out std_logic_vector(7 downto 0) ); 
end top;

architecture Behavioral of top is

-- SPI module parameters
constant length: integer range 0 to 64 := 24;
constant freq_M: integer range 1 to 100 := 10;
constant mode: integer range 0 to 3 := 2;
constant slave_num: integer := 8;   

component SPI_top_transmitter is
    generic(length: integer range 0 to 64 := 8;
            freq_M: integer range 1 to 100 := 1;
            mode: integer range 0 to 3 := 0;
            slave_num: integer := 4             );
       port(clk100M,rst,send: in std_logic;
            data_in: in std_logic_vector(length-1 downto 0);
            slave_sel: in std_logic_vector(log2_int(slave_num)-1 downto 0); 
            mosi,ready,sclk: out std_logic;
            cs_vector: out std_logic_vector(slave_num-1 downto 0));
end component;

component UART_top_receiver is
    port(clk100M,Rx,rst: in std_logic;
         data_buff: out std_logic_vector(7 downto 0);
         valid: out std_logic );
end component;

signal valid_UART: std_logic;
signal received_byte_UART: std_logic_vector(7 downto 0);

component top_UART_to_SPI is
    port( clk: in std_logic;
          rst: in std_logic;
          valid_in: in std_logic;
          received_byte: in std_logic_vector(7 downto 0);
          ready_SPI: in std_logic;
          valid_out: out std_logic;
          slave_sel: out std_logic_vector(7 downto 0);
          data_SPI: out std_logic_vector(23 downto 0)  );
end component;

signal slave_sel_byte: std_logic_vector(7 downto 0);
signal valid_for_SPI: std_logic;
signal data_for_SPI: std_logic_vector(23 downto 0);
signal ready_SPI: std_logic;

signal Q: std_logic;

----------------------------------------------------------------------
COMPONENT ila_top4
PORT (
	clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END COMPONENT  ;

signal sclk_buf,mosi_buf: std_logic;
signal cs_buf: std_logic_vector(7 downto 0);
------------------------------------------------------------

begin

SPI: SPI_top_transmitter generic map( length => length,
                                      freq_M => freq_M,
                                      mode => mode,
                                      slave_num => slave_num )
                            port map( clk100M => clk100M,
                                      rst => rst,
                                      send => valid_for_SPI,
                                      data_in => data_for_SPI,
                                      slave_sel => slave_sel_byte(2 downto 0), 
                                      mosi => mosi_buf, --mosi
                                      ready => ready_SPI,
                                      sclk => sclk_buf, -- sclk
                                      cs_vector => cs_buf                      ); --cs_buf
                                  

UART: UART_top_receiver port map( clk100M => clk100M,
                                  rst => rst,
                                  rx => rx,
                                  data_buff => received_byte_UART,
                                  valid => valid_UART           );
                              
UART_TO_SPI: top_UART_to_SPI port map( clk => clk100M,
                                       rst => rst,
                                       valid_in => valid_UART,
                                       received_byte => received_byte_UART,
                                       ready_SPI => ready_SPI,
                                       valid_out => valid_for_SPI,
                                       slave_sel => slave_sel_byte,
                                       data_SPI => data_for_SPI          );

RESET_DAC_BUF: DFF port map( D => rst,
                             Q => Q,
                             clk => clk100M,
                             rst => '0' );
                         
rst_DAC <= not Q;

----------------------------------------------------------
ILA_TOP: ila_top4
PORT MAP (
	clk => clk100M,
    probe0(0) => rx, 
	probe1(0) => mosi_buf, 
	probe2(0) => sclk_buf,
	probe3 => cs_buf
);

mosi <= mosi_buf;
sclk <= sclk_buf;
cs <= cs_buf;
-----------------------------------------------------------

end Behavioral;
