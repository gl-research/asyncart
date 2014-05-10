library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity asyncart_demo is
    port (
        --GCLK : in std_logic; -- 100 MHz input clock
        BTNC : in std_logic; -- 100 MHz input clock
        BTND : in std_logic; -- 100 MHz input clock
        --OTG-RESETN : in std_logic;
        LD0 : out std_logic;
        LD1 : out std_logic;
        LD2 : out std_logic;
        LD3 : out std_logic;
        LD4 : out std_logic;
        LD5 : out std_logic;
        LD6 : out std_logic;
        LD7 : out std_logic
    );
end entity;

architecture demo_hw of asyncart_demo is


  component asyncart_source
     port (
        fire_out : out std_logic;
        phase_out : out std_logic;
        phase_in_neg : in std_logic;
        act : in std_logic;
        rst : in std_logic);
  end component;

  component asyncart_delay
     port (
        data_out : out std_logic;
        data_in : in std_logic;
        act : in std_logic;
        rst : in std_logic);
  end component;

  component asyncart_sink
     port (
        fire_out : out std_logic;
        phase_out : out std_logic;
        phase_in_pos : in std_logic;
        act : in std_logic; 
        rst : in std_logic);
  end component;


signal clk_source, clk_sink, rst, act: std_logic;
signal fire_source, phase_source, phase_source_delayed: std_logic;
signal fire_sink, phase_sink: std_logic;
signal counter_source, counter_source_next: std_logic_vector(31 downto 0);
signal counter_sink, counter_sink_next: std_logic_vector(31 downto 0);

-- Begin Architecture
begin


LD0 <= counter_sink(24);
LD1 <= counter_sink(25);
LD2 <= counter_sink(26);
LD3 <= counter_sink(27);
LD4 <= counter_sink(28);
LD5 <= counter_sink(29);
LD6 <= counter_sink(30);
LD7 <= counter_sink(31);

rst <= BTND;
act <= BTNC;

----------------------------------
-- Sequential logic description --
----------------------------------


  n1: asyncart_source
     port map (
        fire_out => clk_source,
        phase_out => phase_source,
        phase_in_neg => phase_sink, 
        act => act, 
        rst => rst 
    );

  n2: asyncart_delay
     port map (
        data_out => phase_source_delayed,
        data_in => phase_source, 
        act => act, 
        rst => rst 
    );

  n3: asyncart_sink
     port map (
        fire_out => clk_sink,
        phase_out => phase_sink,
        phase_in_pos => phase_source_delayed, 
        act => act, 
        rst => rst 
    );



    seq_source: process (rst, clk_source)
    begin
        if (rst = '1') then
            counter_source <=  (others => '0');
        else
            if (clk_source'event and clk_source = '1') then
                counter_source <=  counter_source_next;
            end if;
        end if;
    end process seq_source;

    counter_source_next <= counter_source + 1;

    seq_sink: process (rst, clk_sink)
    begin
        if (rst = '1') then
            counter_sink <=  (others => '0');
        else
            if (clk_sink'event and clk_sink = '1') then
                counter_sink <=  counter_sink_next;
            end if;
        end if;
    end process seq_sink;

    counter_sink_next <= counter_source;


end demo_hw;
