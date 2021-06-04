# ----------------------------------------------------------------------------

set(the_description "The Core Functionality")

ocv_add_module(core WRAP objc js)

# ----------------------------------------------------------------------------

ocv_include_directories(${ZLIB_INCLUDE_DIRS})
list(APPEND CORE_LIBS ${ZLIB_LIBRARIES})

if(HAVE_AES)
  ocv_include_directories(${AES_INCLUDE_DIR} ${${AES_LIBRARY}_BINARY_DIR})
  list(APPEND CORE_LIBS ${AES_LIBRARIES})
endif()

if(HAVE_BZIP2)
  ocv_include_directories(${BZIP2_INCLUDE_DIR} ${${BZIP2_LIBRARY}_BINARY_DIR})
  list(APPEND CORE_LIBS ${BZIP2_LIBRARIES})
endif()

if(HAVE_JPEG)
  ocv_include_directories(${JPEG_INCLUDE_DIR} ${${JPEG_LIBRARY}_BINARY_DIR})
  list(APPEND CORE_LIBS ${JPEG_LIBRARIES})
endif()

if(HAVE_PNG)
  add_definitions(${PNG_DEFINITIONS})
  ocv_include_directories(${PNG_INCLUDE_DIR})
  list(APPEND CORE_LIBS ${PNG_LIBRARIES})
endif()

if(HAVE_LZMA)
  ocv_include_directories(${LZMA_INCLUDE_DIRS})
  list(APPEND CORE_LIBS ${LZMA_LIBRARIES})
endif()

# ----------------------------------------------------------------------------

set(CORE_GLES_dir ${CMAKE_CURRENT_LIST_DIR}/Khronos)
file(GLOB CORE_GLES_hdrs ${CORE_GLES_dir}/*.h)
ocv_module_include_directories(${CORE_GLES_dir})

source_group("Src\\GLES" FILES ${CORE_GLES_hdrs})

# ----------------------------------------------------------------------------

set(CORE_android_dir ${CMAKE_CURRENT_LIST_DIR}/Android)
file(GLOB CORE_android_hdrs ${CORE_android_dir}/*.h)
file(GLOB CORE_android_srcs ${CORE_android_dir}/*.cpp)
ocv_module_include_directories(${CORE_android_dir})

source_group("Src\\Android" FILES ${CORE_android_hdrs} ${CORE_android_srcs})

# ----------------------------------------------------------------------------

file(GLOB CORE_hdrs ${CMAKE_CURRENT_LIST_DIR}/*.h)
file(GLOB CORE_srcs ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

ocv_module_include_directories(${CMAKE_CURRENT_LIST_DIR})

set(CORE_conf_dir ${CMAKE_CURRENT_LIST_DIR}/..)
file(GLOB CORE_conf_hdrs ${CORE_conf_dir}/*.h)
ocv_module_include_directories(${CORE_conf_dir})

set(CORE_ext_dir ${CMAKE_CURRENT_LIST_DIR}/../../include)
file(GLOB CORE_ext_hdrs ${CORE_ext_dir}/*.h)
ocv_module_include_directories(${CORE_ext_dir})

if(IOS)
  list(APPEND CORE_srcs ${CMAKE_CURRENT_LIST_DIR}/*.mm)
  list(APPEND CORE_LIBS "-framework UIKit" "-framework AssetsLibrary")
endif()
if(APPLE_FRAMEWORK)
  list(APPEND CORE_LIBS "-framework Accelerate" "-framework CoreGraphics" "-framework QuartzCore")
endif()

source_group("Src" FILES ${CORE_srcs})
source_group("Include" FILES ${CORE_hdrs})
source_group("External Include" FILES ${CORE_ext_hdrs} ${CORE_conf_hdrs})

# ----------------------------------------------------------------------------

ocv_set_module_sources(
  HEADERS ${CORE_ext_hdrs} ${CORE_conf_hdrs}
  SOURCES ${CORE_srcs} ${CORE_hdrs}
          ${CORE_android_srcs} ${CORE_android_hdrs})

ocv_create_module(${CORE_LIBS})

# ----------------------------------------------------------------------------

ocv_add_accuracy_tests()
ocv_add_perf_tests()

# ----------------------------------------------------------------------------
