# this file is used directly from VTK/CMakeLists.txt, not from VTK/Wrapping/CMakeLists.txt

# Defined local options to add to VTK Tcl interpreter
#
# Example of such options are:
#   VTK_EXTRA_TCL_WRAPPING_CODE which should define extra code that will be
#   added to vtkTkAppInitConfigure.h. This code may include something like
#
#
#   extern "C" int Vtkmyspecialtcl_Init(Tcl_Interp *interp);
#   #define VTK_EXTRA_TCL_INIT \
#     if (Vtkmyspecialtcl_Init(interp) == TCL_ERROR) \
#       {
#       return TCL_ERROR;
#       }
#
#   and
#
#   SET(VTK_EXTRA_TCL_LIBRARIES ${VTK_EXTRA_TCL_LIBRARIES} vtkMySpecialTCL)

# Set if the tcl/tk libs are static
option(VTK_TCL_TK_STATIC "Build with static Tcl/Tk support. TCL_LIBRARY and TK_LIBRARY must point to the corresponding Tcl/Tk static libraries (example, tcl85sx.lib, tk85sx.lib)." OFF)
mark_as_advanced(VTK_TCL_TK_STATIC)

# Use Tk Toolkit with Tcl
INCLUDE(vtkDependentOption)

set(VTK_CAN_USE_TK OFF)
set(VTK_USE_TK_DEFAULT ON)
if(VTK_WRAP_PYTHON OR VTK_WRAP_TCL)
  if(NOT VTK_DISABLE_TK_INIT)
    set(VTK_CAN_USE_TK ON)
    if(APPLE)
      if(OSX_SDK_VERSION)
        if(${OSX_SDK_VERSION} VERSION_LESS "10.6")
          # Until OS X 10.6, building Tk with Cocoa was not possible
          if(VTK_USE_COCOA)
            set(VTK_CAN_USE_TK OFF)
          endif()
        else()
          # For OS X 10.6, the default system Tk is Cocoa, not Carbon
          if(VTK_USE_CARBON)
            set(VTK_USE_TK_DEFAULT OFF)
          endif()
        endif()
      endif()
    endif()
  endif()
endif()
vtk_dependent_option(VTK_USE_TK "Build VTK with Tk support"
                     ${VTK_USE_TK_DEFAULT} "VTK_CAN_USE_TK" OFF)

CONFIGURE_FILE(
  ${VTK_SOURCE_DIR}/Wrapping/Tcl/vtkTkAppInitConfigure.h.in
  ${VTK_BINARY_DIR}/Wrapping/Tcl/vtkTkAppInitConfigure.h
  @ONLY IMMEDIATE
)

get_property(VTK_TCL_WRAPPED GLOBAL PROPERTY VTK_TCL_WRAPPED)
# Format the list in a way Tcl expects it
unset(VTK_TCL_WRAPPED_MODULES)
foreach(module ${VTK_TCL_WRAPPED})
  string(REGEX REPLACE "^vtk" "" tcl_module ${module})
  if("${tcl_module}" STREQUAL "RenderingContext2D")
    set(tcl_module "RenderingContextIID")
  elseif("${tcl_module}" STREQUAL "ViewsContext2D")
    set(tcl_module "ViewsContextIID")
  endif()
  set(VTK_TCL_WRAPPED_MODULES "${VTK_TCL_WRAPPED_MODULES} ${tcl_module}")
endforeach()

IF (NOT TCL_LIBRARY)
  MESSAGE("VTK_WRAP_TCL is ON, but the Tcl library was not found.  Please set TCL_LIBRARY." "Error")
ENDIF (NOT TCL_LIBRARY)

include(${VTK_SOURCE_DIR}/Wrapping/Tcl/vtkDetermineTkResources.cmake)

IF (WIN32)
  IF (NOT BORLAND)
    IF(NOT CYGWIN)
      IF(VTK_USE_TK)
        INCLUDE_DIRECTORIES("${VTK_TK_RESOURCES_DIR}")
      ENDIF(VTK_USE_TK)

      CONFIGURE_FILE(
        ${CMAKE_CURRENT_SOURCE_DIR}/resources/vtk.rc.in
        ${CMAKE_CURRENT_BINARY_DIR}/resources/vtk.rc)
      INCLUDE_DIRECTORIES(
        "${CMAKE_CURRENT_SOURCE_DIR}/resources"
        "${CMAKE_CURRENT_BINARY_DIR}/resources"
        )
      SET(VTK_EXE_RESOURCE_FILES
        "${CMAKE_CURRENT_BINARY_DIR}/resources/vtk.rc")
    ENDIF(NOT CYGWIN)
  ENDIF (NOT BORLAND)
ENDIF (WIN32)

find_package(TCL)

include_directories(
  ${CMAKE_CURRENT_BINARY_DIR}
  ${TCL_INCLUDE_PATH}
  )

if(VTK_USE_TK)
  include_directories(
    ${TK_INCLUDE_PATH}
    ${TK_XLIB_PATH}
  )
endif(VTK_USE_TK)

# Create the vtk Tcl wrapper executable.
VTK_ADD_EXECUTABLE(vtk vtkTkAppInit.cxx ${VTK_EXE_RESOURCE_FILES})


IF(VTK_USE_CARBON)
  FIND_PROGRAM(VTK_APPLE_RESOURCE Rez /Developer/Tools)
  IF(VTK_APPLE_RESOURCE)
    ADD_CUSTOM_COMMAND(
      SOURCE vtk
      COMMAND ${VTK_APPLE_RESOURCE}
      ARGS Carbon.r -o ${VTK_EXECUTABLE_DIR}/vtk
      TARGET vtk
      )
  ENDIF(VTK_APPLE_RESOURCE)
ENDIF(VTK_USE_CARBON)

# Link to TCL static libraries
if(BUILD_SHARED_LIBS)
  # vtkCommonCoreTCL is required even for shared builds
  # to link the vtkTclUtil object - FIXME ??
  target_link_libraries(vtk vtkCommonCoreTCL)
else()
  foreach(module ${VTK_TCL_WRAPPED})
    if("${module}" STREQUAL "vtkRenderingContext2D")
      set(module "vtkRenderingContextIID")
    elseif("${module}" STREQUAL "vtkViewsContext2D")
      set(module "vtkViewsContextIID")
    endif()
    target_link_libraries(vtk ${module}TCL)
  endforeach()
endif()

if(VTK_USE_TK)
  target_link_libraries(vtk ${VTK_TK_LIBRARIES})
endif(VTK_USE_TK)

if(VTK_INSTALL_RUNTIME AND VTK_BUILD_FORWARDING_EXECUTABLES)
  install(TARGETS vtk
    EXPORT ${VTK_INSTALL_EXPORT_NAME}
    RUNTIME DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT RuntimeExecutables # .exe, .dll
    LIBRARY DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT RuntimeLibraries # .so, mod.dll
    ARCHIVE DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT Development      # .a, .lib
    )
  install(TARGETS vtk${VTK_EXE_SUFFIX}
    EXPORT ${VTK_INSTALL_EXPORT_NAME}
    RUNTIME DESTINATION ${VTK_INSTALL_RUNTIME_DIR} COMPONENT RuntimeExecutables # .exe, .dll
    LIBRARY DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT RuntimeLibraries # .so, mod.dll
    ARCHIVE DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT Development      # .a, .lib
    )
elseif(VTK_INSTALL_RUNTIME)
  install(TARGETS vtk
    EXPORT ${VTK_INSTALL_EXPORT_NAME}
    RUNTIME DESTINATION ${VTK_INSTALL_RUNTIME_DIR} COMPONENT RuntimeExecutables # .exe, .dll
    LIBRARY DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT RuntimeLibraries # .so, mod.dll
    ARCHIVE DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT Development      # .a, .lib
    )
endif()

# Create the pvtk Tcl wrapper executable with MPI support.
IF (VTK_USE_PARALLEL)
  IF (VTK_USE_MPI)
    INCLUDE_DIRECTORIES(${MPI_INCLUDE_PATH})
    IF (MPI_LIBRARY)
      SET(MPI_LIBRARIES ${MPI_LIBRARY})
    ENDIF (MPI_LIBRARY)
    IF (MPI_EXTRA_LIBRARY)
      SET(MPI_LIBRARIES ${MPI_LIBRARIES} "${MPI_EXTRA_LIBRARY}")
    ENDIF (MPI_EXTRA_LIBRARY)

    VTK_ADD_EXECUTABLE(pvtk vtkParaTkAppInit.cxx ${VTK_EXE_RESOURCE_FILES})
    IF(VTK_USE_CARBON)
      FIND_PROGRAM(VTK_APPLE_RESOURCE Rez /Developer/Tools)
      IF(VTK_APPLE_RESOURCE)
        ADD_CUSTOM_COMMAND(
          SOURCE pvtk
          COMMAND ${VTK_APPLE_RESOURCE}
          ARGS Carbon.r -o ${VTK_EXECUTABLE_DIR}/pvtk
          TARGET pvtk
          )
      ENDIF(VTK_APPLE_RESOURCE)
    ENDIF(VTK_USE_CARBON)

    TARGET_LINK_LIBRARIES (pvtk
      ${MPI_LIBRARIES}
    )

    # Link to TCL static libraries
    if(BUILD_SHARED_LIBS)
      # vtkCommonCoreTCL is required even for shared builds
      # to link the vtkTclUtil object - FIXME ??
      target_link_libraries(vtk vtkCommonCoreTCL)
    else()
      foreach(module ${VTK_TCL_WRAPPED})
        if("${module}" STREQUAL "vtkRenderingContext2D")
          set(module "vtkRenderingContextIID")
        elseif("${module}" STREQUAL "vtkViewsContext2D")
          set(module "vtkViewsContextIID")
        endif()
        target_link_libraries(pvtk ${module}TCL)
      endforeach()
    endif()

    IF(VTK_INSTALL_RUNTIME)
      INSTALL(TARGETS pvtk
        EXPORT ${VTK_INSTALL_EXPORT_NAME}
        RUNTIME DESTINATION ${VTK_INSTALL_BIN_DIR_CM24} COMPONENT RuntimeExecutables # .exe, .dll
        LIBRARY DESTINATION ${VTK_INSTALL_LIB_DIR_CM24} COMPONENT RuntimeLibraries # .so, mod.dll
        ARCHIVE DESTINATION ${VTK_INSTALL_LIB_DIR_CM24} COMPONENT Development      # .a, .lib
        )
    ENDIF()
  ENDIF (VTK_USE_MPI)
ENDIF (VTK_USE_PARALLEL)

if(NOT VTK_INSTALL_NO_DOCUMENTATION)
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/README"
    DESTINATION ${VTK_INSTALL_TCL_DIR}
    COMPONENT RuntimeLibraries)
endif()
if(NOT VTK_INSTALL_NO_DEVELOPMENT)
  install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/vtktcl.c"
    DESTINATION ${VTK_INSTALL_TCL_DIR}
    COMPONENT Development)
endif()

# Configure the Tcl package index files for the build tree.
set(VTK_TCL_SCRIPT_DIR "${VTK_BINARY_DIR}/Wrapping/Tcl")

set(VTK_TCL_LIBNAME_PREFIX "${CMAKE_SHARED_LIBRARY_PREFIX}")
set(VTK_TCL_CONFIGURATION_TYPES ${CMAKE_CONFIGURATION_TYPES})

if(VTK_TCL_CONFIGURATION_TYPES)
  foreach(config ${VTK_TCL_CONFIGURATION_TYPES})
    set(VTK_TCL_LIBRARY_DIR "${LIBRARY_OUTPUT_PATH}/${config}")
    configure_file(${VTK_SOURCE_DIR}/Wrapping/Tcl/pkgIndex.tcl.in
                   ${VTK_BINARY_DIR}/Wrapping/Tcl/${config}/pkgIndex.tcl
                   @ONLY IMMEDIATE)
  endforeach()
else()
  set(VTK_TCL_LIBRARY_DIR "${LIBRARY_OUTPUT_PATH}")
  configure_file(${VTK_SOURCE_DIR}/Wrapping/Tcl/pkgIndex.tcl.in
                 ${VTK_BINARY_DIR}/Wrapping/Tcl/pkgIndex.tcl
                 @ONLY IMMEDIATE)
endif()

# A few hand coded bits of Tcl to glue things together.
macro(configure_tcl_files)
  foreach(file ${ARGN})
    configure_file(${file}.tcl.in "${VTK_TCL_HOME}/${file}.tcl" @ONLY IMMEDIATE)
  endforeach()
endmacro()

macro(copy_tcl_files)
  foreach(file ${ARGN})
    configure_file(${file}.tcl "${VTK_TCL_HOME}/${file}.tcl" COPYONLY)
  endforeach()
endmacro()

configure_tcl_files(
  vtkbase/vtkbase
  vtk/vtk
  vtktesting/vtktesting
  vtktesting/grab
  vtkinteraction/vtkinteraction
  )
copy_tcl_files(
  vtktesting/backdrop
  vtktesting/colors
  vtktesting/mccases
  vtkinteraction/bindings
  vtkinteraction/bindings-iw
  vtkinteraction/bindings-rw
  vtkinteraction/Interactor
  vtkinteraction/setget
  )

if(NOT VTK_INSTALL_NO_RUNTIME)
  install(DIRECTORY ${VTK_TCL_HOME}/vtk ${VTK_TCL_HOME}/vtkbase
    ${VTK_TCL_HOME}/vtktesting ${VTK_TCL_HOME}/vtkinteraction
    DESTINATION ${VTK_INSTALL_TCL_DIR}
    COMPONENT RuntimeLibraries)
endif()

# We must write out a file for each wrapped module to load the SO.
foreach(module ${VTK_TCL_WRAPPED})
  string(TOLOWER ${module} module_lc)
  if(module_lc STREQUAL "vtkrenderingcontext2d")
    set(module_lc "vtkrenderingcontextiid")
    set(module "vtkRenderingContextIID")
  elseif(module_lc STREQUAL "vtkviewscontext2d")
    set(module_lc "vtkviewscontextiid")
    set(module "vtkViewsContextIID")
  endif()
  configure_file(vtkmodule.tcl.in
    "${VTK_TCL_HOME}/${module_lc}/${module_lc}.tcl" @ONLY IMMEDIATE)
  if(NOT VTK_INSTALL_NO_RUNTIME)
    install(FILES
      "${VTK_TCL_HOME}/${module_lc}/${module_lc}.tcl"
      DESTINATION ${VTK_INSTALL_TCL_DIR}/${module_lc}
      COMPONENT RuntimeLibraries)
  endif()
endforeach()

# Configure the Tcl package index file for the install tree.
SET(VTK_TCL_SCRIPT_DIR "[file dirname [info script]]")
IF(UNIX)
  SET(VTK_TCL_LIBRARY_DIR "[file dirname [file dirname [file dirname [info script]]]]")
ELSE(UNIX)
  SET(VTK_TCL_LIBRARY_DIR
      "[file join [file dirname [file dirname [file dirname [file dirname [info script]]]]] bin]")
ENDIF(UNIX)
configure_file(${VTK_SOURCE_DIR}/Wrapping/Tcl/pkgIndex.tcl.in
               ${VTK_BINARY_DIR}/Wrapping/Tcl/Install/Hide/pkgIndex.tcl
               @ONLY IMMEDIATE)
IF(NOT VTK_INSTALL_NO_RUNTIME)
  INSTALL(FILES
    ${VTK_BINARY_DIR}/Wrapping/Tcl/Install/Hide/pkgIndex.tcl
    DESTINATION ${VTK_INSTALL_TCL_DIR}
    COMPONENT RuntimeLibraries)
ENDIF()

# If the wrapped tcl libs are static we have to initialized them.
if(NOT BUILD_SHARED_LIBS)
  file(REMOVE ${VTK_BINARY_DIR}/Wrapping/Tcl/vtktcl_static_prototypes.h ${VTK_BINARY_DIR}/Wrapping/Tcl/vtktcl_static_packages.h)
  foreach(module ${VTK_TCL_WRAPPED})
    if("${module}" STREQUAL "vtkRenderingContext2D")
      set(module "vtkRenderingContextIID")
    elseif("${module}" STREQUAL "vtkViewsContext2D")
      set(module "vtkViewsContextIID")
    endif()
    string(TOLOWER ${module} module_lc)
    string(REGEX REPLACE "^vtk" "Vtk" module_lc ${module_lc})
    file(APPEND ${VTK_BINARY_DIR}/Wrapping/Tcl/vtktcl_static_prototypes.h "extern \"C\" int ${module_lc}tcl_Init(Tcl_Interp *interp);\n")
    file(APPEND ${VTK_BINARY_DIR}/Wrapping/Tcl/vtktcl_static_packages.h "Tcl_StaticPackage(0, \"${module}Tcl\", ${module_lc}tcl_Init, NULL);\n")
  endforeach()
endif()

# Allow the user to customize their build with some local options
#
INCLUDE (${VTK_BINARY_DIR}/Wrapping/Tcl/LocalUserOptions.cmake OPTIONAL)
INCLUDE (${VTK_SOURCE_DIR}/Wrapping/Tcl/LocalUserOptions.cmake OPTIONAL)
