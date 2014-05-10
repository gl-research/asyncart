library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity asyncart_demo is
    port (
        BTNC : in std_logic;
        BTND : in std_logic;
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


  component asyncart_reg is
     port (
        fire_out : out std_logic;
        phase_out : out std_logic;
        phase_in_pos : in std_logic;
        phase_in_neg : in std_logic;
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


-- PIPELINE_DEPTH must be > 2
constant PIPE_DEPTH : integer := 4096;

signal rst, act: std_logic;

type array_data is array (0 to PIPE_DEPTH-1) of std_logic_vector(31 downto 0); 
signal data, data_next : array_data;

type array_control is array (0 to PIPE_DEPTH-1) of std_logic;
signal phase, clk : array_control;


-- Begin Architecture
begin


LD0 <= data(PIPE_DEPTH-1)(24);
LD1 <= data(PIPE_DEPTH-1)(25);
LD2 <= data(PIPE_DEPTH-1)(26);
LD3 <= data(PIPE_DEPTH-1)(27);
LD4 <= data(PIPE_DEPTH-1)(28);
LD5 <= data(PIPE_DEPTH-1)(29);
LD6 <= data(PIPE_DEPTH-1)(30);
LD7 <= data(PIPE_DEPTH-1)(31);

rst <= BTND;
act <= BTNC;

----------------------------------
-- Micropipeline description    --
----------------------------------

  GEN_PIPE: for i in 0 to PIPE_DEPTH-1 generate


  -- x PIPE_DEPTH Asynchronous control pipeline elements

  SOURCE_STAGE: if (i = 0) generate
  source_i: asyncart_source
     port map (
        fire_out => clk(i),
        phase_out => phase(i),
        phase_in_neg => phase(i+1), 
        act => act, 
        rst => rst 
    );
  end generate SOURCE_STAGE;
  
  REG_STAGE: if ((i > 0) and (i < PIPE_DEPTH-1)) generate
  reg_i: asyncart_reg
     port map (
        fire_out => clk(i),
        phase_out => phase(i),
        phase_in_pos => phase(i-1),
        phase_in_neg => phase(i+1),
        act => act,
        rst => rst
    );
  end generate REG_STAGE;

  SINK_STAGE: if (i = PIPE_DEPTH-1) generate
  sink_i: asyncart_sink
     port map (
        fire_out => clk(i),
        phase_out => phase(i),
        phase_in_pos => phase(i-1), 
        act => act, 
        rst => rst 
    );
  end generate SINK_STAGE;


  -- x PIPE_DEPTH sequential data register pipeline elements

  DATA_REG: process (rst, clk(i))
  begin
      if (rst = '1') then
          data(i) <=  (others => '0');
      else
          if (clk(i)'event and clk(i) = '1') then
              data(i) <=  data_next(i);
          end if;
      end if;
  end process DATA_REG;


  -- x PIPE_DEPTH datapath functions pipeline elements

  COUNTER_FUNCTION: if (i = 0) generate
    data_next(0) <= data(0)+1;
  end generate COUNTER_FUNCTION;

  MOVE_FUNCTION: if (i > 0) generate
    data_next(i) <= data(i-1);
  end generate MOVE_FUNCTION;


  end generate GEN_PIPE;

end demo_hw;

