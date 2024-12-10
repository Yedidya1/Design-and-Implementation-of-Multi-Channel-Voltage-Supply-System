library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package SPI_package is
 
function log2_int( x: integer := 8 ) return integer;

procedure get_next_rand (signal lfsr : inout std_logic_vector(23 downto 0));

constant seed: integer := 431;
signal lfsr: std_logic_vector(23 downto 0) := std_logic_vector(to_unsigned(seed,24));

-- Entity declared in the end of this file.
component DFF is
    port(clk,rst,d: in std_logic;
         q: out std_logic);
end component;

end package SPI_package;

package body SPI_package is


-- Returns an ineger of log2(x) with round up.
function log2_int ( x : integer := 8 ) return integer is
    variable y: integer := x*10;
    variable res: integer := 0;
begin
    while(y > 10) loop
    y := y/2;
    res := res + 1; 
   end loop;
    return res;
end function;


-- Generates pseudo random std_logic_vectors sequence according to the seed value that initailized  
-- at the top of the package: 
procedure get_next_rand (signal lfsr : inout std_logic_vector(23 downto 0)) is
    variable tmp: std_logic;
begin
     tmp := lfsr(23) xor lfsr(23) xor lfsr(21) xor lfsr(16);
     lfsr <= lfsr(22 downto 0) & tmp;
end procedure;

end package body SPI_package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFF is
    port(clk,rst,d: in std_logic;
         q: out std_logic);
end DFF;

architecture Behavioral of DFF is
begin

process(rst,clk) begin
    if rst='1' then
        q<='0';
    else
        if rising_edge(clk) then
            q<=d;
        end if;
    end if;
end process;   

end behavioral;
