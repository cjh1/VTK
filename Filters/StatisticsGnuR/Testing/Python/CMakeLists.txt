if(VTK_PYTHON_EXE)
  set(tests
    testrcalculatorfilter
    )
#  foreach(tfile ${tests})
#    vtk_add_test_python(${tfile}.py NO_RT NO_OUTPUT NO_DATA)
#  endforeach()
else()
  message(FATAL_ERROR "No Python tests added!")
endif()
