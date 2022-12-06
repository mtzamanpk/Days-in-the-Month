library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
entity mydecoder is
    Port ( clock : in STD_LOGIC;-- clock 
           reset : in STD_LOGIC; -- reset
           leap_year: in STD_LOGIC; -- leap year 
           Anode_Activate : out STD_LOGIC_VECTOR (3 downto 0);-- 4 Anode signals
           LED_out : out STD_LOGIC_VECTOR (6 downto 0);-- Cathode patterns of 7-segment display
           birthday : out STD_LOGIC_VECTOR (15 downto 0));-- switch LEDs that will light up on birthday month
end mydecoder;

architecture Behavioral of mydecoder is
signal month: std_logic_vector (3 downto 0) := "0000";
signal increment_counter: STD_LOGIC_VECTOR (25 downto 0);
-- counter for generating incrementing clock enable
signal increment_enable: std_logic;
-- one second enable for counting numbers
signal displayed_number: STD_LOGIC_VECTOR (11 downto 0);
-- counting decimal number to be displayed on 4-digit 7-segment display
signal LED: STD_LOGIC_VECTOR (3 downto 0);
 -- controls the 4 anodes on the board
signal refresh_counter: STD_LOGIC_VECTOR (25 downto 0);
-- creating refresh period
signal LED_activating_counter: std_logic_vector(1 downto 0);
-- activates t he LED
begin
-- Cathode patterns of the 7 segment display
process(LED)
begin
    case LED is
    when "0000" => LED_out <= "0000001"; -- "0"     
    when "0001" => LED_out <= "1001111"; -- "1" 
    when "0010" => LED_out <= "0010010"; -- "2" 
    when "0011" => LED_out <= "0000110"; -- "3" 
    when "0100" => LED_out <= "1001100"; -- "4" 
    when "0101" => LED_out <= "0100100"; -- "5" 
    when "0110" => LED_out <= "0100000"; -- "6" 
    when "0111" => LED_out <= "0001111"; -- "7" 
    when "1000" => LED_out <= "0000000"; -- "8"     
    when "1001" => LED_out <= "0000100"; -- "9" 
    when "1010" => LED_out <= "0000010"; -- a
    when "1011" => LED_out <= "1100000"; -- b
    when "1100" => LED_out <= "0110001"; -- C
    when "1101" => LED_out <= "1000010"; -- d
    when "1110" => LED_out <= "0110000"; -- E
    when "1111" => LED_out <= "0111000"; -- F
    end case;
end process;
-- 7-segment display controller
-- generate refresh period of 10.5ms

process(clock, reset)
begin
        if(reset='1') then
            refresh_counter <= (others => '0');
        elsif(rising_edge(clock)) then
            if(refresh_counter ="11111111111111111111111111") then
                refresh_counter <= (others => '0'); --refresh counter has to be the same as increment counter because they
            else                                    --both need to show in sync, otherwise it wouldnt display properly
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
end process;

LED_activating_counter <= refresh_counter(19 downto 18);

process(LED_activating_counter)
begin
    case LED_activating_counter is
    when "00" =>
        Anode_Activate <= "0111"; 
        -- activate LED1 and Deactivate LED2, LED3, LED4
        LED <= displayed_number(11 downto 8);
        -- reads the first 4 bits 
    when "01" =>
        Anode_Activate <= "1011"; 
        -- activate LED2 and Deactivate LED1, LED3, LED4
        LED <= "0000";
        -- for this one, I just set it to 0 so that it doesnt change, I forgot to just turn it off
    when "10" =>
        Anode_Activate <= "1101"; 
        -- activate LED3 and Deactivate LED2, LED1, LED4
        LED <= displayed_number(7 downto 4);
        -- reads the middle 4 bits 
    when "11" =>
        Anode_Activate <= "1110"; 
        -- activate LED4 and Deactivate LED2, LED3, LED1
        LED <= displayed_number(3 downto 0);
        -- reads the final 4 bits   
    end case;
end process;
-- incrementing the number to be displayed on the anodes
process(clock, reset)
begin
        if(reset='1') then
            increment_counter <= (others => '0');
        elsif(rising_edge(clock)) then
            if(increment_counter ="11111111111111111111111111") then
                increment_counter <= (others => '0');
            else
                increment_counter <= increment_counter + 1;
            end if;
        end if;
end process;
increment_enable <= '1' when increment_counter="11111111111111111111111111" else '0'; -- making it process a big number, simulating a delay, before the next clock 
process(clock, reset)
begin
        if(reset='1') then
            Month <= (others => '0');
        elsif(rising_edge(clock)) then
             if(increment_enable='1') then
                Month <= Month + "0001";
                if(Month = "1011") then -- month increments all the way until december, then resets to 0
                Month <= "0000";
                end if;
             end if;
        end if;
end process;

process(clock, reset, leap_year)
begin
    if(reset='1') then
     displayed_number <= (others => '0');
    elsif(rising_edge(clock)) then     
        if (Month = "0000") then -- January 
          displayed_number <= "000100110001"; -- (1 3 1)
           birthday<= "0000000010000000"; 
        elsif (Month = "0001") then -- Febuary
            if(leap_year = '1')then --checks if leap year switch is on, if it is then sets to 29, if not then sets to 28
                displayed_number <= "001000101001"; -- (2 2 9)
                 birthday<= "0000000110000000"; 
            elsif(leap_year = '0')then
                displayed_number <= "001000101000"; -- (2 2 8)  
                 birthday<= "0000000110000000";
            end if;   
        elsif (Month = "0010") then -- March
          displayed_number <= "001100110001"; -- (3 3 1)
           birthday<= "0000000111000000";   --pattern for birthday, goes left right, left right, until we reach december where it resets
        elsif (Month = "0011") then  -- April
          displayed_number <= "010000110000"; -- (4 3 0)
           birthday<= "0000001111000000";
        elsif (Month = "0100") then  -- May
          displayed_number <= "010100110001"; -- (5 3 1)
           birthday<= "0000001111100000";
        elsif (Month = "0101") then  -- June
          displayed_number <= "011000110000"; -- (6 3 0)
           birthday<= "0000011111100000";
        elsif (Month = "0110") then -- July
          displayed_number <= "011100110001"; -- (7 3 1)
           birthday<= "0000011111110000";
        elsif (Month = "0111") then  -- August
          displayed_number <= "100000110001"; -- (8 3 1)
           birthday<= "0000111111110000";
        elsif (Month = "1000") then  -- September
          displayed_number <= "100100110000"; -- (9 3 0)
           birthday<= "0000111111111000";   
        elsif (Month = "1001") then  -- October
          displayed_number <= "101000110001"; -- (10 3 1)
          birthday<= "1111111111111111";    -- flashes all lights on my birthday month
        elsif (Month = "1010") then  -- November
          displayed_number <= "101100110000"; -- (11 3 0)
           birthday<= "0011111111111000";
        elsif (Month = "1011") then  -- December
          displayed_number <= "110000110001"; -- (12 3 1)           
           birthday<= "0011111111111100";      
        end if;
    end if;
end process;
end Behavioral;