
set(CD ${CMAKE_CURRENT_LIST_DIR})

# ----------------------------------------------------------------------------
# Thirdy party components.
# ----------------------------------------------------------------------------

if(TARGET irr.3rdparty)
  list(APPEND TGT_LIB irr.3rdparty)
endif()

if(TARGET irr.graphics)
  list(APPEND TGT_LIB irr.graphics)
endif()

# ----------------------------------------------------------------------------
# Platform sources.
# ----------------------------------------------------------------------------

if(IOS)

  set(ios_dir ${CD}/IOS)
  file(GLOB ios_hdrs ${ios_dir}/*.h)
  file(GLOB ios_srcs ${ios_dir}/*.cpp)
  list(APPEND TGT_INC ${ios_dir})

  source_group("Source\\IOS" FILES ${ios_hdrs} ${ios_srcs})

endif()

# ----------------------------------------------------------------------------
# Platform sources.
# ----------------------------------------------------------------------------

set(android_dir ${CD}/Android)
file(GLOB android_hdrs ${android_dir}/*.h)
file(GLOB android_srcs ${android_dir}/*.cpp)
list(APPEND TGT_INC ${android_dir})

source_group("Source\\Android" FILES ${android_hdrs} ${android_srcs})

# ----------------------------------------------------------------------------
# Main sources.
# ----------------------------------------------------------------------------

set(conf_hdrs_dir ${QVR_BIN_DIR})
file(GLOB conf_hdrs ${conf_hdrs_dir}/*.h)
list(APPEND TGT_INC ${conf_hdrs_dir})

set(main_dir ${CD})
file(GLOB main_hdrs ${main_dir}/*.h)
file(GLOB main_srcs ${main_dir}/*.cpp)
list(APPEND TGT_INC ${main_dir})

set(pub_hdrs_dir ${CD}/../../include)
file(GLOB pub_hdrs ${pub_hdrs_dir}/*.h)
list(APPEND TGT_PUB_INC ${pub_hdrs})
list(APPEND TGT_BUILD_INC ${pub_hdrs_dir})

source_group("Source" FILES ${main_srcs})
source_group("Include" FILES ${main_hdrs})
source_group("External Include" FILES ${conf_hdrs})
source_group("Public Include" FILES ${pub_hdrs})

# ----------------------------------------------------------------------------
# Main Target.
# ----------------------------------------------------------------------------

set(TGT Irrlicht)

add_library(
  ${TGT} STATIC
  ${pub_hdrs} ${conf_hdrs}
  ${main_srcs} ${main_hdrs}
  ${android_srcs} ${android_hdrs}
  ${ios_srcs} ${ios_hdrs}
)

target_include_directories(
  ${TGT} PRIVATE
  ${TGT_INC})

string(TOLOWER ${TGT} __LTGT)
target_include_directories(
  ${TGT} PUBLIC
  $<BUILD_INTERFACE:${TGT_BUILD_INC}>
  $<INSTALL_INTERFACE:include/${__LTGT}>)

target_compile_features(
  ${TGT} PRIVATE
  cxx_std_11)

target_link_libraries(
  ${TGT} PRIVATE
  ${TGT_LIB})

# ----------------------------------------------------------------------------
# Extra Target definitions.
# ----------------------------------------------------------------------------

if(WITH_UNICODE_PATH)
  target_compile_definitions(${TGT} PRIVATE UNICODE _UNICODE)
  target_compile_definitions(${TGT} PUBLIC _IRR_WCHAR_FILESYSTEM)
endif()

# ----------------------------------------------------------------------------
# CMake Installation.
# ----------------------------------------------------------------------------

include(${QVR_ROOT_DIR}/cmake/targets.cmake)
qvr_install_target(
  ${TGT}
  PUB_INC ${TGT_PUB_INC}
  LIB ${TGT_LIB})
