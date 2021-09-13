
set(CD ${CMAKE_CURRENT_LIST_DIR})

# ----------------------------------------------------------------------------
# Features
# ----------------------------------------------------------------------------

include(${QVR_ROOT_DIR}/portfile.cmake)

# ----------------------------------------------------------------------------
# Platform-specific config file
# ----------------------------------------------------------------------------

set(_IRR_MATERIAL_MAX_TEXTURES_ 8)
set(NO_IRR_USE_NON_SYSTEM_ZLIB_ ON)
set(NO_IRR_USE_NON_SYSTEM_LIB_PNG_ ON)
set(NO_IRR_USE_NON_SYSTEM_BZLIB_ ON)
set(NO_IRR_USE_NON_SYSTEM_JPEG_LIB_ ON)
set(NO_IRR_COMPILE_WITH_ZIP_ENCRYPTION_ ON)
set(NO_IRR_HAS_PRAGMA_LIB ON)
set(NO_IRR_COMPILE_WITH_OGLES1_ ON)
if(NOT BUILD_SHARED_LIBS)
  set(_IRR_STATIC_LIB_ ON)
endif()
if(HAVE_WEBGL)
  set(IRR_COMPILE_WITH_WEBGL1_ ON)
endif()
if(HAVE_WIN32UI AND NOT HAVE_ANGLE)
  set(NO_IRR_COMPILE_WITH_OGLES2_ ON)
endif()
if(HAVE_WIN32UI AND NOT HAVE_DIRECTX)
  set(NO_IRR_COMPILE_WITH_DIRECT3D_9_ ON)
endif()
if(NOT HAVE_WIN32UI)
  set(NO_IRR_COMPILE_WITH_DIRECT3D_9_ ON)
endif()
if(NOT HAVE_OPENGL)
  set(NO_IRR_COMPILE_WITH_OPENGL ON)
endif()

configure_file(${CD}/irr_config.h.in ${QVR_BIN_DIR}/irr_config.h)

install(FILES ${QVR_BIN_DIR}/irr_config.h DESTINATION ${CMAKE_BINARY_DIR})

# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------
# ----------------------------------------------------------------------------

add_subdirectory(Irrlicht)
