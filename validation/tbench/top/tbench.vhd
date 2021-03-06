--------------------------------------------------------------------------------
-- Company: Istituto Italiano di Tecnologia
-- Engineer: Francesco Diotalevi
--
-- Design Name:   
-- Module Name:   /home/francesco/FPGA/FIR/tbench.vhd
-- Project Name:  FMC
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use IEEE.MATH_REAL.ALL;

--LIBRARY dut_lib;
--use  dut_lib.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tbench IS
generic (
		CLK_PERIOD         : integer := 10; -- CLK period [ns]
        C_S_AXI_DATA_WIDTH : natural := 32;
        C_S_AXI_ADDR_WIDTH : natural := 12;
        C_ENC_NUM_OF_STEPS : natural := 1970; -- Limit of incremental encoder
        NUM_OF_TRANSMITTER : integer := 32;
        NUM_OF_RECEIVER    : natural := 32;
        SPI_ADC_RES        : natural := 12;
        
        NORANDOM_DMA       : natural := 0
);
END tbench;
 
ARCHITECTURE behavior OF tbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    
 component spinn2Neu_core 
    generic (
        -- DO NOT EDIT BELOW THIS LINE ---------------------
        -- Bus protocol parameters, do not add to or delete
        C_S_AXI_DATA_WIDTH             : integer              := 32;
        C_S_AXI_ADDR_WIDTH             : integer              := 7;
        C_S_AXI_MIN_SIZE               : std_logic_vector     := X"000001FF";
        C_USE_WSTRB                    : integer              := 1;
        C_DPHASE_TIMEOUT               : integer              := 8;
        C_BASEADDR                     : std_logic_vector     := X"FFFFFFFF";
        C_HIGHADDR                     : std_logic_vector     := X"00000000";
        C_FAMILY                       : string               := "virtex7";
        C_NUM_REG                      : integer              := 24;
        C_NUM_MEM                      : integer              := 1;
        C_SLV_AWIDTH                   : integer              := 32;
        C_SLV_DWIDTH                   : integer              := 32
        -- DO NOT EDIT ABOVE THIS LINE ---------------------
    );
    port (
        nRst        : in  std_logic;
        Clk_Spinn   : in  std_logic;
        Clk_Core    : in  std_logic;
        
        Interrupt_o : out std_logic;
        
        LpbkDefault_i : in  std_logic_vector(2 downto 0);


        -- input SpiNNaker link interface
        data_2of7_from_spinnaker       : in  std_logic_vector(6 downto 0);
        ack_to_spinnaker               : out std_logic;
        -- output SpiNNaker link interface
        data_2of7_to_spinnaker         : out std_logic_vector(6 downto 0);
        ack_from_spinnaker             : in  std_logic;
        
        -- Debug signals
        dbg_dt_2of7_from_spin : out std_logic_vector(6 downto 0);
        dbg_ack_to_spin       : out std_logic;

        dbg_dt_2of7_to_spin   : out std_logic_vector(6 downto 0);
        dbg_ack_from_spin     : out std_logic;
        
        dbg_txSeqData    : out std_logic_vector(31 downto 0);
        dbg_txSeqSrcRdy  : out std_logic;
        dbg_txSeqDstRdy  : out std_logic;

        dbg_rxMonData    : out std_logic_vector(31 downto 0);
        dbg_rxMonSrcRdy  : out std_logic;
        dbg_rxMonDstRdy  : out std_logic;
        
        dbg_rxstate      : out std_logic_vector(2 downto 0);
        dbg_txstate      : out std_logic_vector(1 downto 0);
        dbg_ipkt_vld     : out std_logic;
        dbg_ipkt_rdy     : out std_logic;
        dbg_opkt_vld     : out std_logic;
        dbg_opkt_rdy     : out std_logic;


        -- ADD USER PORTS ABOVE THIS LINE ------------------

        -- DO NOT EDIT BELOW THIS LINE ---------------------
        -- Bus protocol ports, do not add to or delete
        -- Axi lite I-f
        S_AXI_ACLK                     : in  std_logic;
        S_AXI_ARESETN                  : in  std_logic;
        S_AXI_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_AWVALID                  : in  std_logic;
        S_AXI_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
        S_AXI_WVALID                   : in  std_logic;
        S_AXI_BREADY                   : in  std_logic;
        S_AXI_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
        S_AXI_ARVALID                  : in  std_logic;
        S_AXI_RREADY                   : in  std_logic;
        S_AXI_ARREADY                  : out std_logic;
        S_AXI_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        S_AXI_RRESP                    : out std_logic_vector(1 downto 0);
        S_AXI_RVALID                   : out std_logic;
        S_AXI_WREADY                   : out std_logic;
        S_AXI_BRESP                    : out std_logic_vector(1 downto 0);
        S_AXI_BVALID                   : out std_logic;
        S_AXI_AWREADY                  : out std_logic;
        -- Axi Stream I/f
        S_AXIS_TREADY                  : out std_logic;
        S_AXIS_TDATA                   : in  std_logic_vector(31 downto 0);
        S_AXIS_TLAST                   : in  std_logic;
        S_AXIS_TVALID                  : in  std_logic;
        M_AXIS_TVALID                  : out std_logic;
        M_AXIS_TDATA                   : out std_logic_vector(31 downto 0);
        M_AXIS_TLAST                   : out std_logic;
        M_AXIS_TREADY                  : in  std_logic
        -- DO NOT EDIT ABOVE THIS LINE ---------------------
    );
    END COMPONENT;

 component axi4lite_bfm_v00 
  generic(
  		limit : integer := 1000;
  		NORANDOM_DMA : integer := 0;
        SPI_ADC_RES : integer := 12;
        NUM_OF_RECEIVER    : natural := NUM_OF_RECEIVER;
      AXI4LM_CMD_FILE    : string        := "AXI4LM_bfm.cmd";  -- Command file name
      AXI4LM_LOG_FILE    : string        := "AXI4LM_bfm.log"   -- Log file name
		);
    Port ( S_AXI_ACLK :in  STD_LOGIC;
           S_AXI_ARESETN : in  STD_LOGIC;
           S_AXI_AWVALID : out  STD_LOGIC;
           S_AXI_AWREADY : in  STD_LOGIC;
           S_AXI_AWADDR : out  STD_LOGIC_VECTOR (31 downto 0);
           S_AXI_WVALID : out  STD_LOGIC;
           S_AXI_WREADY : in  STD_LOGIC;
           S_AXI_WDATA : out  STD_LOGIC_VECTOR (31 downto 0);
           S_AXI_WSTRB : out  STD_LOGIC_VECTOR (3 downto 0);
           S_AXI_BVALID : in  STD_LOGIC;
           S_AXI_BREADY : out  STD_LOGIC;
           S_AXI_BRESP : in  STD_LOGIC_VECTOR (1 downto 0);
           S_AXI_ARVALID : inout  STD_LOGIC;
           S_AXI_ARREADY : in  STD_LOGIC;
           S_AXI_ARADDR : out  STD_LOGIC_VECTOR (31 downto 0);
           S_AXI_RVALID : in  STD_LOGIC;
           S_AXI_RREADY : out  STD_LOGIC;
           S_AXI_RDATA : in  STD_LOGIC_VECTOR (31 downto 0);
           S_AXI_RRESP : in  STD_LOGIC_VECTOR (1 downto 0);
           M_Axis_TVALID  : in  std_logic;
           M_Axis_TLAST   : in  std_logic;
           M_Axis_TDATA   : in  std_logic_vector (31 downto 0);
           M_Axis_TREADY  : out std_logic;
           S_AXIS_TREADY  : in  std_logic;
           S_AXIS_TDATA   : out std_logic_vector(31 downto 0);
           S_AXIS_TLAST   : out std_logic;
           S_AXIS_TVALID  : out std_logic;
           -- Axi Master I-f
           M_AXI_ACLK     : in  std_logic;
           -- Axi master
           M_AXI_AWADDR   : in  std_logic_vector(31 downto 0);
           M_AXI_AWLEN    : in  std_logic_vector(7 downto 0); 
           M_AXI_AWSIZE   : in  std_logic_vector(2 downto 0);
           M_AXI_AWBURST  : in  std_logic_vector(1 downto 0);
           M_AXI_AWCACHE  : in  std_logic_vector(3 downto 0);
           M_AXI_AWVALID  : in  std_logic; 
           M_AXI_AWREADY  : out std_logic; 
           --       master interface write data
           M_AXI_WDATA    : in  std_logic_vector(31 downto 0); 
           M_AXI_WSTRB    : in  std_logic_vector(3 downto 0);
           M_AXI_WLAST    : in  std_logic;  
           M_AXI_WVALID   : in  std_logic;   
           M_AXI_WREADY   : out std_logic;  
           --       master interface write response
           M_AXI_BRESP    : out std_logic_vector(1 downto 0); 
           M_AXI_BVALID   : out std_logic;   
           M_AXI_BREADY   : in  std_logic;

           start_dmas     : out std_logic;
           dma_done       : in  std_logic;

           ocp_o          : out std_logic;
           ext_fault_o    : out std_logic;
            
           interrupt  	  : in std_logic;			  
           start : in std_logic
);
end component;
     

component PLL
	generic(
		SYSCLK_PERIOD: integer := 10;
        SD_PERIOD    : integer := 50;
		SWEEP : integer := 0
		);
	port(
		rst_in	        : in  std_logic; 	-- Reset in
		rst_out	        : out std_logic;	-- Reset out
		SYS_CLK	        : out std_logic;  	-- Clock
        sd_rst_out      : out std_logic;    -- Reset out
        SD_CLK          : out std_logic     -- Clock 
	);
end component ;

signal i_clk              : std_logic;
signal i_resetn           : std_logic;

signal S_AXI_ACLK            : std_logic;
signal S_AXI_ARESETN         : std_logic;
signal S_AXI_AWADDR          : std_logic_vector(31 downto 0);
signal S_AXI_AWVALID         : std_logic;
signal S_AXI_WDATA           : std_logic_vector(31 downto 0);
signal S_AXI_WSTRB           : std_logic_vector(3 downto 0);
signal S_AXI_WVALID          : std_logic;
signal S_AXI_BREADY          : std_logic;
signal S_AXI_ARADDR          : std_logic_vector(31 downto 0);
signal S_AXI_ARVALID         : std_logic;
signal S_AXI_RREADY          : std_logic;
signal S_AXI_ARREADY         : std_logic;
signal S_AXI_RDATA           : std_logic_vector(31 downto 0);
signal S_AXI_RRESP           : std_logic_vector(1 downto 0);
signal S_AXI_RVALID          : std_logic;
signal S_AXI_WREADY          : std_logic;
signal S_AXI_BRESP           : std_logic_vector(1 downto 0);
signal S_AXI_BVALID          : std_logic;
signal S_AXI_AWREADY         : std_logic;
signal S_AXIS_TREADY         : std_logic;
signal S_AXIS_TDATA          : std_logic_vector(31 downto 0);
signal S_AXIS_TLAST          : std_logic;
signal S_AXIS_TVALID         : std_logic;
signal M_AXIS_TVALID         : std_logic;
signal M_AXIS_TDATA          : std_logic_vector(31 downto 0);
signal M_AXIS_TLAST          : std_logic;
signal M_AXIS_TREADY         : std_logic;
signal M_AXI_ARADDR          : std_logic_vector(31 downto 0);
signal M_AXI_ARLEN           : std_logic_vector( 7 downto 0);
signal M_AXI_ARSIZE          : std_logic_vector( 2 downto 0);
signal M_AXI_ARBURST         : std_logic_vector( 1 downto 0);
signal M_AXI_ARCACHE         : std_logic_vector( 3 downto 0);
signal M_AXI_ARVALID         : std_logic;
signal M_AXI_ARREADY         : std_logic;
signal M_AXI_RDATA           : std_logic_vector(31 downto 0);  
signal M_AXI_RRESP           : std_logic_vector( 1 downto 0);  
signal M_AXI_RLAST           : std_logic;                      
signal M_AXI_RVALID          : std_logic;                      
signal M_AXI_RREADY          : std_logic;                      
signal M_AXI_AWADDR          : std_logic_vector(31 downto 0);
signal M_AXI_AWLEN           : std_logic_vector(7 downto 0);
signal M_AXI_AWSIZE          : std_logic_vector(2 downto 0);
signal M_AXI_AWBURST         : std_logic_vector(1 downto 0);
signal M_AXI_AWVALID         : std_logic;
signal M_AXI_AWREADY         : std_logic;
signal M_AXI_WDATA           : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal M_AXI_WSTRB           : std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
signal M_AXI_WLAST           : std_logic; 
signal M_AXI_WVALID          : std_logic;
signal M_AXI_WREADY          : std_logic;
signal M_AXI_BRESP           : std_logic_vector(1 downto 0);
signal M_AXI_BVALID          : std_logic;
signal M_AXI_BREADY          : std_logic;
signal M_AXI_AWCACHE         : std_logic_vector(3 downto 0);

signal i_start : std_logic;
signal i_rst_in: std_logic := '0';
signal i_Interrupt : std_logic := '0';

signal i_en : std_logic;

signal tx : std_logic_vector(NUM_OF_TRANSMITTER-1 downto 0 );

signal start_dmas : std_logic;
signal dma_done : std_logic;
signal i_Async_reset : std_logic;
signal i_vr1_i : std_logic_vector (7 downto 0);
signal i_vr2_i : std_logic_vector (7 downto 0);
signal i_vr3_i : std_logic_vector (7 downto 0);
signal pwmap : std_logic;
signal pwman : std_logic;
signal pwmbp : std_logic;
signal pwmbn : std_logic;
signal pwmcp : std_logic;
signal pwmcn : std_logic;

-- encoder
signal i_FromSpeed : real;
signal i_ToSpeed : real := 10000.0;
signal i_SpeedInDeltaTime : time := 3 ms;
signal i_encoder_A, i_encoder_B, i_encoder_Index, i_encoder_Home : std_logic;
signal i_encoder_encoder_A, i_encoder_encoder_B, i_encoder_encoder_Index, i_encoder_encoder_Home : std_logic;

-- SD
signal i_sd_resetn: std_logic;
signal i_sd_clk: std_logic;
signal clk_sd : std_logic;
signal resetn_sd : std_logic;
signal current_sd : std_logic_vector(2 downto 0);

-- current
signal i_ocp : std_logic;
signal i_ext_fault : std_logic;

-- VDClink
signal i_vdclink_data_sd : std_logic;
signal i_vdclink_clk_sd : std_logic;

begin 
    
    INST_PLL : PLL
	generic map(
		SYSCLK_PERIOD => CLK_PERIOD,
        SD_PERIOD     => 50,
		SWEEP         => 0
		)
	port map( 
		rst_in	        => i_rst_in,
		rst_out	        => i_resetn,
		SYS_CLK	        => i_clk,
        sd_rst_out      => i_sd_resetn,
        SD_CLK          => i_sd_clk
	);

-- Instantiate the Unit Under Test (UUT)
inst_spinn2Neu_core : spinn2Neu_core 
    generic map(
        -- DO NOT EDIT BELOW THIS LINE ---------------------
        -- Bus protocol parameters, do not add to or delete
        C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
        C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH
        -- DO NOT EDIT ABOVE THIS LINE ---------------------
    )
    port map (
        nRst         => i_resetn,
        Clk_Spinn    => i_clk,
        Clk_Core     => i_clk,
        
        Interrupt_o => open,
        
        LpbkDefault_i => (others => '0'),


        -- input SpiNNaker link interface
        data_2of7_from_spinnaker       => (others => '0'),
        ack_to_spinnaker               => open,
        -- output SpiNNaker link interface
        data_2of7_to_spinnaker         => open,
        ack_from_spinnaker             => '0',
        
        -- Debug signals
        dbg_dt_2of7_from_spin => open,
        dbg_ack_to_spin       => open,

        dbg_dt_2of7_to_spin   => open,
        dbg_ack_from_spin     => open,
        
        dbg_txSeqData         => open,
        dbg_txSeqSrcRdy       => open,
        dbg_txSeqDstRdy       => open,

        dbg_rxMonData         => open,
        dbg_rxMonSrcRdy       => open,
        dbg_rxMonDstRdy       => open,
 
        dbg_rxstate           => open,
        dbg_txstate           => open,
        dbg_ipkt_vld          => open,
        dbg_ipkt_rdy          => open,
        dbg_opkt_vld          => open,
        dbg_opkt_rdy          => open,


        -- ADD USER PORTS ABOVE THIS LINE ------------------

        -- DO NOT EDIT BELOW THIS LINE ---------------------
        -- Bus protocol ports, do not add to or delete
        -- Axi lite I-f
        S_AXI_ACLK => i_clk,
        S_AXI_ARESETN => i_resetn,
        S_AXI_AWADDR => S_AXI_AWADDR(C_S_AXI_ADDR_WIDTH-1 downto 0),
        S_AXI_AWVALID => S_AXI_AWVALID,
        S_AXI_WDATA => S_AXI_WDATA,
        S_AXI_WSTRB => S_AXI_WSTRB,
        S_AXI_WVALID => S_AXI_WVALID,
        S_AXI_BREADY => S_AXI_BREADY,
        S_AXI_ARADDR => S_AXI_ARADDR(C_S_AXI_ADDR_WIDTH-1 downto 0),
        S_AXI_ARVALID  => S_AXI_ARVALID,
        S_AXI_RREADY  => S_AXI_RREADY,
        S_AXI_ARREADY => S_AXI_ARREADY,
        S_AXI_RDATA   => S_AXI_RDATA,
        S_AXI_RRESP   => S_AXI_RRESP,
        S_AXI_RVALID  => S_AXI_RVALID,
        S_AXI_WREADY  => S_AXI_WREADY,
        S_AXI_BRESP   => S_AXI_BRESP,
        S_AXI_BVALID  => S_AXI_BVALID,
        S_AXI_AWREADY => S_AXI_AWREADY,
        -- Axi Stream I/f
        S_AXIS_TREADY => open,
        S_AXIS_TDATA  => (others => '0'),
        S_AXIS_TLAST  => '0',
        S_AXIS_TVALID => '0',
        M_AXIS_TVALID => open,
        M_AXIS_TDATA  => open,
        M_AXIS_TLAST  => open,
        M_AXIS_TREADY => '0'
        -- DO NOT EDIT ABOVE THIS LINE ---------------------
    );
    
bfm : axi4lite_bfm_v00
generic map (
  		NORANDOM_DMA => NORANDOM_DMA
	)
 PORT MAP (				
           S_AXI_ACLK => i_clk,
           S_AXI_ARESETN => i_resetn,
           S_AXI_AWVALID => S_AXI_AWVALID,
           S_AXI_AWREADY => S_AXI_AWREADY,
           S_AXI_AWADDR => S_AXI_AWADDR,
           S_AXI_WVALID => S_AXI_WVALID,
           S_AXI_WREADY => S_AXI_WREADY,
           S_AXI_WDATA => S_AXI_WDATA,
           S_AXI_WSTRB => S_AXI_WSTRB,
           S_AXI_BVALID => S_AXI_BVALID,
           S_AXI_BREADY => S_AXI_BREADY,
           S_AXI_BRESP  => S_AXI_BRESP,
           S_AXI_ARVALID => S_AXI_ARVALID,
           S_AXI_ARREADY => S_AXI_ARREADY,
           S_AXI_ARADDR => S_AXI_ARADDR,
           S_AXI_RVALID => S_AXI_RVALID,
           S_AXI_RREADY => S_AXI_RREADY,
           S_AXI_RDATA => S_AXI_RDATA,
           S_AXI_RRESP => S_AXI_RRESP,
           M_Axis_TVALID => '0',
           M_Axis_TLAST => '0',
           M_Axis_TDATA  => (others => '0'),
           M_Axis_TREADY => open,
           S_AXIS_TREADY => S_AXIS_TREADY,
           S_AXIS_TDATA => S_AXIS_TDATA,
           S_AXIS_TLAST => S_AXIS_TLAST,
           S_AXIS_TVALID => S_AXIS_TVALID,
           -- Axi master
           M_AXI_ACLK  => i_clk,
           M_AXI_AWADDR   => M_AXI_AWADDR,
           M_AXI_AWLEN    => M_AXI_AWLEN,
           M_AXI_AWSIZE   => M_AXI_AWSIZE,
           M_AXI_AWBURST  => M_AXI_AWBURST,
           M_AXI_AWCACHE  => M_AXI_AWCACHE,
           M_AXI_AWVALID  => M_AXI_AWVALID,
           M_AXI_AWREADY  => M_AXI_AWREADY,
           --       master interface write data
           M_AXI_WDATA    => M_AXI_WDATA,
           M_AXI_WSTRB    => M_AXI_WSTRB,
           M_AXI_WLAST    => M_AXI_WLAST,
           M_AXI_WVALID   => M_AXI_WVALID,
           M_AXI_WREADY   => M_AXI_WREADY,
           --       master interface write response
           M_AXI_BRESP    => M_AXI_BRESP,
           M_AXI_BVALID   => M_AXI_BVALID,
           M_AXI_BREADY   => M_AXI_BREADY,

           start_dmas     => start_dmas,
           dma_done       => dma_done,

           ocp_o          => i_ocp,
           ext_fault_o    => i_ext_fault,


           interrupt => i_Interrupt,
           start => i_start
	);


   -- Stimulus process
    
i_rst_in <= '0', '1' after 150 ns;
i_en <= '0', '1' after 300 ns;
i_FromSpeed <= 0.0, 2000.0 after 400 ns;

StarProc : process
	begin
		i_start <= '0';
		wait until i_resetn='1';
		for i in 0 to 10 loop
			wait until (i_clk'event and i_clk='1');
		end loop;
		i_start <= '1';
		wait;
end process StarProc;

END;
