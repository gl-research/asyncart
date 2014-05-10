library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity asyncart_delay is
    port (
        data_out : out std_logic;
        data_in : in std_logic;
        act : in std_logic;
        rst : in std_logic);
end entity;

architecture design of asyncart_delay is

begin 
    process (rst, data_in, act)  
      begin  
        if (rst='1') then 
          data_out <= '0';  
        elsif (act='1') then  
          data_out <= data_in;  
        end if;  
    end process;  

end design;

