# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.cache/wt [current_project]
set_property parent.project_path D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo d:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_mem D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/otter_memory.mem
read_verilog -library xil_defaultlib -sv {
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/ALU.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/SevSeg/BCD.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/Branch_Address_Generator.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/Branch_Condition_Generator.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/CU_DCDR.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/SevSeg/CathodeDriver.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/new/Data_CU.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/Immed_Gen.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/new/OTTER_PIPELINE_MCU.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/Program_Counter.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/Reg_File.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/SevSeg/SevSegDisp.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/imports/Downloads/bram_dualport_pipeline.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/debounce_one_shot.sv
  D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/sources_1/SRC/OTTER_Wrapper.sv
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/constrs_1/imports/new/constraints.xdc
set_property used_in_implementation false [get_files D:/Jenna/Classes/Vivado/333_Optimized_OTTER/333_Optimized_OTTER.srcs/constrs_1/imports/new/constraints.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top OTTER_Wrapper -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef OTTER_Wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file OTTER_Wrapper_utilization_synth.rpt -pb OTTER_Wrapper_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]