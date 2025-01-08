library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.all;    -- for uniform & trunc functions
use ieee.numeric_std.all;  -- for to_unsigned function

entity tb_top is
--  Port ( );
end tb_top;

architecture Behavioral of tb_top is

component top is
   port(clk100M: in std_logic;
            rst: in std_logic;
            rx: in std_logic;
            rst_DAC: out std_logic;
            mosi: out std_logic;
            sclk: out std_logic;
            cs: out std_logic_vector(7 downto 0) ); 
end component;

signal clk: std_logic := '0';
signal rst: std_logic := '1';
signal rx: std_logic := '1';
signal rst_DAC: std_logic;
signal mosi: std_logic;
signal sclk: std_logic;
signal cs: std_logic_vector(7 downto 0);

signal test_data: std_logic_vector(9 downto 0);

constant cyc: time := 10ns;
constant cycUART: time := 104.166us; -- for baud rate of 9600bps

begin

DUT: top port map( clk100M => clk,
                   rst => rst,
                   rx => rx,
                   rst_DAC => rst_DAC,
                   mosi => mosi,
                   sclk => sclk,
                   cs => cs         );
                   
process begin
    clk<=not clk;
    wait for cyc/2;
end process;

-- This process contain creation of random 8-bit test data and then it fed into the receiver 
-- through Rx signal. 
process 
variable seed1, seed2: positive;  				-- seed values for random generator
variable rand: real;              				-- random real-number value in range 0 to 1.0
variable int_rand: integer;       				-- random integer value in range 0..255
variable stim: std_logic_vector(7 downto 0); 	-- random 12-bit stimulus
begin
    test_data <= (others=>'0');
    wait for 2*cyc;
    rst<='0';
    wait for 2.3*cycUART;
    for j in 0 to 100 loop
        uniform(seed1, seed2, rand);
        int_rand := integer(trunc(rand*255.0));
        stim := std_logic_vector(to_unsigned(int_rand, stim'length));
        test_data<='1'&stim&'0';
        wait for 1.2*cycUART;
        for i in 0 to 9 loop
            Rx<=test_data(i);
            wait for cycUART;
        end loop;
        wait for int_rand*10us;
    end loop;
    wait;
end process;
    
end Behavioral;
