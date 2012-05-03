# Build with or without MPI, for now do this rather compiling a
# parallel and non parallel version
option(VTK_COSMO_USE_MPI "Build Cosmo with MPI" OFF)
mark_as_advanced(VTK_COSMO_USE_MPI)

if(VTK_COSMOS_USE_MPI)
  find_package(MPI REQUIRED)
  include_directories(${MPI_INCLUDE_PATH})
else()
  add_definitions(-DUSE_SERIAL_COSMO)
endif()

set(Module_SRCS
  vtkPCosmoReader.cxx
  vtkPCosmoHaloFinder.cxx
  )

vtk_module_library(vtkFiltersCosmo ${Module_SRCS})
