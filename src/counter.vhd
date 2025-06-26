library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity counter is
  generic (DATA_WIDTH : integer);
  port (
    rst : in  std_logic;
    clk : in  std_logic;
    en  : in  std_logic;
    set : in  std_logic;
    d   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
    q   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of counter is
  signal q_tmp : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
begin
  q <= q_tmp;

  process (rst, clk)
  begin
    if rst = '1' then
      q_tmp <= (others => '0');
    elsif rising_edge(clk) then
      if set = '1' then
        q_tmp <= d;
      elsif en = '1' then
        q_tmp <= std_logic_vector(unsigned(q_tmp) + 1);
      end if;
    end if;
  end process;
end architecture;
