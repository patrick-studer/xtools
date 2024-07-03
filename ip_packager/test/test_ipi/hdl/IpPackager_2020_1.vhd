---------------------------------------------------------------------------------------------------
-- Copyright (c) 2022 by XTools, Switzerland
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Libraries
---------------------------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

library work;

---------------------------------------------------------------------------------------------------
-- Entity Declaration
---------------------------------------------------------------------------------------------------
entity IpPackager_2020_1 is
    generic(
        Clk_FreqHz_g                    : positive;
        M_Axi_DataWidth_g               : positive;
        M_Axi_AddrWidth_g               : positive;
        S_Axi_DataWidth_g               : positive;
        S_Axi_AddrWidth_g               : positive;
        M_Axis_TDataWidth_g             : natural;
        M_Axis_TUserWidth_g             : natural;
        S_Axis_TDataWidth_g             : natural;
        S_Axis_TUserWidth_g             : natural
    );
    port(
        -------------------------------------------------------------------------------------------
        -- Clock and Reset
        -------------------------------------------------------------------------------------------
        Clk             : in  std_logic;
        Rst             : in  std_logic;

        Axi_Clk         : in  std_logic;
        Axi_ResetN      : in  std_logic;

        Axis_Clk        : in  std_logic;
        Axis_ResetN     : in  std_logic;

        -------------------------------------------------------------------------------------------
        -- Interrupt [Clk]
        -------------------------------------------------------------------------------------------
        Interrupt       : out std_logic;

        -------------------------------------------------------------------------------------------
        -- UART [Clk]
        -------------------------------------------------------------------------------------------
        Uart_Tx         : out std_logic;
        Uart_Rx         : in  std_logic;

        -------------------------------------------------------------------------------------------
        -- AXI Master Interface [Axi_Clk]
        -------------------------------------------------------------------------------------------
        -- AXI Write Address Channel
        M_Axi_AwAddr    : out std_logic_vector(M_Axi_AddrWidth_g-1 downto 0);
        M_Axi_AwLen     : out std_logic_vector(7 downto 0);
        M_Axi_AwSize    : out std_logic_vector(2 downto 0);
        M_Axi_AwBurst   : out std_logic_vector(1 downto 0);
        M_Axi_AwLock    : out std_logic;
        M_Axi_AwCache   : out std_logic_vector(3 downto 0);
        M_Axi_AwProt    : out std_logic_vector(2 downto 0);
        M_Axi_AwValid   : out std_logic;
        M_Axi_AwReady   : in  std_logic;
        -- AXI Write Data Channel
        M_Axi_WData     : out std_logic_vector(M_Axi_DataWidth_g-1 downto 0);
        M_Axi_WStrb     : out std_logic_vector(M_Axi_DataWidth_g/8-1 downto 0);
        M_Axi_WLast     : out std_logic;
        M_Axi_WValid    : out std_logic;
        M_Axi_WReady    : in  std_logic;
        -- AXI Write Response Channel
        M_Axi_BResp     : in  std_logic_vector(1 downto 0);
        M_Axi_BValid    : in  std_logic;
        M_Axi_BReady    : out std_logic;
        -- AXI Read Address Channel
        M_Axi_ArAddr    : out std_logic_vector(M_Axi_AddrWidth_g-1 downto 0);
        M_Axi_ArLen     : out std_logic_vector(7 downto 0);
        M_Axi_ArSize    : out std_logic_vector(2 downto 0);
        M_Axi_ArBurst   : out std_logic_vector(1 downto 0);
        M_Axi_ArLock    : out std_logic;
        M_Axi_ArCache   : out std_logic_vector(3 downto 0);
        M_Axi_ArProt    : out std_logic_vector(2 downto 0);
        M_Axi_ArValid   : out std_logic;
        M_Axi_ArReady   : in  std_logic;
        -- AXI Read Data Channel
        M_Axi_RData     : in  std_logic_vector(M_Axi_DataWidth_g-1 downto 0);
        M_Axi_RResp     : in  std_logic_vector(1 downto 0);
        M_Axi_RLast     : in  std_logic;
        M_Axi_RValid    : in  std_logic;
        M_Axi_RReady    : out std_logic;

        -------------------------------------------------------------------------------------------
        -- AXI Slave Interface [Axi_Clk]
        -------------------------------------------------------------------------------------------
        -- AXI Write Address Channel
        S_Axi_AwAddr    : in  std_logic_vector(S_Axi_AddrWidth_g-1 downto 0);
        S_Axi_AwLen     : in  std_logic_vector(7 downto 0);
        S_Axi_AwSize    : in  std_logic_vector(2 downto 0);
        S_Axi_AwBurst   : in  std_logic_vector(1 downto 0);
        S_Axi_AwLock    : in  std_logic;
        S_Axi_AwCache   : in  std_logic_vector(3 downto 0);
        S_Axi_AwProt    : in  std_logic_vector(2 downto 0);
        S_Axi_AwValid   : in  std_logic;
        S_Axi_AwReady   : out std_logic;

        -- AXI Write Data Channel
        S_Axi_WData     : in  std_logic_vector(S_Axi_DataWidth_g-1 downto 0);
        S_Axi_WStrb     : in  std_logic_vector(S_Axi_DataWidth_g/8-1 downto 0);
        S_Axi_WLast     : in  std_logic;
        S_Axi_WValid    : in  std_logic;
        S_Axi_WReady    : out std_logic;

        -- AXI Write Response Channel
        S_Axi_BResp     : out std_logic_vector(1 downto 0);
        S_Axi_BValid    : out std_logic;
        S_Axi_BReady    : in  std_logic;

        -- AXI Read Address Channel
        S_Axi_ArAddr    : in  std_logic_vector(S_Axi_AddrWidth_g-1 downto 0);
        S_Axi_ArLen     : in  std_logic_vector(7 downto 0);
        S_Axi_ArSize    : in  std_logic_vector(2 downto 0);
        S_Axi_ArBurst   : in  std_logic_vector(1 downto 0);
        S_Axi_ArLock    : in  std_logic;
        S_Axi_ArCache   : in  std_logic_vector(3 downto 0);
        S_Axi_ArProt    : in  std_logic_vector(2 downto 0);
        S_Axi_ArValid   : in  std_logic;
        S_Axi_ArReady   : out std_logic;

        -- AXI Read Data Channel
        S_Axi_RData     : out std_logic_vector(S_Axi_DataWidth_g-1 downto 0);
        S_Axi_RResp     : out std_logic_vector(1 downto 0);
        S_Axi_RLast     : out std_logic;
        S_Axi_RValid    : out std_logic;
        S_Axi_RReady    : in  std_logic;

        -------------------------------------------------------------------------------------------
        -- AXI Stream Master Interface [Axis_Clk]
        -------------------------------------------------------------------------------------------
        M_Axis_TData    : out std_logic_vector(M_Axis_TDataWidth_g-1 downto 0);
        M_Axis_TStrb    : out std_logic_vector(M_Axis_TDataWidth_g/8-1 downto 0);
        M_Axis_TKeep    : out std_logic_vector(M_Axis_TDataWidth_g/8-1 downto 0);
        M_Axis_TUser    : out std_logic_vector(M_Axis_TUserWidth_g-1 downto 0);
        M_Axis_TLast    : out std_logic;
        M_Axis_TValid   : out std_logic;
        M_Axis_TReady   : in  std_logic;

        -------------------------------------------------------------------------------------------
        -- AXI Stream Slave Interface [Axis_Clk]
        -------------------------------------------------------------------------------------------
        S_Axis_TData    : in  std_logic_vector(S_Axis_TDataWidth_g-1 downto 0)  ;
        S_Axis_TStrb    : in  std_logic_vector(S_Axis_TDataWidth_g/8-1 downto 0);
        S_Axis_TKeep    : in  std_logic_vector(S_Axis_TDataWidth_g/8-1 downto 0);
        S_Axis_TUser    : in  std_logic_vector(S_Axis_TUserWidth_g-1 downto 0)  ;
        S_Axis_TLast    : in  std_logic;
        S_Axis_TValid   : in  std_logic;
        S_Axis_TReady   : out std_logic
    );
end entity IpPackager_2020_1;

---------------------------------------------------------------------------------------------------
-- Architecture Implementation
---------------------------------------------------------------------------------------------------
architecture rtl of IpPackager_2020_1 is

    component IpPackager_2020_1_sub is
    port(
        Clk         : in std_logic;
        Rst         : in std_logic;
        Uart_Tx     : out std_logic;
        Uart_Rx     : in std_logic
    );
    end component;

begin

-----------------------------------------------------------------------------------------------
-- Sequential Process
-----------------------------------------------------------------------------------------------
    p_seq_sync_rst_axi : process(Axi_Clk)
    begin
        if rising_edge(Axi_Clk) then
            if Axi_ResetN = '0' then
                -- AXI Master Interface [Axi_Clk]
                M_Axi_AwAddr    <= (others => '0');
                M_Axi_AwLen     <= (others => '0');
                M_Axi_AwSize    <= (others => '0');
                M_Axi_AwBurst   <= (others => '0');
                M_Axi_AwLock    <= '0';
                M_Axi_AwCache   <= (others => '0');
                M_Axi_AwProt    <= (others => '0');
                M_Axi_AwValid   <= '0';
                M_Axi_WData     <= (others => '0');
                M_Axi_WStrb     <= (others => '0');
                M_Axi_WLast     <= '0';
                M_Axi_WValid    <= '0';
                M_Axi_BReady    <= '0';
                M_Axi_ArAddr    <= (others => '0');
                M_Axi_ArLen     <= (others => '0');
                M_Axi_ArSize    <= (others => '0');
                M_Axi_ArBurst   <= (others => '0');
                M_Axi_ArLock    <= '0';
                M_Axi_ArCache   <= (others => '0');
                M_Axi_ArProt    <= (others => '0');
                M_Axi_ArValid   <= '0';
                M_Axi_RReady    <= '0';
                -- AXI Slave Interface [Axi_Clk]
                S_Axi_AwReady   <= '0';
                S_Axi_WReady    <= '0';
                S_Axi_BResp     <= (others => '0');
                S_Axi_BValid    <= '0';
                S_Axi_ArReady   <= '0';
                S_Axi_RData     <= (others => '0');
                S_Axi_RResp     <= (others => '0');
                S_Axi_RLast     <= '0';
                S_Axi_RValid    <= '0';
            else
                -- AXI Master Interface [Axi_Clk]
                M_Axi_AwAddr    <= S_Axi_AwAddr;
                M_Axi_AwLen     <= S_Axi_AwLen;
                M_Axi_AwSize    <= S_Axi_AwSize;
                M_Axi_AwBurst   <= S_Axi_AwBurst;
                M_Axi_AwLock    <= S_Axi_AwLock;
                M_Axi_AwCache   <= S_Axi_AwCache;
                M_Axi_AwProt    <= S_Axi_AwProt;
                M_Axi_AwValid   <= S_Axi_AwValid;
                M_Axi_WData     <= S_Axi_WData;
                M_Axi_WStrb     <= S_Axi_WStrb;
                M_Axi_WLast     <= S_Axi_WLast;
                M_Axi_WValid    <= S_Axi_WValid;
                M_Axi_BReady    <= S_Axi_BReady;
                M_Axi_ArAddr    <= S_Axi_ArAddr;
                M_Axi_ArLen     <= S_Axi_ArLen;
                M_Axi_ArSize    <= S_Axi_ArSize;
                M_Axi_ArBurst   <= S_Axi_ArBurst;
                M_Axi_ArLock    <= S_Axi_ArLock;
                M_Axi_ArCache   <= S_Axi_ArCache;
                M_Axi_ArProt    <= S_Axi_ArProt;
                M_Axi_ArValid   <= S_Axi_ArValid;
                M_Axi_RReady    <= S_Axi_RReady;
                -- AXI Slave Interface [Axi_Clk]
                S_Axi_AwReady   <= M_Axi_AwReady;
                S_Axi_WReady    <= M_Axi_WReady;
                S_Axi_BResp     <= M_Axi_BResp;
                S_Axi_BValid    <= M_Axi_BValid;
                S_Axi_ArReady   <= M_Axi_ArReady;
                S_Axi_RData     <= M_Axi_RData;
                S_Axi_RResp     <= M_Axi_RResp;
                S_Axi_RLast     <= M_Axi_RLast;
                S_Axi_RValid    <= M_Axi_RValid;
            end if;
        end if;
    end process p_seq_sync_rst_axi;

p_seq_sync_rst_axis : process(Axis_Clk)
begin
    if rising_edge(Axis_Clk) then
        if Axis_ResetN = '0' then
            -- AXI Stream Master Interface [Axis_Clk]
            M_Axis_TData    <= (others => '0');
            M_Axis_TStrb    <= (others => '0');
            M_Axis_TKeep    <= (others => '0');
            M_Axis_TUser    <= (others => '0');
            M_Axis_TLast    <= '0';
            M_Axis_TValid   <= '0';
            -- AXI Stream Slave Interface [Axis_Clk]
            S_Axis_TReady   <= '0';
        else
            -- AXI Stream Master Interface [Axis_Clk]
            M_Axis_TData    <= S_Axis_TData;
            M_Axis_TStrb    <= S_Axis_TStrb;
            M_Axis_TKeep    <= S_Axis_TKeep;
            M_Axis_TUser    <= S_Axis_TUser;
            M_Axis_TLast    <= S_Axis_TLast;
            M_Axis_TValid   <= S_Axis_TValid;
            -- AXI Stream Slave Interface [Axis_Clk]
            S_Axis_TReady   <= M_Axis_TReady;
        end if;
    end if;
end process p_seq_sync_rst_axis;

        -- Misc [Clk]
        Interrupt       <= not Uart_Rx;

        i_sub : component IpPackager_2020_1_sub
        port map(
            Clk         => Clk,
            Rst         => Rst,
            Uart_Tx     => Uart_Tx,
            Uart_Rx     => Uart_Rx
        );

end architecture rtl;

---------------------------------------------------------------------------------------------------
-- EOF
---------------------------------------------------------------------------------------------------
