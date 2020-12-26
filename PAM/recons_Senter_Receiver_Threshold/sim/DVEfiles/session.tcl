# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Dec 20 16:43:19 2020
# Designs open: 1
#   Sim: /home/eda/feifan/vlc_plat/PAM/recons_Senter_Receiver/sim/simv
# Toplevel windows open: 1
# 	TopLevel.1
#   Source.1: tb_senter_receiver
#   Group count = 1
#   Group uut_demodulation signal count = 66
# End_DVE_Session_Save_Info

# DVE version: O-2018.09-SP2_Full64
# DVE build date: Feb 28 2019 23:39:41


#<Session mode="Full" path="/home/eda/feifan/vlc_plat/PAM/recons_Senter_Receiver/sim/DVEfiles/session.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set -value 1000000

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{98 163} {1478 880}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 439]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 439
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 438} {height 460} {dock_state left} {dock_on_new_line true} {child_hier_colhier 491} {child_hier_coltype 111} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 221]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 221
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 460
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 220} {height 460} {dock_state left} {dock_on_new_line true} {child_data_colvariable 314} {child_data_colvalue 13} {child_data_coltype 56} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 151]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1381
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 151
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1380} {height 150} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state normal -rect {{0 0} {196 340}}
gui_update_layout -id ${Source.1} {{left 0} {top 0} {width 201} {height 365} {show_state normal} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{}}
gui_set_env SIMSETUP::SIMEXE {./simv}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {/home/eda/feifan/vlc_plat/PAM/recons_Senter_Receiver/sim/simv}] } {
gui_sim_run Ucli -exe simv -args { -ucligui} -dir /home/eda/feifan/vlc_plat/PAM/recons_Senter_Receiver/sim -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 1ps
gui_set_time_units 1ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups


set _session_group_1 uut_demodulation
gui_sg_create "$_session_group_1"
set uut_demodulation "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { tb_senter_receiver.uut_receiver.uut_demodulation.rec_pilot_r tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_0 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_1 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_2 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_3 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_4 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_5 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_6 tb_senter_receiver.uut_receiver.uut_demodulation.pam_data_7 tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tvalid_r tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tdata tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_10 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_11 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_12 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_13 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_14 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_15 tb_senter_receiver.uut_receiver.uut_demodulation.addr_pilot_w tb_senter_receiver.uut_receiver.uut_demodulation.addr_pilot tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tkeep tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tready tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_DATA tb_senter_receiver.uut_receiver.uut_demodulation.clk tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result tb_senter_receiver.uut_receiver.uut_demodulation.IDLE tb_senter_receiver.uut_receiver.uut_demodulation.cnt_rec_data tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_KEEP tb_senter_receiver.uut_receiver.uut_demodulation.syn_demod_ready tb_senter_receiver.uut_receiver.uut_demodulation.syn_demod_valid_r tb_senter_receiver.uut_receiver.uut_demodulation.pilot_mem tb_senter_receiver.uut_receiver.uut_demodulation.i tb_senter_receiver.uut_receiver.uut_demodulation.rst_n tb_senter_receiver.uut_receiver.uut_demodulation.flag_S0_over tb_senter_receiver.uut_receiver.uut_demodulation.LENGTH_DATA tb_senter_receiver.uut_receiver.uut_demodulation.cur_state tb_senter_receiver.uut_receiver.uut_demodulation.flag_IDLE_over tb_senter_receiver.uut_receiver.uut_demodulation.syn_demod_data_signed tb_senter_receiver.uut_receiver.uut_demodulation.cnt_rec_pam tb_senter_receiver.uut_receiver.uut_demodulation.PAM_ORDER tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_0 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_1 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_2 tb_senter_receiver.uut_receiver.uut_demodulation.nxt_state tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tvalid tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_3 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_4 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_5 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_6 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_7 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_8 tb_senter_receiver.uut_receiver.uut_demodulation.S0 tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_9 tb_senter_receiver.uut_receiver.uut_demodulation.S1 tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_ADDR_REC_DATA tb_senter_receiver.uut_receiver.uut_demodulation.div_enable tb_senter_receiver.uut_receiver.uut_demodulation.AD_CVER_WIDTH tb_senter_receiver.uut_receiver.uut_demodulation.div_pilot tb_senter_receiver.uut_receiver.uut_demodulation.syn_demod_valid tb_senter_receiver.uut_receiver.uut_demodulation.cmp_result_r tb_senter_receiver.uut_receiver.uut_demodulation.rec_pilot_rr tb_senter_receiver.uut_receiver.uut_demodulation.cnt_rec_pam_r tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tlast tb_senter_receiver.uut_receiver.uut_demodulation.m_axi_tlast_r tb_senter_receiver.uut_receiver.uut_demodulation.LEGTHN_PILOT tb_senter_receiver.uut_receiver.uut_demodulation.flag_S1_over tb_senter_receiver.uut_receiver.uut_demodulation.syn_demod_data }
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_DATA}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_DATA}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.IDLE}
gui_set_radix -radix {unsigned} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.IDLE}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_KEEP}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_AXI_KEEP}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.i}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.i}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.LENGTH_DATA}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.LENGTH_DATA}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.PAM_ORDER}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.PAM_ORDER}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.S0}
gui_set_radix -radix {unsigned} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.S0}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.S1}
gui_set_radix -radix {unsigned} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.S1}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_ADDR_REC_DATA}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.WIDTH_ADDR_REC_DATA}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.AD_CVER_WIDTH}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.AD_CVER_WIDTH}
gui_set_radix -radix {decimal} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.LEGTHN_PILOT}
gui_set_radix -radix {twosComplement} -signals {Sim:tb_senter_receiver.uut_receiver.uut_demodulation.LEGTHN_PILOT}

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 167000



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} tb_senter_receiver}
catch {gui_list_expand -id ${Hier.1} tb_senter_receiver.uut_receiver}
catch {gui_list_select -id ${Hier.1} {tb_senter_receiver.uut_receiver.uut_demodulation}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {tb_senter_receiver.uut_receiver.uut_demodulation}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active tb_senter_receiver /home/eda/feifan/vlc_plat/PAM/recons_Senter_Receiver/sim/../tb/tb_senter_receiver.v
gui_view_scroll -id ${Source.1} -vertical -set 342
gui_src_set_reusable -id ${Source.1}
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
#</Session>

