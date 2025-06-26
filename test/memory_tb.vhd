library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity memory_tb is
end entity;

architecture behavior of memory_tb is
  constant ADDR_WIDTH      : integer := 32;
  constant DATA_BYTE_WIDTH : integer := 1;
  constant CLK_PERIOD      : time    := 10 ns;

  signal clk   : std_logic := '0';
  signal r_en  : std_logic;
  signal w_en  : std_logic;
  signal addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal d_in  : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
  signal d_out : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
begin
  dut: memory
    generic map (
      ADDR_WIDTH      => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      clk   => clk,
      r_en  => r_en,
      w_en  => w_en,
      addr  => addr,
      d_in  => d_in,
      d_out => d_out
    );

  process
  begin
    -- Test case 1: Write and read back a value
    w_en <= '1';
    r_en <= '0';
    addr <= std_logic_vector(to_unsigned(20, ADDR_WIDTH));
    d_in <= std_logic_vector(to_unsigned(42, 8 * DATA_BYTE_WIDTH));

    clk <= '1';
    wait for CLK_PERIOD / 2;
    clk <= '0';
    wait for CLK_PERIOD / 2;

    w_en <= '0';
    r_en <= '1';
    addr <= std_logic_vector(to_unsigned(20, ADDR_WIDTH));
    clk <= '1';
    wait for CLK_PERIOD / 2;
    clk <= '0';
    wait for CLK_PERIOD / 2;
    assert d_out = d_in
      report "Test case 1 failed"
      severity error;

    wait;
  end process;

end architecture;
