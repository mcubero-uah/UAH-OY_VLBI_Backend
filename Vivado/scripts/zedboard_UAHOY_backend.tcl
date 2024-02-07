file delete -force zedboard_UAHOY_backend ip_repo/ip_repo/axi_spi_3_wire_ctrl ip_repo/ip_repo/axi_sync ip_repo/ip_repo/tlast_gen_axi4

set script_dir [file dirname [file normalize [info script]]]
set project_dir [file dirname [file dirname [file normalize [info script]]]]
set project_name "zedboard_UAHOY_backend"

set ip_path_dir "./ip_repo" 

# Build IP cores
cd $ip_path_dir
source scripts/build_ips.tcl

# Create project
cd $project_dir

create_project $project_name $project_dir/$project_name -part xc7z020clg484-1
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]

set_property ip_repo_paths {"ip_repo"} [current_project]
update_ip_catalog -rebuild

set files [glob -nocomplain src/*.vhd]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

source $script_dir/zedboard_UAHOY_backend_bd.tcl

#make core hireachy
add_files -fileset constrs_1 -norecurse $project_dir/constraints/system.xdc

validate_bd_design
make_wrapper -files [get_files $project_dir/$project_name/${project_name}.srcs/sources_1/bd/${project_name}/${project_name}.bd] -top
add_files -norecurse $project_dir/$project_name/${project_name}.srcs/sources_1/bd/${project_name}/hdl/${project_name}_wrapper.v
set_property top ${project_name}_wrapper [current_fileset]
update_compile_order -fileset sources_1
save_bd_design
# close_project
# exit
