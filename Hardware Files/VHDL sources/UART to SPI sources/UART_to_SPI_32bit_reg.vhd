library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.SPI_package.all;

entity UART_to_SPI_32bit_reg is
    port( clk: in std_logic;
          rst: in std_logic;
          enb: in std_logic;
          state_in: in std_logic_vector(2 downto 0);
          din: in std_logic_vector(7 downto 0);
          slave_sel_byte: out std_logic_vector(7 downto 0);
          data_bytes: out std_logic_vector(23 downto 0)   );
end UART_to_SPI_32bit_reg;

architecture Behavioral of UART_to_SPI_32bit_reg is

signal reg_32: std_logic_vector(31 downto 0);

begin

process(clk) begin
    if rst='1' then
        reg_32 <= (others=>'0');
    else
        if rising_edge(clk) then 
            if enb='1' then 
                case state_in is 
                    when "000" => reg_32(31 downto 24) <= din;   
                    when "001" => reg_32(23 downto 16) <= din;   
                    when "010" => reg_32(15 downto 8) <= din;   
                    when "011" => reg_32(7 downto 0) <= din;
                    when others => reg_32 <= reg_32;   
                end case;
            end if;
        end if;
    end if;
end process;

slave_sel_byte <= reg_32(31 downto 24);
data_bytes <= reg_32(23 downto 0);

end Behavioral;
