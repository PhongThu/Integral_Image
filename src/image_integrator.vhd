library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

entity image_integrator is
  generic (
    ADDR_WIDTH      : integer := 32;
    INDEX_WIDTH     : integer := 16;
    DATA_BYTE_WIDTH : integer := 1
  );
  port (
    -- reset and clock
    rst        : in  std_logic;
    clk        : in  std_logic;
    -- user
    start      : in  std_logic;
    src_addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    dst_addr   : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
    src_col    : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    src_row    : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
    size_error : out std_logic;
    done       : out std_logic;
    -- memory
    r_en       : out std_logic;
    w_en       : out std_logic;
    d_out      : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
    addr       : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
    d_in       : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
  );
end entity;

architecture rtl of image_integrator is
  signal r_le_src_row : std_logic := '0';
  signal c_le_src_col : std_logic := '0';

  signal r_cnt_set : std_logic                    := '0';
  signal r_cnt_en  : std_logic                    := '0';
  signal r_cnt_val : std_logic                    := '0';
  signal c_cnt_set : std_logic                    := '0';
  signal c_cnt_en  : std_logic                    := '0';
  signal c_cnt_val : std_logic                    := '0';
  signal r_sel     : std_logic_vector(1 downto 0) := (others => '0');
  signal c_sel     : std_logic_vector(1 downto 0) := (others => '0');
  signal base_sel  : std_logic                    := '0';
  signal d_sel     : std_logic                    := '0';
  signal alu_sel   : std_logic                    := '0';
  signal pixel_rst : std_logic                    := '0';

  signal size_error_internal : std_logic := '0';
begin
  size_error <= size_error_internal;

  data_path_block: data_path
    generic map (
      INDEX_WIDTH     => INDEX_WIDTH,
      ADDR_WIDTH      => ADDR_WIDTH,
      DATA_BYTE_WIDTH => DATA_BYTE_WIDTH
    )
    port map (
      rst          => rst,
      clk          => clk,
      src_addr     => src_addr,
      dst_addr     => dst_addr,
      src_col      => src_col,
      src_row      => src_row,
      size_error   => size_error_internal,
      d_out        => d_out,
      addr         => addr,
      d_in         => d_in,
      r_cnt_set    => r_cnt_set,
      r_cnt_en     => r_cnt_en,
      r_cnt_val    => r_cnt_val,
      c_cnt_set    => c_cnt_set,
      c_cnt_en     => c_cnt_en,
      c_cnt_val    => c_cnt_val,
      base_sel     => base_sel,
      r_sel        => r_sel,
      c_sel        => c_sel,
      alu_sel      => alu_sel,
      d_sel        => d_sel,
      pixel_rst    => pixel_rst,
      r_le_src_row => r_le_src_row,
      c_le_src_col => c_le_src_col
    );

  controller_block: controller
    port map (
      rst          => rst,
      clk          => clk,
      start        => start,
      size_error   => size_error_internal,
      r_le_src_row => r_le_src_row,
      c_le_src_col => c_le_src_col,
      done         => done,
      r_cnt_set    => r_cnt_set,
      r_cnt_en     => r_cnt_en,
      r_cnt_val    => r_cnt_val,
      c_cnt_set    => c_cnt_set,
      c_cnt_en     => c_cnt_en,
      c_cnt_val    => c_cnt_val,
      r_sel        => r_sel,
      c_sel        => c_sel,
      base_sel     => base_sel,
      d_sel        => d_sel,
      alu_sel      => alu_sel,
      pixel_rst    => pixel_rst,
      r_en         => r_en,
      w_en         => w_en
    );
end architecture;
