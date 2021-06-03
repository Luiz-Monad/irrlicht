# ----------------------------------------------------------------------------
#  CMake file for libaes. See root CMakeLists.txt
#
# ----------------------------------------------------------------------------

project(${AES_LIBRARY} CXX)

file(GLOB lib_srcs *.cpp)
file(GLOB lib_hdrs *.h)

ocv_include_directories("${CMAKE_CURRENT_LIST_DIR}/../../../include")

# ----------------------------------------------------------------------------------
#         Define the library target:
# ----------------------------------------------------------------------------------

if(MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
endif(MSVC)

add_library(${AES_LIBRARY} STATIC ${lib_srcs} ${lib_hdrs})

ocv_warnings_disable(CMAKE_C_FLAGS -Wundef -Wcast-align -Wimplicit-fallthrough -Wunused-parameter -Wsign-compare)

set_target_properties(${AES_LIBRARY}
  PROPERTIES OUTPUT_NAME ${AES_LIBRARY}
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ${AES_LIBRARY}
  COMPILE_PDB_NAME_DEBUG "${AES_LIBRARY}${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
  )

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${AES_LIBRARY} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${AES_LIBRARY} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(libaes Readme.txt)
