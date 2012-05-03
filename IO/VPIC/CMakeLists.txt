# Build with or without MPI, for now do this rather compiling a
# parallel and non parallel version
option(VTK_VPIC_USE_MPI "Build VPIC with MPI" OFF)
mark_as_advanced(VTK_VPIC_USE_MPI)

if(VTK_VPIC_USE_MPI)
  find_package(MPI REQUIRED)
  include_directories(${MPI_INCLUDE_PATH})
endif()

set(Module_SRCS
  vtkVPICReader.cxx
  )

vtk_module_library(vtkIOVPIC ${Module_SRCS})
