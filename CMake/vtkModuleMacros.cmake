get_filename_component(_VTKModuleMacros_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

set(_VTKModuleMacros_DEFAULT_LABEL "VTKModular")

include(${_VTKModuleMacros_DIR}/vtkModuleAPI.cmake)
include(GenerateExportHeader)
include(vtkWrapping)
if(VTK_MAKE_INSTANTIATORS)
  include(vtkMakeInstantiator)
endif()

macro(vtk_module _name)
  vtk_module_check_name(${_name})
  set(vtk-module ${_name})
  set(vtk-module-test ${_name}-Test)
  set(_doing "")
  set(VTK_MODULE_${vtk-module}_DECLARED 1)
  set(VTK_MODULE_${vtk-module-test}_DECLARED 1)
  set(VTK_MODULE_${vtk-module}_DEPENDS "")
  set(VTK_MODULE_${vtk-module}_COMPILE_DEPENDS "")
  set(VTK_MODULE_${vtk-module-test}_DEPENDS "${vtk-module}")
  set(VTK_MODULE_${vtk-module}_IMPLEMENTS "")
  set(VTK_MODULE_${vtk-module}_DESCRIPTION "description")
  set(VTK_MODULE_${vtk-module}_EXCLUDE_FROM_ALL 0)
  set(VTK_MODULE_${vtk-module}_EXCLUDE_FROM_WRAPPING 0)
  foreach(arg ${ARGN})
  if("${arg}" MATCHES "^((|COMPILE_|TEST_|)DEPENDS|DESCRIPTION|IMPLEMENTS|DEFAULT|GROUPS)$")
      set(_doing "${arg}")
    elseif("${arg}" MATCHES "^EXCLUDE_FROM_ALL$")
      set(_doing "")
      set(VTK_MODULE_${vtk-module}_EXCLUDE_FROM_ALL 1)
    elseif("${arg}" MATCHES "^EXCLUDE_FROM_WRAPPING$")
      set(_doing "")
      set(VTK_MODULE_${vtk-module}_EXCLUDE_FROM_WRAPPING 1)
    elseif("${arg}" MATCHES "^[A-Z][A-Z][A-Z]$" AND
           NOT "${arg}" MATCHES "^(ON|OFF|MPI)$")
      set(_doing "")
      message(AUTHOR_WARNING "Unknown argument [${arg}]")
    elseif("${_doing}" MATCHES "^DEPENDS$")
      list(APPEND VTK_MODULE_${vtk-module}_DEPENDS "${arg}")
    elseif("${_doing}" MATCHES "^TEST_DEPENDS$")
      list(APPEND VTK_MODULE_${vtk-module-test}_DEPENDS "${arg}")
    elseif("${_doing}" MATCHES "^COMPILE_DEPENDS$")
      list(APPEND VTK_MODULE_${vtk-module}_COMPILE_DEPENDS "${arg}")
    elseif("${_doing}" MATCHES "^DESCRIPTION$")
      set(_doing "")
      set(VTK_MODULE_${vtk-module}_DESCRIPTION "${arg}")
    elseif("${_doing}" MATCHES "^IMPLEMENTS$")
      list(APPEND VTK_MODULE_${vtk-module}_DEPENDS "${arg}")
      list(APPEND VTK_MODULE_${vtk-module}_IMPLEMENTS "${arg}")
    elseif("${_doing}" MATCHES "^DEFAULT")
      message(FATAL_ERROR "Invalid argument [DEFAULT]")
    elseif("${_doing}" MATCHES "^GROUPS")
      # Groups control larger groups of modules.
      if(NOT DEFINED VTK_GROUP_${arg}_MODULES)
        list(APPEND VTK_GROUPS ${arg})
      endif()
      list(APPEND VTK_GROUP_${arg}_MODULES ${vtk-module})
    else()
      set(_doing "")
      message(AUTHOR_WARNING "Unknown argument [${arg}]")
    endif()
  endforeach()
  list(SORT VTK_MODULE_${vtk-module}_DEPENDS) # Deterministic order.
  set(VTK_MODULE_${vtk-module}_LINK_DEPENDS
    "${VTK_MODULE_${vtk-module}_DEPENDS}")
  list(APPEND VTK_MODULE_${vtk-module}_DEPENDS
    ${VTK_MODULE_${vtk-module}_COMPILE_DEPENDS})
  unset(VTK_MODULE_${vtk-module}_COMPILE_DEPENDS)
  list(SORT VTK_MODULE_${vtk-module}_DEPENDS) # Deterministic order.
  list(SORT VTK_MODULE_${vtk-module-test}_DEPENDS) # Deterministic order.
  list(SORT VTK_MODULE_${vtk-module}_IMPLEMENTS) # Deterministic order.
endmacro()

macro(vtk_module_check_name _name)
  if( NOT "${_name}" MATCHES "^[a-zA-Z][a-zA-Z0-9]*$")
    message(FATAL_ERROR "Invalid module name: ${_name}")
  endif()
endmacro()

macro(vtk_module_impl)
  include(module.cmake) # Load module meta-data

  vtk_module_config(_dep ${VTK_MODULE_${vtk-module}_DEPENDS})
  if(_dep_INCLUDE_DIRS)
    include_directories(${_dep_INCLUDE_DIRS})
    # This variable is used in vtkWrapping.cmake
    set(${vtk-module}_DEPENDS_INCLUDE_DIRS ${_dep_INCLUDE_DIRS})
  endif()
  if(_dep_LIBRARY_DIRS)
    link_directories(${_dep_LIBRARY_DIRS})
  endif()

  if(NOT DEFINED ${vtk-module}_LIBRARIES)
    set(${vtk-module}_LIBRARIES "")
    foreach(dep IN LISTS VTK_MODULE_${vtk-module}_LINK_DEPENDS)
      list(APPEND ${vtk-module}_LIBRARIES "${${dep}_LIBRARIES}")
    endforeach()
    if(${vtk-module}_LIBRARIES)
      list(REMOVE_DUPLICATES ${vtk-module}_LIBRARIES)
    endif()
  endif()

  list(APPEND ${vtk-module}_INCLUDE_DIRS
    ${${vtk-module}_BINARY_DIR}
    ${${vtk-module}_SOURCE_DIR}
    )

  if(${vtk-module}_INCLUDE_DIRS)
    include_directories(${${vtk-module}_INCLUDE_DIRS})
  endif()
  if(${vtk-module}_SYSTEM_INCLUDE_DIRS)
    include_directories(${${vtk-module}_SYSTEM_INCLUDE_DIRS})
  endif()

  if(${vtk-module}_SYSTEM_LIBRARY_DIRS)
    link_directories(${${vtk-module}_SYSTEM_LIBRARY_DIRS})
  endif()

  if(${vtk-module}_THIRD_PARTY)
    vtk_module_warnings_disable(C CXX)
  endif()

  set(_code "")
  foreach(opt ${${vtk-module}_EXPORT_OPTIONS})
    set(_code "${_code}set(${opt} \"${${opt}}\")\n")
  endforeach()
  if(VTK_MODULE_${vtk-module}_EXCLUDE_FROM_WRAPPING)
    set(_code "${_code}set(${vtk-module}_EXCLUDE_FROM_WRAPPING 1)\n")
  endif()
  if(VTK_MODULE_${vtk-module}_IMPLEMENTS)
    set(_code "${_code}set(${vtk-module}_IMPLEMENTS \"${VTK_MODULE_${vtk-module}_IMPLEMENTS}\")\n")
  endif()
  set(vtk-module-EXPORT_CODE-build "${_code}${${vtk-module}_EXPORT_CODE_BUILD}")
  set(vtk-module-EXPORT_CODE-install "${_code}${${vtk-module}_EXPORT_CODE_INSTALL}")

  set(vtk-module-DEPENDS "${VTK_MODULE_${vtk-module}_DEPENDS}")
  set(vtk-module-LIBRARIES "${${vtk-module}_LIBRARIES}")
  set(vtk-module-INCLUDE_DIRS-build "${${vtk-module}_INCLUDE_DIRS}")
  set(vtk-module-INCLUDE_DIRS-install "\${VTK_INSTALL_PREFIX}/${VTK_INSTALL_INCLUDE_DIR}")
  if(${vtk-module}_SYSTEM_INCLUDE_DIRS)
    list(APPEND vtk-module-INCLUDE_DIRS-build "${${vtk-module}_SYSTEM_INCLUDE_DIRS}")
    list(APPEND vtk-module-INCLUDE_DIRS-install "${${vtk-module}_SYSTEM_INCLUDE_DIRS}")
  endif()
  set(vtk-module-LIBRARY_DIRS "${${vtk-module}_SYSTEM_LIBRARY_DIRS}")
  set(vtk-module-INCLUDE_DIRS "${vtk-module-INCLUDE_DIRS-build}")
  set(vtk-module-EXPORT_CODE "${vtk-module-EXPORT_CODE-build}")
  configure_file(${_VTKModuleMacros_DIR}/vtkModuleInfo.cmake.in ${VTK_MODULES_DIR}/${vtk-module}.cmake @ONLY)
  set(vtk-module-INCLUDE_DIRS "${vtk-module-INCLUDE_DIRS-install}")
  set(vtk-module-EXPORT_CODE "${vtk-module-EXPORT_CODE-install}")
  configure_file(${_VTKModuleMacros_DIR}/vtkModuleInfo.cmake.in CMakeFiles/${vtk-module}.cmake @ONLY)
  install(FILES
    ${${vtk-module}_BINARY_DIR}/CMakeFiles/${vtk-module}.cmake
    DESTINATION ${VTK_INSTALL_PACKAGE_DIR}/Modules
    )
endmacro()

macro(vtk_module_test)
  if(NOT vtk_module_test_called)
    set(vtk_module_test_called 1) # Run once in a given scope.
    include(../../module.cmake) # Load module meta-data
    vtk_module_config(${vtk-module-test}-Cxx ${VTK_MODULE_${vtk-module-test}-Cxx_DEPENDS})
    if(${vtk-module-test}-Cxx_DEFINITIONS)
      set_property(DIRECTORY APPEND PROPERTY COMPILE_DEFINITIONS
        ${${vtk-module-test}-Cxx_DEFINITIONS})
    endif()
    if(${vtk-module-test}-Cxx_INCLUDE_DIRS)
      include_directories(${${vtk-module-test}-Cxx_INCLUDE_DIRS})
    endif()
    if(${vtk-module-test}-Cxx_LIBRARY_DIRS)
      link_directories(${${vtk-module-test}-Cxx_LIBRARY_DIRS})
    endif()
  endif()
endmacro()

macro(vtk_module_warnings_disable)
  foreach(lang ${ARGN})
    if(MSVC)
      string(REGEX REPLACE "(^| )[/-]W[0-4]( |$)" " "
        CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -w")
    elseif(BORLAND)
      set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -w-")
    else()
      set(CMAKE_${lang}_FLAGS "${CMAKE_${lang}_FLAGS} -w")
    endif()
  endforeach()
endmacro()

macro(vtk_target_label _target_name)
  if(vtk-module)
    set(_label ${vtk-module})
  else()
    set(_label ${_VTKModuleMacros_DEFAULT_LABEL})
  endif()
  set_property(TARGET ${_target_name} PROPERTY LABELS ${_label})
endmacro()

macro(vtk_target_name _name)
  set_property(TARGET ${_name} PROPERTY VERSION 1)
  set_property(TARGET ${_name} PROPERTY SOVERSION 1)
  if("${_name}" MATCHES "^[Vv][Tt][Kk]")
    set(_vtk "")
  else()
    set(_vtk "vtk")
    #message(AUTHOR_WARNING "Target [${_name}] does not start in 'vtk'.")
  endif()
  set_property(TARGET ${_name} PROPERTY OUTPUT_NAME ${_vtk}${_name}-${VTK_MAJOR_VERSION}.${VTK_MINOR_VERSION})
endmacro()

macro(vtk_target_export _name)
  if(NOT VTK_INSTALL_NO_LIBRARIES)
    set_property(GLOBAL APPEND PROPERTY VTK_TARGETS ${_name})
  endif()
endmacro()

macro(vtk_target_install _name)
  if(NOT VTK_INSTALL_NO_LIBRARIES)
    install(TARGETS ${_name}
      EXPORT ${VTK_INSTALL_EXPORT_NAME}
      RUNTIME DESTINATION ${VTK_INSTALL_RUNTIME_DIR} COMPONENT RuntimeLibraries
      LIBRARY DESTINATION ${VTK_INSTALL_LIBRARY_DIR} COMPONENT RuntimeLibraries
      ARCHIVE DESTINATION ${VTK_INSTALL_ARCHIVE_DIR} COMPONENT Development
      )
  endif()
endmacro()

macro(vtk_target _name)
  set(_install 1)
  foreach(arg ${ARGN})
    if("${arg}" MATCHES "^(NO_INSTALL)$")
      set(_install 0)
    else()
      message(FATAL_ERROR "Unknown argument [${arg}]")
    endif()
  endforeach()
  vtk_target_name(${_name})
  vtk_target_label(${_name})
  vtk_target_export(${_name})
  if(_install)
    vtk_target_install(${_name})
  endif()
endmacro()

function(vtk_add_library name)
  add_library(${name} ${ARGN} ${headers})
  vtk_target(${name})
endfunction()

function(vtk_add_executable name)
  if(UNIX AND VTK_BUILD_FORWARDING_EXECUTABLES)
    vtk_add_executable_with_forwarding(VTK_EXE_SUFFIX ${name} ${ARGN})
    set_property(GLOBAL APPEND PROPERTY VTK_TARGETS ${name})
  else()
    add_executable(${name} ${ARGN})
    set_property(GLOBAL APPEND PROPERTY VTK_TARGETS ${name})
  endif()
endfunction()

macro(vtk_module_test_executable test_exe_name)
  vtk_module_test()
  # No forwarding or export for test executables.
  add_executable(${test_exe_name} ${ARGN})
  target_link_libraries(${test_exe_name} ${${vtk-module-test}-Cxx_LIBRARIES})
endmacro()

function(vtk_module_library name)
  if(NOT "${name}" STREQUAL "${vtk-module}")
    message(FATAL_ERROR "vtk_module_library must be invoked with module name")
  endif()

  set(${vtk-module}_LIBRARIES ${vtk-module})
  vtk_module_impl()

  set(vtk-module-CLASSES)
  set(vtk-module-ABSTRACT)
  set(vtk-module-WRAP_SPECIAL)

  # Collect header files matching sources.
  set(_hdrs ${${vtk-module}_HDRS})
  foreach(arg ${ARGN})
    get_filename_component(src "${arg}" ABSOLUTE)
    
    string(REGEX REPLACE "\\.(cxx|mm)$" ".h" hdr "${src}")
    if("${hdr}" MATCHES "\\.h$")
      if(EXISTS "${hdr}")
        list(APPEND _hdrs "${hdr}")
        
        get_filename_component(_filename "${hdr}" NAME)
        string(REGEX REPLACE "\\.h$" "" _cls "${_filename}")
    
        get_source_file_property(_wrap_exclude ${src} WRAP_EXCLUDE)
        get_source_file_property(_abstract ${src} ABSTRACT)
        get_source_file_property(_wrap_special ${src} WRAP_SPECIAL)
    
        if(NOT _wrap_exclude)
          list(APPEND vtk-module-CLASSES ${_cls})
        endif()  
        
        if(_abstract)
          set(vtk-module-ABSTRACT "${vtk-module-ABSTRACT}set(${vtk-module}_CLASS_${_cls}_ABSTRACT 1)\n")   
        endif()
    
        if(_wrap_special)
          set(vtk-module-WRAP_SPECIAL "${vtk-module-WRAP_SPECIAL}set(${vtk-module}_CLASS_${_cls}_WRAP_SPECIAL 1)\n")
        endif()
      endif()
    elseif("${src}" MATCHES "\\.txx$")
      list(APPEND _hdrs "${src}")
    endif()
  endforeach()
  list(APPEND _hdrs "${CMAKE_CURRENT_BINARY_DIR}/${vtk-module}Module.h")
  list(REMOVE_DUPLICATES _hdrs)

  # Configure wrapping information for external wrappers
  configure_file(${_VTKModuleMacros_DIR}/vtkModuleClasses.cmake.in ${VTK_MODULES_DIR}/${vtk-module}-Classes.cmake @ONLY)

  # The instantiators are off by default, and only work on wrapped modules.
  if(VTK_MAKE_INSTANTIATORS AND NOT VTK_MODULE_${vtk-module}_EXCLUDE_FROM_WRAPPING)
    string(TOUPPER "${vtk-module}_EXPORT" _export_macro)
    vtk_make_instantiator3(${vtk-module}Instantiator _instantiator_SRCS
      "${ARGN}" ${_export_macro} ${CMAKE_CURRENT_BINARY_DIR}
      ${vtk-module}Module.h)
    list(APPEND _hdrs "${CMAKE_CURRENT_BINARY_DIR}/${vtk-module}Instantiator.h")
  endif()

  vtk_add_library(${vtk-module} ${ARGN} ${_hdrs} ${_instantiator_SRCS})
  foreach(dep IN LISTS VTK_MODULE_${vtk-module}_LINK_DEPENDS)
    target_link_libraries(${vtk-module} ${${dep}_LIBRARIES})
  endforeach()

  # Generate the export macro header for symbol visibility/Windows DLL declspec
  if(${vtk-module}_EXPORT_CODE)
    set(${vtk-module}_EXPORT_CODE "${${vtk-module}_EXPORT_CODE}\n\n")
  endif()
  set(${vtk-module}_EXPORT_CODE
    "${${vtk-module}_EXPORT_CODE}#if defined(${vtk-module}_INCLUDE)
# include ${vtk-module}_INCLUDE
#endif
#if defined(${vtk-module}_AUTOINIT)
# include \"vtkAutoInit.h\"
VTK_AUTOINIT(${vtk-module})
#endif")
  generate_export_header(${vtk-module} EXPORT_FILE_NAME ${vtk-module}Module.h)
  add_compiler_export_flags(my_abi_flags)
  set_property(TARGET ${vtk-module} APPEND
    PROPERTY COMPILE_FLAGS "${my_abi_flags}")

  if(BUILD_TESTING AND PYTHON_EXECUTABLE AND NOT ${vtk-module}_NO_HeaderTest)
    string(TOUPPER "${vtk-module}" MOD)
    add_test(NAME ${vtk-module}.HeaderTest
      COMMAND ${PYTHON_EXECUTABLE} ${VTK_SOURCE_DIR}/Testing/Core/HeaderTesting.py
                                   ${CMAKE_CURRENT_SOURCE_DIR} ${MOD}_EXPORT
      )
  endif()

  # Add the module to the list of wrapped modules if necessary
  vtk_add_wrapping(${vtk-module} "${ARGN}")

  # Figure out which headers to install.
  if(NOT VTK_INSTALL_NO_DEVELOPMENT AND _hdrs)
    install(FILES ${_hdrs}
      DESTINATION ${VTK_INSTALL_INCLUDE_DIR}
      COMPONENT Development
      )
  endif()
endfunction()

macro(vtk_module_third_party _pkg)
  string(TOLOWER "${_pkg}" _lower)
  string(TOUPPER "${_pkg}" _upper)

  set(_includes "")
  set(_libs "")
  set(_nolibs 0)
  set(_subdir 1)
  set(_doing "")
  foreach(arg ${ARGN})
    if("${arg}" MATCHES "^(LIBRARIES|INCLUDE_DIRS)$")
      set(_doing "${arg}")
    elseif("${arg}" MATCHES "^NO_ADD_SUBDIRECTORY$")
      set(_doing "")
      set(_subdir 0)
    elseif("${arg}" MATCHES "^NO_LIBRARIES$")
      set(_doing "")
      set(_nolibs 1)
    elseif("${_doing}" MATCHES "^LIBRARIES$")
      list(APPEND _libs "${arg}")
    elseif("${_doing}" MATCHES "^INCLUDE_DIRS$")
      list(APPEND _includes "${arg}")
    else()
      set(_doing "")
      message(AUTHOR_WARNING "Unknown argument [${arg}]")
    endif()
  endforeach()
  if(_libs AND _nolibs)
    message(FATAL_ERROR "Cannot specify both LIBRARIES and NO_LIBRARIES")
  endif()

  option(VTK_USE_SYSTEM_${_upper} "Use system-installed ${_pkg}" OFF)
  mark_as_advanced(VTK_USE_SYSTEM_${_upper})

  if(VTK_USE_SYSTEM_${_upper})
    find_package(${_pkg} REQUIRED)
    if(NOT ${_upper}_FOUND)
      message(FATAL_ERROR "VTK_USE_SYSTEM_${_upper} is ON but ${_pkg} is not found!")
    endif()
    if(${_upper}_INCLUDE_DIRS)
      set(vtk${_lower}_SYSTEM_INCLUDE_DIRS ${${_upper}_INCLUDE_DIRS})
    else()
      set(vtk${_lower}_SYSTEM_INCLUDE_DIRS ${${_upper}_INCLUDE_DIR})
    endif()
    set(vtk${_lower}_LIBRARIES "${${_upper}_LIBRARIES}")
    set(vtk${_lower}_INCLUDE_DIRS "")
  else()
    if(_nolibs)
      set(vtk${_lower}_LIBRARIES "")
    elseif(_libs)
      set(vtk${_lower}_LIBRARIES "${_libs}")
    else()
      set(vtk${_lower}_LIBRARIES vtk${_lower})
    endif()
    set(vtk${_lower}_INCLUDE_DIRS "${_includes}")
  endif()

  set(vtk${_lower}_THIRD_PARTY 1)
  vtk_module_impl()
  configure_file(vtk_${_lower}.h.in vtk_${_lower}.h)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/vtk_${_lower}.h
    DESTINATION ${VTK_INSTALL_INCLUDE_DIR})

  if(_subdir AND NOT VTK_USE_SYSTEM_${_upper})
    add_subdirectory(vtk${_lower})
  endif()
endmacro()

macro(vtk_module_glob src bld) # [test-langs]
  set(VTK_MODULES_ALL)
  file(GLOB meta RELATIVE "${src}" "${src}/*/*/module.cmake")
  foreach(f ${meta})
    unset(vtk-module)
    include(${src}/${f})
    if(DEFINED vtk-module)
      list(APPEND VTK_MODULES_ALL ${vtk-module})
      get_filename_component(${vtk-module}_BASE ${f} PATH)
      set(${vtk-module}_SOURCE_DIR ${src}/${${vtk-module}_BASE})
      set(${vtk-module}_BINARY_DIR ${bld}/${${vtk-module}_BASE})
      foreach(_lang ${ARGN})
        if(EXISTS ${${vtk-module}_SOURCE_DIR}/Testing/${_lang}/CMakeLists.txt)
          vtk_add_test_module(${_lang})
        endif()
      endforeach()
    endif()
  endforeach()
  unset(vtk-module)
  unset(vtk-module-test)
endmacro()

macro(vtk_add_test_module _lang)
  set(_test_module_name ${vtk-module-test}-${_lang})

  list(APPEND VTK_MODULES_ALL ${_test_module_name})
  set(VTK_MODULE_${_test_module_name}_DEPENDS ${VTK_MODULE_${vtk-module-test}_DEPENDS})
  set(${_test_module_name}_SOURCE_DIR ${${vtk-module}_SOURCE_DIR}/Testing/${_lang})
  set(${_test_module_name}_BINARY_DIR ${${vtk-module}_BINARY_DIR}/Testing/${_lang})
  set(${_test_module_name}_IS_TEST 1)
  list(APPEND ${vtk-module}_TESTED_BY ${_test_module_name})
  set(${_test_module_name}_TESTS_FOR ${vtk-module})
  set(VTK_MODULE_${_test_module_name}_DECLARED 1)
  # Exclude test modules from wrapping
  set(VTK_MODULE_${_test_module_name}_EXCLUDE_FROM_WRAPPING 1)
endmacro()
