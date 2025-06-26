library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity alu is
  generic (DATA_BYTE_WIDTH : integer);
  port (
    sel : in  std_logic;
    a   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    b   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    z   : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of alu is
begin
  process (sel, a, b)
  begin
    if sel = '0' then
      z <= std_logic_vector(unsigned(a) + unsigned(b));
    else
      z <= std_logic_vector(unsigned(a) - unsigned(b));
    end if;
  end process;
end architecture;
