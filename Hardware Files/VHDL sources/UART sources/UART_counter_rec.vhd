library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- counter for reciever
entity UART_counter_rec is
    port(clk,rst: in std_logic;
         count: buffer std_logic_vector(3 downto 0));
end UART_counter_rec;

architecture Behavioral of UART_counter_rec is

signal not_clk: std_logic;

begin

not_clk <= not clk;

process(not_clk,rst) begin 
    if rst='1' then
        count<=X"0";
    elsif rising_edge(not_clk) then 
        if count = X"A" then
            count<=X"0";
        else  
            count<=std_logic_vector(unsigned(count)+1);
        end if;
    end if; 
end process;

end Behavioral;