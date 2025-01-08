library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.SPI_package.all;

entity UART_to_SPI_state_machine is
    port( clk: in std_logic;
          rst: in std_logic;
          enb: in std_logic;
          ready: in std_logic;
          state_out: out std_logic_vector(2 downto 0);
          valid: out std_logic                         
          );
end UART_to_SPI_state_machine;

architecture B2 of UART_to_SPI_state_machine is

signal edge_enb_buf,edge_enb: std_logic;
signal Q,delayed_rst: std_logic;
signal state: std_logic_vector(2 downto 0) := "000";
signal D: std_logic_vector(2 downto 0);

begin

ENB_EDGE_DET: DFF port map( D => enb,
                            Q => Q,
                            clk => clk,
                            rst => rst );
                    
RESET_DELAY: DFF port map( D => rst,
                           Q => delayed_rst,
                           clk => clk,
                           rst => '0'      );
                        
edge_enb <= enb and (not Q) and (not delayed_rst); -- delayed_rst is added for avioding edge detection after rst. 

EDGE_ENB_BUFF: DFF port map( D => edge_enb,
                             Q => edge_enb_buf,
                             clk => clk,
                             rst => rst );
                         
process(clk,rst,ready) begin
    if rst='1' or ready='0' then 
        state <= "000";
    else 
        if rising_edge(clk) then 
            state <= D;
        end if;
    end if;
end process;

with edge_enb_buf select
D <= std_logic_vector(unsigned(state)+1) when '1',
     state when others;
     
state_out <= state;

with state select
valid <= '1' when "100",
         '0' when others;

end B2;
