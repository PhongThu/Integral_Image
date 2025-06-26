library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity memory is
  generic (
    ADDR_WIDTH      : integer;
    DATA_BYTE_WIDTH : integer
  );
  port (
    clk   : in  std_logic;
    r_en  : in  std_logic;
    w_en  : in  std_logic;
    addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    d_in  : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    d_out : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
  );
end entity;

architecture mock_1kb of memory is
  constant MEM_BYTE_SIZE : integer := 2 ** 10; -- 1 KB
  type mem_array is array (0 to MEM_BYTE_SIZE - 1) of std_logic_vector(7 downto 0);
  signal mem : mem_array;
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if w_en = '1' then
        for i in 0 to DATA_BYTE_WIDTH - 1 loop
          mem(to_integer(unsigned(addr)) + i) <= d_in(8 * (i + 1) - 1 downto 8 * i);
        end loop;
        d_out <= (others => '0');
      elsif r_en = '1' then
        for i in 0 to DATA_BYTE_WIDTH - 1 loop
          d_out(8 * (i + 1) - 1 downto 8 * i) <= mem(to_integer(unsigned(addr)) + i) after 1 ns;
        end loop;
      end if;
    end if;
  end process;
end architecture;