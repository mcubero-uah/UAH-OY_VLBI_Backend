# Obtener la lista de archivos .tcl en la carpeta actual excluyendo "build_ips.tcl"

set tcl_files [glob -nocomplain scripts/*.tcl] 

# Iterar sobre cada archivo y ejecutarlo
foreach file $tcl_files {
    if {$file=="scripts/build_ips.tcl"} {

    } else {
    source $file
    puts "Ejecutando: $file"
    }
    
    
 }

puts "Todos los archivos .tcl han sido ejecutados."
puts $tcl_files
