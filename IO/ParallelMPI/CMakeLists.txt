find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

# FIXME: To be removed when #ifdef's have been removed
set(${vtk-module}_EXPORT_CODE "#define VTK_USE_MPI")

set(Module_SRCS
  vtkMPIImageReader.cxx
  vtkPNrrdReader.cxx
  )

vtk_module_library(vtkIOParallelMPI ${Module_SRCS})
