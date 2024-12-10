-- Receiver state machine:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_state_machine_rec is
    port(Rx,clk,rst: in std_logic;
         count: in std_logic_vector(3 downto 0);
         state: buffer std_logic);
end UART_state_machine_rec;

architecture Behavioral of UART_state_machine_rec is

begin

process(clk,rst) begin
    if rst='1' then
        state<='0';
    else
        if rising_edge(clk) then
            if state='0' then 
                if Rx='0' then
                    state<='1';
                end if;
            else 
                if count=X"A" then 
                    state<='0';
                end if;
            end if; 
        end if;
    end if;   
end process;

end Behavioral;