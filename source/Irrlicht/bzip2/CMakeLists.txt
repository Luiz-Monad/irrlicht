# ----------------------------------------------------------------------------
#  CMake file for libbzip2. See root CMakeLists.txt
#
# ----------------------------------------------------------------------------

project(${BZIP2_LIBRARY} C)

file(GLOB lib_srcs *.c)
file(GLOB lib_hdrs *.h)

# ----------------------------------------------------------------------------------
#         Define the library target:
# ----------------------------------------------------------------------------------

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
endif(MSVC)

add_library(${BZIP2_LIBRARY} STATIC ${lib_srcs} ${lib_hdrs})

ocv_warnings_disable(CMAKE_C_FLAGS -Wundef -Wcast-align -Wimplicit-fallthrough -Wunused-parameter -Wsign-compare)

set_target_properties(${BZIP2_LIBRARY}
  PROPERTIES OUTPUT_NAME ${BZIP2_LIBRARY}
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ${BZIP2_LIBRARY}
  COMPILE_PDB_NAME_DEBUG "${BZIP2_LIBRARY}${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
  )

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${BZIP2_LIBRARY} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${BZIP2_LIBRARY} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(libbzip2 LICENSE README)
