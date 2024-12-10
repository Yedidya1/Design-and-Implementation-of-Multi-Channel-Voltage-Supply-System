library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This block generates the system clock at frequency range of 1-50MHz according to the parameter freq_M
-- which is an integer with unit of MHz. freq_M must be one of the following choices: [ 100, 50, 33, 25, 20, 16, 12, 10, 1](MHz)
-- For 33,16,12 the output clock will be 33.33, 16.67, 12.5 (MHz) respectively, the rest of the choices are accurate.

entity SPI_clock_divider is
    generic(freq_M: integer range 1 to 100 := 1);
    port   (clk100M,rst: in std_logic;
            clk_out: out std_logic);
end SPI_clock_divider;

architecture Behavioral of SPI_clock_divider is

constant limit: integer range 1 to 100 := 100/freq_M;
constant std_limit: std_logic_vector(6 downto 0) := std_logic_vector(to_unsigned(limit,7)-1);
signal d,q,not_clk100M: std_logic;

signal ctr: std_logic_vector(6 downto 0) := "0000000";
signal clk_befor_sample: std_logic;
signal clk_out_buf: std_logic;

component DFF is
    port( clk: in std_logic;
          rst: in std_logic;
          d: in std_logic;
          q: out std_logic);
end component;

begin

OUTPUT_BUF: DFF port map( clk => clk100M,
                          rst => rst,
                            d => clk_befor_sample,
                            q => clk_out_buf        );
                        
-- Counter definition
process(clk100M,rst) begin
    if rst='1' then 
        ctr<="0000000";
    elsif rising_edge(clk100M) then
        if ctr=std_limit then
            ctr<="0000000";
        else
            ctr<=std_logic_vector(unsigned(ctr)+1);
        end if;
    end if;
end process;

-- Extra reversed clock flop definition
not_clk100M<=not clk100M;
process(not_clk100M,rst) begin
    if rst='1' then
        q<='0';
    elsif rising_edge(not_clk100M) then
        if d='1' then 
            q<='1'; 
        else
            q<='0';
        end if;
    end if;
end process;

-- Signal d definition
with freq_M select
d <= ctr(1) when 33,
     ctr(1) when 20,
     '0' when others;
     
-- Output definition
with freq_M select
clk_befor_sample <= ctr(0)                        when 50 ,
                    ctr(1) or q                   when 33 ,
                    ctr(1)                        when 25 ,
                    ctr(1) or q                   when 20 , 
                    ctr(2) or (ctr(1) and ctr(0)) when 16 ,
                    ctr(2)                        when 12 ,
                    ctr(2) or (ctr(1) and ctr(0)) when 10 ,
                    ctr(6) or (ctr(5) and ctr(4) and (ctr(3) or ctr(2) or ctr(1))) when others;
                    
with freq_M select
clk_out <= clk100M when 100,
           clk_out_buf when others;            

end Behavioral;
