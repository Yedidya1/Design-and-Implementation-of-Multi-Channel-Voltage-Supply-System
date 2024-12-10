library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_UART_to_SPI is
    port( clk: in std_logic;
          rst: in std_logic;
          valid_in: in std_logic;
          received_byte: in std_logic_vector(7 downto 0);
          ready_SPI: in std_logic;
          valid_out: out std_logic;
          slave_sel: out std_logic_vector(7 downto 0);
          data_SPI: out std_logic_vector(23 downto 0)  );
end top_UART_to_SPI;

architecture Behavioral of top_UART_to_SPI is

--component UART_to_SPI_state_machine is
--    port( clk: in std_logic;
--          rst: in std_logic;
--          enb: in std_logic;
--          ready: in std_logic;
--          state_out: out std_logic_vector(2 downto 0);
--          valid: out std_logic                         
--          );
--end component;

component UART_to_SPI_32bit_reg is
    port( clk: in std_logic;
          rst: in std_logic;
          enb: in std_logic;
          state_in: in std_logic_vector(2 downto 0);
          din: in std_logic_vector(7 downto 0);
          slave_sel_byte: out std_logic_vector(7 downto 0);
          data_bytes: out std_logic_vector(23 downto 0)   );
end component;

signal state: std_logic_vector(2 downto 0); 

--------------------------------------------------------------
--COMPONENT ila_UART_to_SPI
--PORT (
--	clk : IN STD_LOGIC;
--    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--	probe1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
--);
--END COMPONENT  ;

signal valid_out_buf: std_logic;
signal slave_sel_buf:  std_logic_vector(7 downto 0);
signal data_SPI_buf: std_logic_vector(23 downto 0); 
------------------------------------------------------------------

begin

FSM: entity work.UART_to_SPI_state_machine(B2) port map( clk => clk,
                                         rst => rst,
                                         enb => valid_in,
                                         ready => ready_SPI,
                                         state_out => state,
                                         valid => valid_out_buf ); -- valid_out
                                     
REG32:   UART_to_SPI_32bit_reg port map( clk => clk,
                                         rst => rst,
                                         enb => valid_in,
                                         state_in => state,
                                         din => received_byte,
                                         slave_sel_byte => slave_sel_buf, --slave_sel
                                         data_bytes => data_SPI_buf      ); --data_SPI
                                         
----------------------------
--ILA_MID_BLOCK : ila_UART_to_SPI
--PORT MAP (
--	clk => clk,
--    probe0(0) => valid_in, 
--	probe1 => state
--	);

valid_out <= valid_out_buf;
slave_sel <= slave_sel_buf;
data_SPI <= data_SPI_buf;
----------------------------
                                     
end Behavioral;
