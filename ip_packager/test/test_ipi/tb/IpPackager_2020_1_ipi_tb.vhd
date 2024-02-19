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
entity IpPackager_2020_1_ipi_tb is
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
end entity IpPackager_2020_1_ipi_tb;

---------------------------------------------------------------------------------------------------
-- Architecture Implementation
---------------------------------------------------------------------------------------------------
architecture tb of IpPackager_2020_1_ipi_tb is

begin

    i_dut : entity work.IpPackager_2020_1_ipi
    generic map(
        Clk_FreqHz_g        => Clk_FreqHz_g,
        M_Axi_DataWidth_g   => M_Axi_DataWidth_g,
        M_Axi_AddrWidth_g   => M_Axi_AddrWidth_g,
        S_Axi_DataWidth_g   => S_Axi_DataWidth_g,
        S_Axi_AddrWidth_g   => S_Axi_AddrWidth_g,
        M_Axis_TDataWidth_g => M_Axis_TDataWidth_g,
        M_Axis_TUserWidth_g => M_Axis_TUserWidth_g,
        S_Axis_TDataWidth_g => S_Axis_TDataWidth_g,
        S_Axis_TUserWidth_g => S_Axis_TUserWidth_g
    )
    port map(
        -- Clock and Reset
        Clk             => '1',
        Rst             => '0',
        Axi_Clk         => '1',
        Axi_ResetN      => '1',
        Axis_Clk        => '1',
        Axis_ResetN     => '1',
        -- Interrupt [Clk]
        Interrupt       => open,
        -- UART [Clk]
        Uart_Tx         => open,
        Uart_Rx         => '1',
        -- AXI Master Interface [Axi_Clk]
        -- AXI Write Address Channel
        M_Axi_AwAddr    => open,
        M_Axi_AwLen     => open,
        M_Axi_AwSize    => open,
        M_Axi_AwBurst   => open,
        M_Axi_AwLock    => open,
        M_Axi_AwCache   => open,
        M_Axi_AwProt    => open,
        M_Axi_AwValid   => open,
        M_Axi_AwReady   => '1',
        -- AXI Write Data Channel
        M_Axi_WData     => open,
        M_Axi_WStrb     => open,
        M_Axi_WLast     => open,
        M_Axi_WValid    => open,
        M_Axi_WReady    => '1',
        -- AXI Write Response Channel
        M_Axi_BResp     => (others => '0'),
        M_Axi_BValid    => '0',
        M_Axi_BReady    => open,
        -- AXI Read Address Channel
        M_Axi_ArAddr    => open,
        M_Axi_ArLen     => open,
        M_Axi_ArSize    => open,
        M_Axi_ArBurst   => open,
        M_Axi_ArLock    => open,
        M_Axi_ArCache   => open,
        M_Axi_ArProt    => open,
        M_Axi_ArValid   => open,
        M_Axi_ArReady   => '1',
        -- AXI Read Data Channel
        M_Axi_RData     => (others => '0'),
        M_Axi_RResp     => (others => '0'),
        M_Axi_RLast     => '1',
        M_Axi_RValid    => '1',
        M_Axi_RReady    => open,
        -- AXI Slave Interface [Axi_Clk]
        -- AXI Write Address Channel
        S_Axi_AwAddr    => (others => '0'),
        S_Axi_AwLen     => (others => '0'),
        S_Axi_AwSize    => (others => '0'),
        S_Axi_AwBurst   => (others => '0'),
        S_Axi_AwLock    => '1',
        S_Axi_AwCache   => (others => '0'),
        S_Axi_AwProt    => (others => '0'),
        S_Axi_AwValid   => '1',
        S_Axi_AwReady   => open,
        -- AXI Write Data Channel
        S_Axi_WData     => (others => '0'),
        S_Axi_WStrb     => (others => '0'),
        S_Axi_WLast     => '1',
        S_Axi_WValid    => '1',
        S_Axi_WReady    => open,
        -- AXI Write Response Channel
        S_Axi_BResp     => open,
        S_Axi_BValid    => open,
        S_Axi_BReady    => '1',
        -- AXI Read Address Channel
        S_Axi_ArAddr    => (others => '0'),
        S_Axi_ArLen     => (others => '0'),
        S_Axi_ArSize    => (others => '0'),
        S_Axi_ArBurst   => (others => '0'),
        S_Axi_ArLock    => '1',
        S_Axi_ArCache   => (others => '0'),
        S_Axi_ArProt    => (others => '0'),
        S_Axi_ArValid   => '1',
        S_Axi_ArReady   => open,
        -- AXI Read Data Channel
        S_Axi_RData     => open,
        S_Axi_RResp     => open,
        S_Axi_RLast     => open,
        S_Axi_RValid    => open,
        S_Axi_RReady    => '1',
        -- AXI Stream Master Interface [Axis_Clk]
        M_Axis_TData    => open,
        M_Axis_TStrb    => open,
        M_Axis_TKeep    => open,
        M_Axis_TUser    => open,
        M_Axis_TLast    => open,
        M_Axis_TValid   => open,
        M_Axis_TReady   => '1',
        -- AXI Stream Slave Interface [Axis_Clk]
        S_Axis_TData    => (others => '0'),
        S_Axis_TStrb    => (others => '0'),
        S_Axis_TKeep    => (others => '0'),
        S_Axis_TUser    => (others => '0'),
        S_Axis_TLast    => '1',
        S_Axis_TValid   => '1',
        S_Axis_TReady   => open
    );
    
end architecture tb;

---------------------------------------------------------------------------------------------------
-- EOF
---------------------------------------------------------------------------------------------------
