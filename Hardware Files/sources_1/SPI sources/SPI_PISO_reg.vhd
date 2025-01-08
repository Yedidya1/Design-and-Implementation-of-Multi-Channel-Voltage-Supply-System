library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- This block gets the data intended for transmition only when the transmition does not taking place, and do the 
-- tranmition itself when it enabled.

entity SPI_PISO_reg is
    generic(length: integer range 0 to 64 := 8);
       port(clk100M,rst,enb: in std_logic;
            par_in: in std_logic_vector(length-1 downto 0);
            count: in integer range 0 to length;
            ser_out: out std_logic );
end SPI_PISO_reg;

architecture Behavioral of SPI_PISO_reg is

signal reg: std_logic_vector(length-1 downto 0);

begin

-- parallel data load
process(clk100M,rst) begin
    if rst='1' then
        reg <= (others=>'0');
    elsif enb='0' then
        if rising_edge(clk100M) then
            reg <= par_in;
        end if;
    end if;
end process;

-- Serialization process
process(count,enb) begin
    if enb='1' then
        if count>0 then
            ser_out <= reg(length-count);
        end if;    
    end if;
end process;

end Behavioral;
