vtk_module(vtkIOParallel
  GROUPS
    MPI
  DEPENDS
    vtkParallelCore
    vtkFiltersParallel
    vtkIOParallelMPI
    vtkIONetCDF
    vtkexodusII
#    vtkVPIC
  TEST_DEPENDS
    vtkTestingCore
  )
