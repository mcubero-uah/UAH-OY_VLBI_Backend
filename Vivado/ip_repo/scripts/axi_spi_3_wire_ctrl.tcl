
set core_name "axi_spi_3_wire_ctrl"

file delete -force ip_repo/$core_name ip_repo/$core_name.cache ip_repo/$core_name.hw ip_repo/$core_name.ip_user_files ip_repo/$core_name.sim ip_repo/$core_name.xpr

create_project $core_name ip_repo
set_property board_part em.avnet.com:zed:part0:1.3 [current_project]
set_property target_language VHDL [current_project]
set_property target_simulator XSim [current_project]

set files [glob -nocomplain hdl/$core_name/*.vhd]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

set_property TOP $core_name [current_fileset]

ipx::package_project -root_dir ip_repo/$core_name

set core [ipx::current_core]

set_property VERSION {1.0} $core
set_property NAME $core_name $core
set_property LIBRARY {UAH-OY-Backend} $core
set_property VENDOR {mcubero} $core
set_property VENDOR_DISPLAY_NAME {M. Cubero} $core
set_property COMPANY_URL {https://github.com/mcubero-uah} $core
set family_lifecycle { \
  zynq Production \
  zynquplus Production \
}
set_property SUPPORTED_FAMILIES ${family_lifecycle} [ipx::current_core]

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core

close_project -delete
