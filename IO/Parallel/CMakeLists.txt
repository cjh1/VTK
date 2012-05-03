find_package(MPI REQUIRED)
include_directories(${MPI_INCLUDE_PATH})

# FIXME: To be removed when #ifdef's have been removed
set(${vtk-module}_EXPORT_CODE "#define VTK_USE_MPI")

set(Module_SRCS
  vtkEnSightWriter.cxx
  # vtkExodusIIWriter.cxx needs vtkMultiProcessController
  vtkPChacoReader.cxx
  vtkPDataSetReader.cxx
  vtkPDataSetWriter.cxx
  vtkPImageWriter.cxx
  vtkPNrrdReader.cxx
  vtkPOpenFOAMReader.cxx
  vtkPSLACReader.cxx
  vtkWindBladeReader.cxx
  vtkXMLPHierarchicalBoxDataWriter.cxx
  vtkXMLPMultiBlockDataWriter.cxx
  )

vtk_module_library(vtkIOParallel ${Module_SRCS})
