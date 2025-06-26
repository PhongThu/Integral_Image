library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity counter_tb is
end entity;

architecture tb of counter_tb is
  constant DATA_WIDTH : integer := 4;
  constant CLK_PERIOD : time    := 10 ns;
  signal rst : std_logic                                 := '0';
  signal clk : std_logic                                 := '0';
  signal en  : std_logic                                 := '0';
  signal set : std_logic                                 := '0';
  signal d   : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  signal q   : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin
  dut: counter
    generic map (DATA_WIDTH => DATA_WIDTH)
    port map (
      rst => rst,
      clk => clk,
      en  => en,
      set => set,
      d   => d,
      q   => q
    );
  clk <= not clk after CLK_PERIOD / 2;

  process
  begin
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    en <= '1';
    wait for CLK_PERIOD * 10;

    en <= '0';
    wait for CLK_PERIOD * 10;

    set <= '1';
    d <= "0101";
    wait for CLK_PERIOD;
    set <= '0';

    en <= '1';
    wait for CLK_PERIOD * 10;

    wait;
  end process;
end architecture;
