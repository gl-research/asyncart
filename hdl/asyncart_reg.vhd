library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity asyncart_reg is
    port (
        fire_out : out std_logic;
        phase_out : out std_logic;
        phase_in_pos : in std_logic;
        phase_in_neg : in std_logic;
        act : in std_logic;
        rst : in std_logic);
end entity;

architecture design of asyncart_reg is

signal fire, phase, phase_next : std_logic;

begin

    reg_fifo: process (rst, fire)
    begin
        if (rst = '1') then
            phase <=  '0';
        else
            if (fire'event and fire = '1') then
                phase <=  phase_next;
            end if;
        end if;
    end process reg_fifo;

    fire <= (phase_in_pos xor phase) and (phase_in_neg xnor phase) and act;
    phase_next <= not phase;
    phase_out <= phase;
    fire_out <= fire;

end design;

