library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity image_integrator_tb is
end entity;

architecture behavior of image_integrator_tb is
  constant ADDR_WIDTH      : integer := 32;
  constant INDEX_WIDTH     : integer := 16;
  constant DATA_BYTE_WIDTH : integer := 1;

  signal rst : std_logic := '0';
  signal clk : std_logic := '1';

  signal start      : std_logic                                  := '0';
  signal src_addr   : std_logic_vector(ADDR_WIDTH - 1 downto 0)  := (others => '0');
  signal dst_addr   : std_logic_vector(ADDR_WIDTH - 1 downto 0)  := (others => '0');
  signal src_col    : std_logic_vector(INDEX_WIDTH - 1 downto 0) := (others => '0');
  signal src_row    : std_logic_vector(INDEX_WIDTH - 1 downto 0) := (others => '0');
  signal size_error : std_logic                                  := '0';
  signal done       : std_logic                                  := '0';

  signal r_en  : std_logic                                          := '0';
  signal w_en  : std_logic                                          := '0';
  signal d_out : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0) := (others => '0');
  signal addr  : std_logic_vector(ADDR_WIDTH - 1 downto 0)          := (others => '0');
  signal d_in  : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0) := (others => '0');

  signal r_en_user : std_logic                                          := '0';
  signal w_en_user : std_logic                                          := '0';
  signal addr_user : std_logic_vector(ADDR_WIDTH - 1 downto 0)          := (others => '0');
  signal d_in_user : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0) := (others => '0');

  signal r_en_final : std_logic                                          := '0';
  signal w_en_final : std_logic                                          := '0';
  signal addr_final : std_logic_vector(ADDR_WIDTH - 1 downto 0)          := (others => '0');
  signal d_in_final : std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0) := (others => '0');

  signal mode_user : std_logic := '1';

  constant CLK_PERIOD : time := 10 ns;
begin
  r_en_final <= r_en_user when mode_user = '1' else r_en;
  w_en_final <= w_en_user when mode_user = '1' else w_en;
  addr_final <= addr_user when mode_user = '1' else addr;
  d_in_final <= d_in_user when mode_user = '1' else d_in;

  dut: image_integrator
    -- generic map (
    --   ADDR_WIDTH      => ADDR_WIDTH,
    --   INDEX_WIDTH     => INDEX_WIDTH,
    --   DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    -- )
    port map (
      rst        => rst,
      clk        => clk,
      start      => start,
      src_addr   => src_addr,
      dst_addr   => dst_addr,
      src_col    => src_col,
      src_row    => src_row,
      size_error => size_error,
      done       => done,
      r_en       => r_en,
      w_en       => w_en,
      d_out      => d_out,
      addr       => addr,
      d_in       => d_in
    );

  memory_instance: memory
    generic map (
      ADDR_WIDTH      => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      clk   => clk,
      r_en  => r_en_final,
      w_en  => w_en_final,
      addr  => addr_final,
      d_in  => d_in_final,
      d_out => d_out
    );

  clk <= not clk after CLK_PERIOD / 2;
  
  process
    constant TEST_SRC_ADDR : integer := 0;
    constant TEST_DST_ADDR : integer := 64;
    constant ROW           : integer := 6;
    constant COL           : integer := 6;
    constant MAX_ROW       : integer := 256;
    constant MAX_COL       : integer := 256;
    constant MIN_ROW       : integer := 5;
    constant MIN_COL       : integer := 5;
  begin

    -- Test case 1: All pixels = 1
    report "Test case 1: All pixels = 1";
    rst <= '1';
    start <= '0';
    wait for CLK_PERIOD;
    rst <= '0';

    -- Write source image with all pixels = 1
    mode_user <= '1';
    w_en_user <= '1';
    wait for CLK_PERIOD;
    for r in 0 to ROW - 1 loop
      for c in 0 to COL - 1 loop
        addr_user <= std_logic_vector(to_unsigned(TEST_SRC_ADDR + r * COL + c, ADDR_WIDTH));
        d_in_user <= std_logic_vector(to_unsigned(1, 8 * DATA_BYTE_WIDTH));
        wait for CLK_PERIOD;
      end loop;
    end loop;
    w_en_user <= '0';

    -- Set inputs
    src_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    dst_addr <= std_logic_vector(to_unsigned(TEST_DST_ADDR, ADDR_WIDTH));
    src_row <= std_logic_vector(to_unsigned(ROW, INDEX_WIDTH));
    src_col <= std_logic_vector(to_unsigned(COL, INDEX_WIDTH));

    -- Start
    wait for CLK_PERIOD;
    report "Start calculate";
    mode_user <= '0';
    start <= '1';
    wait until done = '1';
    report "Test case 1 is complete!";
    wait for CLK_PERIOD;

    -- Test case 2: All pixels = 255
    report "Test case 2: All pixels = 255";
    start <= '0';
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    -- Write source image 6x6 with all pixels = 255
    mode_user <= '1';
    w_en_user <= '1';
    wait for CLK_PERIOD;
    for r in 0 to ROW - 1 loop
      for c in 0 to COL - 1 loop
        addr_user <= std_logic_vector(to_unsigned(TEST_SRC_ADDR + r * COL + c, ADDR_WIDTH));
        d_in_user <= std_logic_vector(to_unsigned(255, 8 * DATA_BYTE_WIDTH));
        wait for CLK_PERIOD;
      end loop;
    end loop;
    w_en_user <= '0';

    -- Set inputs
    src_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    dst_addr <= std_logic_vector(to_unsigned(TEST_DST_ADDR, ADDR_WIDTH));
    src_row <= std_logic_vector(to_unsigned(ROW, INDEX_WIDTH));
    src_col <= std_logic_vector(to_unsigned(COL, INDEX_WIDTH));

    -- Start
    wait for CLK_PERIOD;
    report "Start calculate";
    mode_user <= '0';
    start <= '1';
    wait until done = '1';
    report "Test case 2 is complete!";
    wait for CLK_PERIOD;

    -- Test case 3: Invalid row and column values
    report "Test case 3: Invalid row and column values";
    rst <= '1';
    start <= '0';
    wait for CLK_PERIOD;
    rst <= '0';

    -- Set input
    src_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    dst_addr <= std_logic_vector(to_unsigned(TEST_DST_ADDR, ADDR_WIDTH));
    src_row <= std_logic_vector(to_unsigned(MAX_ROW + 1, INDEX_WIDTH)); -- ROW = 256
    src_col <= std_logic_vector(to_unsigned(MIN_COL, INDEX_WIDTH)); -- COL = 6

    -- Start
    wait for CLK_PERIOD;
    report "Start calculate";
    mode_user <= '0';
    start <= '1';
    wait until done = '1';
    assert size_error = '1'
      report "Test case 3: Size error should be set"
      severity failure;
    report "Test case 3 is complete!";
    wait for CLK_PERIOD;

    -- Test case 4: Image 5x10 with all pixel = 1
    report "Test case 4: Image 5x10 with all pixel = 1";
    start <= '0';
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    -- write source image
    mode_user <= '1';
    w_en_user <= '1';
    wait for CLK_PERIOD;
    for r in 0 to 4 loop
      for c in 0 to 9 loop
        addr_user <= std_logic_vector(to_unsigned(TEST_SRC_ADDR + r * 10 + c, ADDR_WIDTH));
        d_in_user <= std_logic_vector(to_unsigned(1, 8 * DATA_BYTE_WIDTH));
        wait for CLK_PERIOD;
      end loop;
    end loop;
    w_en_user <= '0';

    -- Set inputs
    src_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    dst_addr <= std_logic_vector(to_unsigned(TEST_DST_ADDR, ADDR_WIDTH));
    src_row <= std_logic_vector(to_unsigned(5, INDEX_WIDTH)); -- ROW = 5
    src_col <= std_logic_vector(to_unsigned(10, INDEX_WIDTH)); -- COL = 10

    -- Start
    wait for CLK_PERIOD;
    report "Start calculate";
    mode_user <= '0';
    start <= '1';
    wait until done = '1';
    report "Test case 4 is complete!";
    wait for CLK_PERIOD;

    -- Test case 5: SRC_ADDR == DST_ADDR
    report "Test case 5: SRC_ADDR == DST_ADDR";
    start <= '0';
    rst <= '1';
    wait for CLK_PERIOD;
    rst <= '0';

    -- Write source image
    mode_user <= '1';
    w_en_user <= '1';
    wait for CLK_PERIOD;

    -- Write source image with all pixel = 1
    mode_user <= '1';
    w_en_user <= '1';
    wait for CLK_PERIOD;
    for r in 0 to ROW - 1 loop
      for c in 0 to COL - 1 loop
        addr_user <= std_logic_vector(to_unsigned(TEST_SRC_ADDR + r * COL + c, ADDR_WIDTH));
        d_in_user <= std_logic_vector(to_unsigned(1, 8 * DATA_BYTE_WIDTH));
        wait for CLK_PERIOD;
      end loop;
    end loop;
    w_en_user <= '0';

    -- Set inputs
    src_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    dst_addr <= std_logic_vector(to_unsigned(TEST_SRC_ADDR, ADDR_WIDTH));
    src_row <= std_logic_vector(to_unsigned(ROW, INDEX_WIDTH));
    src_col <= std_logic_vector(to_unsigned(COL, INDEX_WIDTH));

    -- Start
    wait for CLK_PERIOD;
    report "Start calculate";
    mode_user <= '0';
    start <= '1';
    wait until done = '1';
    report "Test case 5 is complete!";
    wait for CLK_PERIOD;

    -- Test case 6: 
    wait;
  end process;

end architecture;
