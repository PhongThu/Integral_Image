library ieee;
  use ieee.std_logic_1164.all;

package project is
  constant ADDR_WIDTH      : integer := 32;
  constant INDEX_WIDTH     : integer := 16;
  constant DATA_BYTE_WIDTH : integer := 1;
  component reg is
    generic (DATA_BYTE_WIDTH : integer);
    port (
      rst : in  std_logic;
      clk : in  std_logic;
      en  : in  std_logic;
      d   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
      q   : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
    );
  end component;

  component counter is
    generic (DATA_WIDTH : integer);
    port (
      rst : in  std_logic;
      clk : in  std_logic;
      en  : in  std_logic;
      set : in  std_logic;
      d   : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
      q   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
  end component;

  component address_calc is
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
  end component;

  component alu is
    generic (DATA_BYTE_WIDTH : integer);
    port (
      sel : in  std_logic;
      a   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
      b   : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
      z   : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0)
    );
  end component;

  component data_path is
    generic (
      INDEX_WIDTH     : integer;
      ADDR_WIDTH      : integer;
      DATA_BYTE_WIDTH : integer
    );
    port (
      -- reset and clock
      rst          : in  std_logic;
      clk          : in  std_logic;
      -- user
      src_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      dst_addr     : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
      src_col      : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
      src_row      : in  std_logic_vector(INDEX_WIDTH - 1 downto 0);
      size_error   : out std_logic;
      -- memory
      d_out        : in  std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
      addr         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      d_in         : out std_logic_vector(8 * DATA_BYTE_WIDTH - 1 downto 0);
      -- controller
      r_cnt_set    : in  std_logic;
      r_cnt_en     : in  std_logic;
      r_cnt_val    : in  std_logic;
      c_cnt_set    : in  std_logic;
      c_cnt_en     : in  std_logic;
      c_cnt_val    : in  std_logic;
      base_sel     : in  std_logic;
      r_sel        : in  std_logic_vector(1 downto 0);
      c_sel        : in  std_logic_vector(1 downto 0);
      alu_sel      : in  std_logic;
      d_sel        : in  std_logic;
      pixel_rst    : in  std_logic;
      r_le_src_row : out std_logic;
      c_le_src_col : out std_logic
    );
  end component;

  component memory is
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
  end component;

  component controller is
    port (
      rst          : in  std_logic;
      clk          : in  std_logic;

      start        : in  std_logic;
      size_error   : in  std_logic;
      r_le_src_row : in  std_logic;
      c_le_src_col : in  std_logic;

      done         : out std_logic;
      r_cnt_set    : out std_logic;
      r_cnt_en     : out std_logic;
      r_cnt_val    : out std_logic;
      c_cnt_set    : out std_logic;
      c_cnt_en     : out std_logic;
      c_cnt_val    : out std_logic;
      r_sel        : out std_logic_vector(1 downto 0);
      c_sel        : out std_logic_vector(1 downto 0);
      base_sel     : out std_logic;
      d_sel        : out std_logic;
      alu_sel      : out std_logic;
      pixel_rst    : out std_logic;
      r_en         : out std_logic;
      w_en         : out std_logic
    );
  end component;

  component image_integrator is
    -- generic (
    --   ADDR_WIDTH      : integer;
    --   INDEX_WIDTH     : integer;
    --   DATA_BYTE_WIDTH : integer
    -- );
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
  end component;

end package;
