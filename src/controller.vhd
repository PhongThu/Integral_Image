library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.project.all;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity controller is
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
end entity;

architecture behavior of controller is
  type state_t is (
      S0, S1, S2, S3, S4, S5, S6, S7,
      S8, S9, S10, S11, S12, S13, S14,
      S15, S16, S17, S18, S19, S20, S21
    );

  signal state : state_t := S0;
  signal done_tmp : std_logic_vector(7 downto 0);
  signal done_out: std_logic_vector(7 downto 0);
begin
  state_control: process (rst, clk)
  begin
    if rst = '1' then
      state <= S0;
    elsif rising_edge(clk) then
      case state is
        -- Reset, clear regs
        when S0 => state <= S1;
        -- Wait for start
        when S1 =>
          if start = '1' then
            state <= S2;
          end if;
        -- Check image size
        when S2 =>
          if size_error = '0' then
            state <= S3;
          else
            state <= S21;
          end if;
        -- Set r
        when S3 => state <= S4;
        -- loop1: r in [0, src_row]
        when S4 =>
          if r_le_src_row = '1' then
            state <= S5;
          else
            state <= S6;
          end if;
        -- dst_addr[r][0] = 0
        when S5 => state <= S4;
        -- Set c
        when S6 => state <= S7;

        -- loop2: c in [1, src_col]
        when S7 =>
          if c_le_src_col = '1' then
            state <= S8;
          else
            state <= S9;
          end if;
        -- dst_addr[0][c] = 0
        when S8 => state <= S7;

        -- Set r = 1
        when S9 => state <= S10;

        -- loop3: r in [1, src_row]
        when S10 =>
          if r_le_src_row = '1' then
            state <= S11;
          else
            state <= S21;
          end if;
        -- Set c = 1
        when S11 => state <= S12;
        -- loop4: c in [1, src_col]
        when S12 =>
          if c_le_src_col = '1' then
            state <= S13;
          else
            state <= S19;
          end if;
        -- Read dst_addr[r-1][c]
        when S13 => state <= S14;
        -- Read dst_addr[r-1][c-1]; pixel = dst_addr[r-1][c]
        when S14 => state <= S15;
        -- Read dst_addr[r][c-1]; pixel = pixel - dst_addr[r-1][c-1]
        when S15 => state <= S16;
        -- Read src_addr[r-1][c-1]; pixel = pixel + dst_addr[r][c-1]
        when S16 => state <= S17;
        -- pixel = pixel + src_addr[r-1][c-1]
        when S17 => state <= S18;
        -- Write pixel to memory; c++
        when S18 => state <= S12;
        -- r++
        when S19 => state <= S10;

        -- done = '1'
        when S20 => state <= S21;
        -- wait for user to clear start
        when S21 =>
          if start = '0' then
            state <= S1;
          end if;
        when others =>
      end case;
    end if;
  end process;

  -- Combinational Logic
  with state select r_cnt_set <=
    '1' when S3 | S9,
    '0' when others;

  with state select r_cnt_val <=
    '1' when S9,
    '0' when others;

  with state select r_cnt_en <=
    '1' when S5 | S19,
    '0' when others;

  with state select c_cnt_set <=
    '1' when S6 | S11,
    '0' when others;

  with state select c_cnt_val <=
    '1' when S6 | S11,
    '0' when others;

  with state select c_cnt_en <=
    '1' when S8 | S18,
    '0' when others;

  with state select base_sel <=
    '1' when S5 | S8 | S13 | S14 | S15 | S18,
    '0' when others;

  with state select r_sel <=
    "01" when S5 | S15 | S18,
    "10" when S13 | S14 | S16,
    "00" when others;

  with state select c_sel <=
    "01" when S8 | S13 | S18,
    "10" when S14 | S15 | S16,
    "00" when others;

  with state select r_en <=
    '1' when S13 | S14 | S15 | S16,
    '0' when others;

  with state select w_en <=
    '1' when S5 | S8 | S18,
    '0' when others;

  with state select d_sel <=
    '1' when S5 | S8,
    '0' when others;

  with state select pixel_rst <=
    '1' when S13,
    '0' when others;

  with state select alu_sel <=
    '1' when S15,
    '0' when others;

  with state select done_tmp <=
    (0 => '1', others => '0') when S20 | S21,
    (others => '0') when others;

  done_reg : reg
    generic map (DATA_BYTE_WIDTH => 1)
    port map (
      rst => rst,
      clk => clk,
      en  => '1',
      d   => done_tmp,
      q   => done_out
    );
  done <= done_out(0);

end architecture;