library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This block is responsible for the frame timing by resetting the state machine at the appropriate time 
-- and by outputting the PISO register the bit index that should be transmitted on the MOSI line. sclk_enb 
-- output is intended to enable the serial clock whenever a frame is sent. 


entity SPI_counter is
    generic(length: integer range 0 to 64 := 10;
            mode: integer range 0 to 3 := 3  );
       port(clk,rst,enb: in std_logic;
            count: out integer range 0 to length;
            reset_state: out std_logic;
            sclk_enb: out std_logic             );
end SPI_counter;

architecture Behavioral of SPI_counter is

signal ctr: integer range 0 to length+1;
signal ctr_clk,rst_clk,d,q,r: std_logic;
signal rst_val: integer range 0 to 1;

begin

-- Counting clock definition according to mode
with mode select
ctr_clk <= not clk when 0,
           not clk when 3,
           clk when others;

-- Counter definition
process(ctr_clk,rst,enb) begin
    if rst='1' or enb ='0' then 
        if mode=0 or mode=2 then
            ctr <= 1;
        else
            ctr <= 0;
        end if;
    elsif rst='0' and enb='1' then  
        if rising_edge(ctr_clk) then 
                ctr <= ctr + 1;
        end if;
    end if;     
end process;

-- Reset_state circuit:

-- Rst clock is reversed from the counter clock in each mode
with mode select
rst_clk <= not clk when 2,
           clk when others;
           
process(ctr) begin
    if ctr=length+1 then 
        d <= '1';
    else 
        d <= '0';
    end if;
end process;

-- Creation of fliped clock flip-flop for an extra half cycle of the output reset 
-- in modes 0 and 2. 
process(rst_clk,rst,enb) begin 
    if rst='1' or enb='0' then 
        q <= '0';
    elsif rising_edge(rst_clk) then 
        q <= d;
    end if;
end process;

with mode select
reset_state <= q when 0,
               q when 2,
               d when others;
               
rst_val <= 0 when (mode=1 or mode=3) else 1;           
           
-- Count output definition
count <= ctr when ctr < length+1 else rst_val;

-- sclk enb for eleminating the clk when the frame is over
sclk_enb <= '0' when (ctr=length+1 or enb='0') else '1';

end Behavioral;
