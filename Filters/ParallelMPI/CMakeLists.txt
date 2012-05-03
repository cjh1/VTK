find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

set(Module_SRCS
  vtkDistributedDataFilter.cxx
  )

vtk_module_library(vtkFiltersParallelMPI ${Module_SRCS})
