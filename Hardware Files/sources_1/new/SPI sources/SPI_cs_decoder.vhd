library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
library work;
use work.SPI_package.all;


entity SPI_cs_decoder is
    generic( slave_num: integer := 4 );
       port( slave_sel: in std_logic_vector(log2_int(slave_num)-1 downto 0);
             enb: in std_logic;
             cs_vector: out std_logic_vector(slave_num-1 downto 0));
end SPI_cs_decoder;

architecture Behavioral of SPI_cs_decoder is

signal slave_sel_latch: std_logic_vector(log2_int(slave_num)-1 downto 0);

begin

with enb select
slave_sel_latch <= slave_sel when '0',
                   slave_sel_latch when others;

process(enb,slave_sel_latch)
variable sel: integer range 0 to slave_num;
begin
    sel := to_integer(unsigned(slave_sel_latch));
    if enb='0' then
        cs_vector <= (others => '1');
    else
        cs_vector(sel) <= '0';
        if sel < (slave_num-1) then
            cs_vector(slave_num-1 downto sel+1) <= (others=>'1');
        end if;
        if sel > 0 then
            cs_vector(sel-1 downto 0) <= (others=>'1');
        end if;
    end if;
end process;

end Behavioral;
