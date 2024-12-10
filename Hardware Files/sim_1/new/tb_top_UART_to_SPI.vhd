library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_UART_to_SPI is
--  Port ( );
end tb_top_UART_to_SPI;

architecture Behavioral of tb_top_UART_to_SPI is

component top_UART_to_SPI is
    port( clk: in std_logic;
          rst: in std_logic;
          valid_in: in std_logic;
          received_byte: in std_logic_vector(7 downto 0);
          valid_out: out std_logic;
          slave_sel: out std_logic_vector(7 downto 0);
          data_SPI: out std_logic_vector(23 downto 0)  );
end component;

signal clk: std_logic := '0';
signal rst: std_logic := '1';
signal valid_in: std_logic;
signal received_byte: std_logic_vector(7 downto 0);
signal valid_out: std_logic;
signal slave_sel: std_logic_vector(7 downto 0);
signal data_SPI: std_logic_vector(23 downto 0);

constant cyc: time := 10ns;

begin

DUT: top_UART_to_SPI port map( clk => clk,
                               rst => rst,
                               valid_in => valid_in,
                               received_byte => received_byte,
                               valid_out => valid_out,
                               slave_sel => slave_sel,
                               data_SPI => data_SPI   
                               );

process begin
    clk <= not clk;
    wait for cyc/2;
end process;

process begin

wait;
end process;

end Behavioral;
