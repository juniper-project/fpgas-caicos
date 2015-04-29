library ieee ;
use ieee.std_logic_1164.all;

entity hls_toplevel is
port(
	s_axi_AXILiteS_AWVALID : IN STD_LOGIC;
    s_axi_AXILiteS_AWREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_AWADDR : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_AXILiteS_WVALID : IN STD_LOGIC;
    s_axi_AXILiteS_WREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_AXILiteS_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_AXILiteS_ARVALID : IN STD_LOGIC;
    s_axi_AXILiteS_ARREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_ARADDR : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    s_axi_AXILiteS_RVALID : OUT STD_LOGIC;
    s_axi_AXILiteS_RREADY : IN STD_LOGIC;
    s_axi_AXILiteS_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_AXILiteS_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_AXILiteS_BVALID : OUT STD_LOGIC;
    s_axi_AXILiteS_BREADY : IN STD_LOGIC;
    s_axi_AXILiteS_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    m_axi_mem_AWVALID : OUT STD_LOGIC;
    m_axi_mem_AWREADY : IN STD_LOGIC;
    m_axi_mem_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mem_AWID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axi_mem_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_mem_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mem_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mem_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_AWREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_WVALID : OUT STD_LOGIC;
    m_axi_mem_WREADY : IN STD_LOGIC;
    m_axi_mem_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mem_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_WLAST : OUT STD_LOGIC;
    m_axi_mem_WID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axi_mem_ARVALID : OUT STD_LOGIC;
    m_axi_mem_ARREADY : IN STD_LOGIC;
    m_axi_mem_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mem_ARID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axi_mem_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_mem_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mem_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_mem_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_ARREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_mem_RVALID : IN STD_LOGIC;
    m_axi_mem_RREADY : OUT STD_LOGIC;
    m_axi_mem_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_mem_RLAST : IN STD_LOGIC;
    m_axi_mem_RID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    m_axi_mem_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_BVALID : IN STD_LOGIC;
    m_axi_mem_BREADY : OUT STD_LOGIC;
    m_axi_mem_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_mem_BID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    interrupt : OUT STD_LOGIC;
    hold_outputs : IN STD_LOGIC
);
end entity hls_toplevel;

architecture rtl of hls_toplevel is
	COMPONENT hls
	  PORT (
	    s_axi_AXILiteS_AWVALID : IN STD_LOGIC;
	    s_axi_AXILiteS_AWREADY : OUT STD_LOGIC;
	    s_axi_AXILiteS_AWADDR : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	    s_axi_AXILiteS_WVALID : IN STD_LOGIC;
	    s_axi_AXILiteS_WREADY : OUT STD_LOGIC;
	    s_axi_AXILiteS_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	    s_axi_AXILiteS_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	    s_axi_AXILiteS_ARVALID : IN STD_LOGIC;
	    s_axi_AXILiteS_ARREADY : OUT STD_LOGIC;
	    s_axi_AXILiteS_ARADDR : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	    s_axi_AXILiteS_RVALID : OUT STD_LOGIC;
	    s_axi_AXILiteS_RREADY : IN STD_LOGIC;
	    s_axi_AXILiteS_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    s_axi_AXILiteS_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    s_axi_AXILiteS_BVALID : OUT STD_LOGIC;
	    s_axi_AXILiteS_BREADY : IN STD_LOGIC;
	    s_axi_AXILiteS_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    ap_clk : IN STD_LOGIC;
	    ap_rst_n : IN STD_LOGIC;
	    m_axi_mem_AWVALID : OUT STD_LOGIC;
	    m_axi_mem_AWREADY : IN STD_LOGIC;
	    m_axi_mem_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    m_axi_mem_AWID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	    m_axi_mem_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	    m_axi_mem_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	    m_axi_mem_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_AWREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_AWUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_WVALID : OUT STD_LOGIC;
	    m_axi_mem_WREADY : IN STD_LOGIC;
	    m_axi_mem_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    m_axi_mem_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_WLAST : OUT STD_LOGIC;
	    m_axi_mem_WID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_WUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_ARVALID : OUT STD_LOGIC;
	    m_axi_mem_ARREADY : IN STD_LOGIC;
	    m_axi_mem_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	    m_axi_mem_ARID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	    m_axi_mem_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	    m_axi_mem_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
	    m_axi_mem_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_ARREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	    m_axi_mem_ARUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_RVALID : IN STD_LOGIC;
	    m_axi_mem_RREADY : OUT STD_LOGIC;
	    m_axi_mem_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	    m_axi_mem_RLAST : IN STD_LOGIC;
	    m_axi_mem_RID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_RUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_BVALID : IN STD_LOGIC;
	    m_axi_mem_BREADY : OUT STD_LOGIC;
	    m_axi_mem_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	    m_axi_mem_BID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	    m_axi_mem_BUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	    interrupt : OUT STD_LOGIC
	  );
	END COMPONENT;

	signal sig_s_axi_AXILiteS_AWVALID :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_AWREADY :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_AWADDR :  STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal sig_s_axi_AXILiteS_WVALID :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_WREADY :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_WDATA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_s_axi_AXILiteS_WSTRB :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_s_axi_AXILiteS_ARVALID :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_ARREADY :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_ARADDR :  STD_LOGIC_VECTOR(4 DOWNTO 0);
    signal sig_s_axi_AXILiteS_RVALID :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_RREADY :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_RDATA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_s_axi_AXILiteS_RRESP :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_s_axi_AXILiteS_BVALID :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_BREADY :  STD_LOGIC;
    signal sig_s_axi_AXILiteS_BRESP :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_ap_clk :  STD_LOGIC;
    signal sig_ap_rst_n :  STD_LOGIC;
    signal sig_m_axi_mem_AWVALID :  STD_LOGIC;
    signal sig_m_axi_mem_AWREADY :  STD_LOGIC;
    signal sig_m_axi_mem_AWADDR :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_m_axi_mem_AWID :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_AWLEN :  STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal sig_m_axi_mem_AWSIZE :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal sig_m_axi_mem_AWBURST :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_AWLOCK :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_AWCACHE :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_AWPROT :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal sig_m_axi_mem_AWQOS :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_AWREGION :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_AWUSER :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_WVALID :  STD_LOGIC;
    signal sig_m_axi_mem_WREADY :  STD_LOGIC;
    signal sig_m_axi_mem_WDATA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_m_axi_mem_WSTRB :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_WLAST :  STD_LOGIC;
    signal sig_m_axi_mem_WID :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_WUSER :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_ARVALID :  STD_LOGIC;
    signal sig_m_axi_mem_ARREADY :  STD_LOGIC;
    signal sig_m_axi_mem_ARADDR :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_m_axi_mem_ARID :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_ARLEN :  STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal sig_m_axi_mem_ARSIZE :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal sig_m_axi_mem_ARBURST :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_ARLOCK :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_ARCACHE :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_ARPROT :  STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal sig_m_axi_mem_ARQOS :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_ARREGION :  STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal sig_m_axi_mem_ARUSER :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_RVALID :  STD_LOGIC;
    signal sig_m_axi_mem_RREADY :  STD_LOGIC;
    signal sig_m_axi_mem_RDATA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal sig_m_axi_mem_RLAST :  STD_LOGIC;
    signal sig_m_axi_mem_RID :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_RUSER :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_RRESP :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_BVALID :  STD_LOGIC;
    signal sig_m_axi_mem_BREADY :  STD_LOGIC;
    signal sig_m_axi_mem_BRESP :  STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal sig_m_axi_mem_BID :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_m_axi_mem_BUSER :  STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal sig_interrupt : STD_LOGIC;
    signal sig_dummy_user : STD_LOGIC_VECTOR(0 downto 0);

    attribute S : string;
    attribute S of sig_dummy_user : signal is "TRUE";
begin
	brg : hls
	  PORT MAP (
	    s_axi_AXILiteS_AWVALID => 	sig_s_axi_AXILiteS_AWVALID,
	    s_axi_AXILiteS_AWREADY => 	sig_s_axi_AXILiteS_AWREADY,
	    s_axi_AXILiteS_AWADDR => 	sig_s_axi_AXILiteS_AWADDR,
	    s_axi_AXILiteS_WVALID => 	sig_s_axi_AXILiteS_WVALID,
	    s_axi_AXILiteS_WREADY => 	sig_s_axi_AXILiteS_WREADY,
	    s_axi_AXILiteS_WDATA => 	sig_s_axi_AXILiteS_WDATA,
	    s_axi_AXILiteS_WSTRB => 	sig_s_axi_AXILiteS_WSTRB,
	    s_axi_AXILiteS_ARVALID => 	sig_s_axi_AXILiteS_ARVALID,
	    s_axi_AXILiteS_ARREADY => 	sig_s_axi_AXILiteS_ARREADY,
	    s_axi_AXILiteS_ARADDR => 	sig_s_axi_AXILiteS_ARADDR,
	    s_axi_AXILiteS_RVALID => 	sig_s_axi_AXILiteS_RVALID,
	    s_axi_AXILiteS_RREADY => 	sig_s_axi_AXILiteS_RREADY,
	    s_axi_AXILiteS_RDATA => 	sig_s_axi_AXILiteS_RDATA,
	    s_axi_AXILiteS_RRESP => 	sig_s_axi_AXILiteS_RRESP,
	    s_axi_AXILiteS_BVALID => 	sig_s_axi_AXILiteS_BVALID,
	    s_axi_AXILiteS_BREADY => 	sig_s_axi_AXILiteS_BREADY,
	    s_axi_AXILiteS_BRESP => 	sig_s_axi_AXILiteS_BRESP,
	    ap_clk => 					sig_ap_clk,
	    ap_rst_n => 				sig_ap_rst_n,
	    m_axi_mem_AWVALID => 		sig_m_axi_mem_AWVALID,
	    m_axi_mem_AWREADY => 		sig_m_axi_mem_AWREADY,
	    m_axi_mem_AWADDR => 		sig_m_axi_mem_AWADDR,
	    m_axi_mem_AWID => 			sig_m_axi_mem_AWID,
	    m_axi_mem_AWLEN => 			sig_m_axi_mem_AWLEN,
	    m_axi_mem_AWSIZE => 		sig_m_axi_mem_AWSIZE,
	    m_axi_mem_AWBURST => 		sig_m_axi_mem_AWBURST,
	    m_axi_mem_AWLOCK => 		sig_m_axi_mem_AWLOCK,
	    m_axi_mem_AWCACHE => 		sig_m_axi_mem_AWCACHE,
	    m_axi_mem_AWPROT => 		sig_m_axi_mem_AWPROT,
	    m_axi_mem_AWQOS => 			sig_m_axi_mem_AWQOS,
	    m_axi_mem_AWREGION => 		sig_m_axi_mem_AWREGION,
	    m_axi_mem_AWUSER => 		sig_m_axi_mem_AWUSER,
	    m_axi_mem_WVALID => 		sig_m_axi_mem_WVALID,
	    m_axi_mem_WREADY => 		sig_m_axi_mem_WREADY,
	    m_axi_mem_WDATA => 			sig_m_axi_mem_WDATA,
	    m_axi_mem_WSTRB => 			sig_m_axi_mem_WSTRB,
	    m_axi_mem_WLAST => 			sig_m_axi_mem_WLAST,
	    m_axi_mem_WID => 			sig_m_axi_mem_WID,
	    m_axi_mem_WUSER => 			sig_m_axi_mem_WUSER,
	    m_axi_mem_ARVALID => 		sig_m_axi_mem_ARVALID,
	    m_axi_mem_ARREADY => 		sig_m_axi_mem_ARREADY,
	    m_axi_mem_ARADDR => 		sig_m_axi_mem_ARADDR,
	    m_axi_mem_ARID => 			sig_m_axi_mem_ARID,
	    m_axi_mem_ARLEN => 			sig_m_axi_mem_ARLEN,
	    m_axi_mem_ARSIZE => 		sig_m_axi_mem_ARSIZE,
	    m_axi_mem_ARBURST => 		sig_m_axi_mem_ARBURST,
	    m_axi_mem_ARLOCK => 		sig_m_axi_mem_ARLOCK,
	    m_axi_mem_ARCACHE => 		sig_m_axi_mem_ARCACHE,
	    m_axi_mem_ARPROT => 		sig_m_axi_mem_ARPROT,
	    m_axi_mem_ARQOS => 			sig_m_axi_mem_ARQOS,
	    m_axi_mem_ARREGION => 		sig_m_axi_mem_ARREGION,
	    m_axi_mem_ARUSER => 		sig_m_axi_mem_ARUSER,
	    m_axi_mem_RVALID => 		sig_m_axi_mem_RVALID,
	    m_axi_mem_RREADY => 		sig_m_axi_mem_RREADY,
	    m_axi_mem_RDATA => 			sig_m_axi_mem_RDATA,
	    m_axi_mem_RLAST => 			sig_m_axi_mem_RLAST,
	    m_axi_mem_RID => 			sig_m_axi_mem_RID,
	    m_axi_mem_RUSER => 			sig_dummy_user,
	    m_axi_mem_RRESP => 			sig_m_axi_mem_RRESP,
	    m_axi_mem_BVALID => 		sig_m_axi_mem_BVALID,
	    m_axi_mem_BREADY => 		sig_m_axi_mem_BREADY,
	    m_axi_mem_BRESP => 			sig_m_axi_mem_BRESP,
	    m_axi_mem_BID => 			sig_m_axi_mem_BID,
	    m_axi_mem_BUSER => 			"0",
	    interrupt => 				sig_interrupt
	);

	
    s_axi_AXILiteS_AWREADY 	<= (not hold_outputs) and sig_s_axi_AXILiteS_AWREADY;
	s_axi_AXILiteS_WREADY 	<= (not hold_outputs) and sig_s_axi_AXILiteS_WREADY ;
	s_axi_AXILiteS_ARREADY 	<= (not hold_outputs) and sig_s_axi_AXILiteS_ARREADY;
    s_axi_AXILiteS_RVALID 	<= (not hold_outputs) and sig_s_axi_AXILiteS_RVALID ;
    s_axi_AXILiteS_RDATA 	<= (not (31 downto 0 => hold_outputs)) and sig_s_axi_AXILiteS_RDATA;
    s_axi_AXILiteS_RRESP 	<= (not (1 downto 0 => hold_outputs)) and sig_s_axi_AXILiteS_RRESP;
    s_axi_AXILiteS_BVALID 	<= (not hold_outputs) and sig_s_axi_AXILiteS_BVALID ;
    s_axi_AXILiteS_BRESP 	<= (not (1 downto 0 => hold_outputs)) and sig_s_axi_AXILiteS_BRESP;
    m_axi_mem_AWVALID 		<= (not hold_outputs) and sig_m_axi_mem_AWVALID ;
    m_axi_mem_AWADDR 		<= (not (31 downto 0 => hold_outputs)) and sig_m_axi_mem_AWADDR ;
    m_axi_mem_AWID 			<= (not (0 downto 0 => hold_outputs)) and sig_m_axi_mem_AWID 		;
    m_axi_mem_AWLEN 		<= (not (7 downto 0 => hold_outputs)) and sig_m_axi_mem_AWLEN 	;
    m_axi_mem_AWSIZE 		<= (not (2 downto 0 => hold_outputs)) and sig_m_axi_mem_AWSIZE ;
    m_axi_mem_AWBURST 		<= (not (1 downto 0 => hold_outputs)) and sig_m_axi_mem_AWBURST ;
    m_axi_mem_AWLOCK 		<= (not (1 downto 0 => hold_outputs)) and sig_m_axi_mem_AWLOCK ;
    m_axi_mem_AWCACHE 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_AWCACHE ;
    m_axi_mem_AWPROT 		<= (not (2 downto 0 => hold_outputs)) and sig_m_axi_mem_AWPROT ;
    m_axi_mem_AWQOS 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_AWQOS 	;
    m_axi_mem_AWREGION 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_AWREGION;
    m_axi_mem_WVALID 		<= (not hold_outputs) and sig_m_axi_mem_WVALID ;
    m_axi_mem_WDATA 		<= (not (31 downto 0 => hold_outputs)) and sig_m_axi_mem_WDATA;
    m_axi_mem_WSTRB 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_WSTRB;
    m_axi_mem_WLAST 		<= (not hold_outputs) and sig_m_axi_mem_WLAST ;
    m_axi_mem_WID 			<= (not (0 downto 0 => hold_outputs)) and sig_m_axi_mem_WID;
    m_axi_mem_ARVALID 		<= (not hold_outputs) and sig_m_axi_mem_ARVALID ;
    m_axi_mem_ARADDR 		<= (not (31 downto 0 => hold_outputs)) and sig_m_axi_mem_ARADDR ;
    m_axi_mem_ARID 			<= (not (0 downto 0 => hold_outputs)) and sig_m_axi_mem_ARID 		;
    m_axi_mem_ARLEN 		<= (not (7 downto 0 => hold_outputs)) and sig_m_axi_mem_ARLEN 	;
    m_axi_mem_ARSIZE 		<= (not (2 downto 0 => hold_outputs)) and sig_m_axi_mem_ARSIZE ;
    m_axi_mem_ARBURST 		<= (not (1 downto 0 => hold_outputs)) and sig_m_axi_mem_ARBURST ;
    m_axi_mem_ARLOCK 		<= (not (1 downto 0 => hold_outputs)) and sig_m_axi_mem_ARLOCK ;
    m_axi_mem_ARCACHE 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_ARCACHE ;
    m_axi_mem_ARPROT 		<= (not (2 downto 0 => hold_outputs)) and sig_m_axi_mem_ARPROT ;
    m_axi_mem_ARQOS 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_ARQOS 	;
    m_axi_mem_ARREGION 		<= (not (3 downto 0 => hold_outputs)) and sig_m_axi_mem_ARREGION;
    m_axi_mem_RREADY 		<= (not hold_outputs) and sig_m_axi_mem_RREADY ;
    m_axi_mem_BREADY 		<= (not hold_outputs) and sig_m_axi_mem_BREADY ;
    interrupt 				<= (not hold_outputs) and sig_interrupt ;


    sig_s_axi_AXILiteS_AWVALID 	<= s_axi_AXILiteS_AWVALID;
    sig_s_axi_AXILiteS_AWADDR 	<= s_axi_AXILiteS_AWADDR ;
    sig_s_axi_AXILiteS_WVALID 	<= s_axi_AXILiteS_WVALID ;
    sig_s_axi_AXILiteS_WDATA 	<= s_axi_AXILiteS_WDATA ;
    sig_s_axi_AXILiteS_WSTRB 	<= s_axi_AXILiteS_WSTRB ;
    sig_s_axi_AXILiteS_ARVALID 	<= s_axi_AXILiteS_ARVALID;
    sig_s_axi_AXILiteS_ARADDR 	<= s_axi_AXILiteS_ARADDR ;
    sig_s_axi_AXILiteS_RREADY 	<= s_axi_AXILiteS_RREADY ;
    sig_s_axi_AXILiteS_BREADY 	<= s_axi_AXILiteS_BREADY ;
    sig_ap_clk 					<= ap_clk 				;
    sig_ap_rst_n 				<= (not hold_outputs) and ap_rst_n; -- Also hold reset when isolated...
    sig_m_axi_mem_AWREADY 		<= m_axi_mem_AWREADY 	;
	sig_m_axi_mem_WREADY 		<= m_axi_mem_WREADY 	;
	sig_m_axi_mem_ARREADY 		<= m_axi_mem_ARREADY 	;
	sig_m_axi_mem_RVALID 		<= m_axi_mem_RVALID 	;
    sig_m_axi_mem_RDATA 		<= m_axi_mem_RDATA 	;
    sig_m_axi_mem_RLAST 		<= m_axi_mem_RLAST 	;
    sig_m_axi_mem_RID 			<= m_axi_mem_RID 		;
    sig_m_axi_mem_RRESP 		<= m_axi_mem_RRESP 	;
    sig_m_axi_mem_BVALID 		<= m_axi_mem_BVALID 	;
    sig_m_axi_mem_BRESP 		<= m_axi_mem_BRESP 	;
    sig_m_axi_mem_BID			<= m_axi_mem_BID		;
    sig_dummy_user <= sig_m_axi_mem_AWUSER or sig_m_axi_mem_WUSER or sig_m_axi_mem_ARUSER;
end architecture rtl;
