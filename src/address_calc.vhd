library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity address_calc is
  generic (
    INDEX_WIDTH     : integer;
    ADDR_WIDTH      : integer;
    DATA_BYTE_WIDTH : integer
  );
  port (
    base_sel  : in  std_logic;
    r         : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    c         : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    col       : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    base_addr : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    addr      : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of address_calc is
  signal col_final  : std_logic_vector(INDEX_WIDTH - 1 downto 0);
  signal row_offset : std_logic_vector(base_addr'length - 1 downto 0);
  signal col_offset : std_logic_vector(base_addr'length - 1 downto 0);
begin
  col_final <= col when base_sel = '0' else std_logic_vector(unsigned(col) + 1);
  row_offset <= std_logic_vector(
    resize(
      DATA_BYTE_WIDTH * resize(unsigned(r), base_addr'length) * resize(unsigned(col_final), base_addr'length),
      base_addr'length
    )
  );
  col_offset <= std_logic_vector(
    resize(
      DATA_BYTE_WIDTH * resize(unsigned(c), base_addr'length),
      base_addr'length
    )
  );
  addr <= std_logic_vector(unsigned(base_addr) + unsigned(row_offset) + unsigned(col_offset));
end architecture;
