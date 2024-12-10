library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_UART_to_SPI is
    port( clk: in std_logic;
          rst: in std_logic;
          valid_in: in std_logic;
          received_byte: in std_logic_vector(7 downto 0);
          ready_SPI: in std_logic;
          valid_out: out std_logic;
          slave_sel: out std_logic_vector(7 downto 0);
          data_SPI: out std_logic_vector(23 downto 0)  );
end top_UART_to_SPI;

architecture Behavioral of top_UART_to_SPI is


component UART_to_SPI_32bit_reg is
    port( clk: in std_logic;
          rst: in std_logic;
          enb: in std_logic;
          state_in: in std_logic_vector(2 downto 0);
          din: in std_logic_vector(7 downto 0);
          slave_sel_byte: out std_logic_vector(7 downto 0);
          data_bytes: out std_logic_vector(23 downto 0)   );
end component;

signal state: std_logic_vector(2 downto 0); 

begin

FSM: entity work.UART_to_SPI_state_machine(B2) port map( clk => clk,
                                         rst => rst,
                                         enb => valid_in,
                                         ready => ready_SPI,
                                         state_out => state,
                                         valid => valid_out ); 
                                     
REG32:   UART_to_SPI_32bit_reg port map( clk => clk,
                                         rst => rst,
                                         enb => valid_in,
                                         state_in => state,
                                         din => received_byte,
                                         slave_sel_byte => slave_sel, 
                                         data_bytes => data_SPI      ); 
                                     
end Behavioral;
