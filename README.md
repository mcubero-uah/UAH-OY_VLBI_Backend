# UAH-OY VLBI Backend
This repository provides the source code of the FPGA-based VLBI digital Backend proposed in the Master's Degree Thesis [Design of an FPGA-based Digital Backend with VDIF formatter for radio astronomy signals](https://ebuah.uah.es/dspace/handle/10017/58428).

## Repository structure
The repository is structured as follows

### Matlab
This directory includes the Matlab code of the function VDIF_getsecondsfromepoch for the calculation of seconds from epoch (see memory), of the UDP server script that emulates the operation of the control computer to send the seconds from the reference epoch to the UDP client (SoC) and, subsequently, the UDP data recording. 
Both the function and the script have been validated in Matlab R2020b.

It also includes the complete sample exposed as an example in memory of some data captured with the system (Data_cap_12_07_18_39h.m).

### Vivado
This directory provides the Vivado/Xilinx SDK project of the designed SoC, targeting the Zedboard platform. It also includes the IP repository containing the custom IP cores used in the project. 

## Building the Vivado Project
To build the project, clone the repository, open the Vivado GUI and move to the Vivado directory inside the root folder. 
To do that, you can use the cd command in the TCL console.
Subsequently, run the following TCL command in the TCL console: 
```tcl
source scripts/zedboard_UAHOY_backend.tcl
```

To run the provided bare-metal software application, generate the bitstream of the project, export the hardware platform, create a Xilinx SDK project, and include the provided source within sw directory (including the linker script, whic suitably set up the reserved memory region for the DMA controller).

## Publication
If you use this design, cite the work: 
```bibtex
@book{CuberoVacas2023,
  title={Diseño de un Backend digital basado en un dispositivo FPGA con formateador VDIF para señales de radioastronomía},
  author={Cubero Vacas, Miguel},
  year={2023},
publisher = "Universidad de Alcalá",
}

```