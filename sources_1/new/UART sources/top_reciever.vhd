library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.SPI_package.all;

entity UART_top_receiver is
    port(clk100M,Rx,rst: in std_logic;
         data_buff: out std_logic_vector(7 downto 0);
         valid: out std_logic );
end UART_top_receiver;

architecture Behavioral of UART_top_receiver is

component clk_UART_rec is
    generic(baud_rate: integer := 9600);
    Port(clk100M,start,rst: in std_logic;
         clk_UART: out std_logic;
         s: buffer std_logic);
end component;

component UART_counter_rec is
    port(clk,rst: in std_logic;
         count: buffer std_logic_vector(3 downto 0));
end component;

component UART_state_machine_rec is
    port(Rx,clk,rst: in std_logic;
         count: in std_logic_vector(3 downto 0);
         state: buffer std_logic);
end component;

component UART_input_shift_reg is
    port(rst,clk,enb,d_in: in std_logic;
         d_out: buffer std_logic_vector(7 downto 0));
end component;

signal state,clk_UART,reset_count: std_logic;
signal count: std_logic_vector(3 downto 0);
signal enb_input,enabled_UART_clk,s,sync_state : std_logic;
signal parallel_data,data_buffer: std_logic_vector(7 downto 0);
signal synch_Rx,D1: std_logic;

begin

UARTclk: clk_UART_rec generic map(baud_rate=>9600)
					  port map(	clk100M => clk100M,
								  start => state,
								    rst => rst,
							   clk_UART => clk_UART,
									  s => s 				);
                   
CTR: 	  UART_counter_rec port map(		clk => enabled_UART_clk,
									        rst => reset_count,
								          count => count			);

SM: UART_state_machine_rec port map(		 Rx => Rx,
									        rst => rst,
								          count => count,
								          state => sync_state,
								            clk => clk100M			);

SH_R: UART_input_shift_reg port map(		rst => rst,
									        clk => clk_UART,
									        enb => enb_input,
								           d_in => Rx,
								          d_out => parallel_data	);
                                      
-- Synchronizer block
--DFF0: DFF port map( D => Rx,
--                    Q => D1,
--                    rst => rst,
--                    clk => clk100M ); 
                
--DFF1: DFF port map( D => D1,
--                    Q => synch_Rx,
--                    rst => rst,
--                    clk => clk100M );

state<=sync_state or s;

reset_count<=rst or (not state);

enb_input<='1' when (state='1' and unsigned(count)>0 and unsigned(count)<9) else '0'; 

enabled_UART_clk<=clk_UART and state and (not s);

process(state,rst) begin
    if rst='1' then
        data_buffer<=x"00";
    else
        if state='0' then 
            data_buffer<=parallel_data;
        end if;
    end if;        
end process;

data_buff<=data_buffer;
valid<=not state;

end Behavioral;
