library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity address_calc_tb is
end entity;

architecture behavior of address_calc_tb is
  constant INDEX_WIDTH     : integer := 16;
  constant ADDR_WIDTH      : integer := 32;
  constant DATA_BYTE_WIDTH : integer := 1;

  signal base_sel  : std_logic;
  signal r         : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal c         : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal col       : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal base_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal addr      : std_logic_vector(ADDR_WIDTH - 1 downto 0);
begin
  dut: address_calc
    generic map (
      INDEX_WIDTH     => INDEX_WIDTH,
      ADDR_WIDTH      => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      base_sel  => base_sel,
      r         => r,
      c         => c,
      col       => col,
      base_addr => base_addr,
      addr      => addr
    );

  process
  begin
    -- case 1: base_sel = '0', r = 0, c = 1, col = 4, base_addr = 10
    base_sel <= '0';
    r <= (others => '0');
    c <= std_logic_vector(to_unsigned(1, INDEX_WIDTH));
    col <= std_logic_vector(to_unsigned(4, INDEX_WIDTH));
    base_addr <= std_logic_vector(to_unsigned(10, ADDR_WIDTH));
    wait for 1 ns;
    assert addr = std_logic_vector(to_unsigned(10 + 0 * 4 + 1, ADDR_WIDTH))
      report "Case 1 failed"
      severity error;

    -- case 2: base_sel = '0', r = 1, c = 0, col = 4, base_addr = 10
    base_sel <= '0';
    r <= std_logic_vector(to_unsigned(1, INDEX_WIDTH));
    c <= (others => '0');
    col <= std_logic_vector(to_unsigned(4, INDEX_WIDTH));
    base_addr <= std_logic_vector(to_unsigned(10, ADDR_WIDTH));
    wait for 1 ns;
    assert addr = std_logic_vector(to_unsigned(10 + 1 * 4 + 0, ADDR_WIDTH))
      report "Case 2 failed"
      severity error;

    -- case 3: base_sel = '1', r = 2, c = 2, col = 5, base_addr = 20
    base_sel <= '1';
    r <= std_logic_vector(to_unsigned(2, INDEX_WIDTH));
    c <= std_logic_vector(to_unsigned(2, INDEX_WIDTH));
    col <= std_logic_vector(to_unsigned(5, INDEX_WIDTH));
    base_addr <= std_logic_vector(to_unsigned(20, ADDR_WIDTH));
    wait for 1 ns;
    assert addr = std_logic_vector(to_unsigned(20 + 2 * (5 + 1) + 2, ADDR_WIDTH))
      report "Case 3 failed"
      severity error;

    wait;
  end process;
end architecture;
