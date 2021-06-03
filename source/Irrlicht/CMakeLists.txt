# ----------------------------------------------------------------------------

set(the_description "The Core Functionality")

ocv_add_module(core irrlicht_core
               WRAP objc js)

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

file(GLOB android_hdrs ${CMAKE_CURRENT_LIST_DIR}/Android/*.h)
file(GLOB android_srcs ${CMAKE_CURRENT_LIST_DIR}/Android/*.cpp)

source_group("Src\\Android" FILES ${android_hdrs} ${android_srcs})

# ----------------------------------------------------------------------------

file(GLOB CORE_hdrs ${CMAKE_CURRENT_LIST_DIR}/*.h)
file(GLOB CORE_srcs ${CMAKE_CURRENT_LIST_DIR}/*.cpp)

file(GLOB CORE_ext_hdrs "${CMAKE_CURRENT_LIST_DIR}/../../include/*.h")

if(IOS)
  list(APPEND CORE_srcs ${CMAKE_CURRENT_LIST_DIR}/*.mm)
  list(APPEND CORE_LIBS "-framework UIKit" "-framework AssetsLibrary")
endif()
if(APPLE_FRAMEWORK)
  list(APPEND CORE_LIBS "-framework Accelerate" "-framework CoreGraphics" "-framework QuartzCore")
endif()

# ----------------------------------------------------------------------------

source_group("Src" FILES ${CORE_srcs} ${CORE_hdrs})
source_group("Include" FILES ${CORE_ext_hdrs})
ocv_set_module_sources(HEADERS ${CORE_ext_hdrs} SOURCES ${CORE_srcs} ${CORE_hdrs} ${android_srcs} ${android_hdrs})
ocv_module_include_directories()

ocv_create_module(${CORE_LIBS})

#ocv_module_include_directories(${the_module} ${ZLIB_INCLUDE_DIRS})
#ocv_target_link_libraries(${the_module} PRIVATE "${ZLIB_LIBRARIES}")

# ----------------------------------------------------------------------------

ocv_add_accuracy_tests()
ocv_add_perf_tests()

# ----------------------------------------------------------------------------
