library ieee;
  use work.project.all;
  use ieee.std_logic_1164.all;

entity reg is
  generic (DATA_BYTE_WIDTH : integer);
  port (
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    d   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    q   : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of reg is
begin
  process (rst, clk)
  begin
    if rst = '1' then
      q <= (others => '0');
    elsif rising_edge(clk) then
      if en = '1' then
        q <= d;
      end if;
    end if;
  end process;
end architecture;
