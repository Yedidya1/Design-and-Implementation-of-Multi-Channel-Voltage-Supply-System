library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_UART_rec_and_UART_to_SPI is
    port( clk: in std_logic;
          rst: in std_logic;
          rx: in std_logic;
          slave_sel_byte: out std_logic_vector(7 downto 0);
          valid: out std_logic;
          data_bytes: out std_logic_vector(23 downto 0)  );
end top_UART_rec_and_UART_to_SPI;

architecture Behavioral of top_UART_rec_and_UART_to_SPI is

component UART_top_receiver is
    port(clk100M,Rx,rst: in std_logic;
         data_buff: out std_logic_vector(7 downto 0);
         valid: out std_logic );
end component;

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

signal valid_UART: std_logic;
signal received_byte: std_logic_vector(7 downto 0);

begin 

UART_REC: UART_top_receiver port map( clk100M => clk,
                                      rx => rx,
                                      rst => rst,
                                      data_buff => received_byte,
                                      valid => valid_UART        );
                                  
UART_TO_SPI: top_UART_to_SPI port map( clk => clk,
                                       rst => rst,
                                       valid_in => valid_UART,
                                       received_byte => received_byte,
                                       ready_SPI => '1',
                                       valid_out => valid,
                                       slave_sel => slave_sel_byte,
                                       data_SPI => data_bytes        );
                                   

end Behavioral;
