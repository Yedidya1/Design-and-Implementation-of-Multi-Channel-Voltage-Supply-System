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

architecture Behavioral of UART_to_SPI_state_machine is

type state is( IDLE,f1,f2,f3,send );
signal PS,NS: state;
signal edge_enb_buf,edge_enb: std_logic;
signal Q,delayed_rst: std_logic;

---------------------------------------------------------
COMPONENT ila_UART_to_SPI
PORT (
	clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
);
END COMPONENT  ;

signal state_out_buf: std_logic_vector(2 downto 0);
signal valid_buf: std_logic;
----------------------------------------------------------
begin

UART_to_SPI_fsm : ila_UART_to_SPI
PORT MAP (
	clk => clk,
    probe0(0) => enb, 
	probe1(0) => edge_enb_buf, 
	probe2(0) => valid_buf,
	probe3 => state_out_buf
);

process(clk,rst) begin
    if rst='1' then 
        PS <= IDLE;
    else
        if rising_edge(clk) then 
            PS <= NS;
        end if;
    end if;
end process;

process(edge_enb_buf,rst,PS,ready) begin
    if rst='1' then
        NS <= IDLE;
        valid_buf <= '0'; --valid
        state_out_buf <= "000"; --state_out
    else
        case PS is
            when IDLE =>
                valid_buf <= '0'; --valid
                state_out_buf <= "000"; --state_out
                if edge_enb_buf='1' then 
                    NS <= f1;
                end if;
            when f1 =>
                valid_buf <= '0'; --valid
                state_out_buf <= "001"; --state_out 
                if edge_enb_buf='1' then 
                    NS <= f2;
                end if;
            when f2 =>
                valid_buf <= '0'; --valid
                state_out_buf <= "010"; --state_out
                if edge_enb_buf='1' then 
                    NS <= f3;
                end if;
            when f3 =>
                valid_buf <= '0'; --valid
                state_out_buf <= "011"; --state_out
                if edge_enb_buf='1' then 
                    NS <= send;
                end if;
            when send => 
                valid_buf <= '1'; --valid
                state_out_buf <= "100"; --state_out
                if ready='0' then 
                    NS <= IDLE;
                end if;
        end case;    
     end if;
end process;

EDGE_DET: DFF port map( D => enb,
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

-------------------------------                         
state_out <= state_out_buf;
valid <= valid_buf;
-------------------------------
end Behavioral;


architecture B2 of UART_to_SPI_state_machine is

signal edge_enb_buf,edge_enb: std_logic;
signal Q,delayed_rst: std_logic;
signal state: std_logic_vector(2 downto 0) := "000";
signal D: std_logic_vector(2 downto 0);

---------------------------------------------------------
COMPONENT ila_UART_to_SPI
PORT (
	clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
	probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	probe3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
);
END COMPONENT  ;

signal valid_buf: std_logic;
----------------------------------------------------------
begin

UART_to_SPI_fsm : ila_UART_to_SPI
PORT MAP (
	clk => clk,
    probe0(0) => enb, 
	probe1(0) => edge_enb_buf, 
	probe2(0) => valid_buf,
	probe3 => state
);

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
valid_buf <= '1' when "100",
             '0' when others;

-------------------------------                         
valid <= valid_buf;
-------------------------------

end B2;
