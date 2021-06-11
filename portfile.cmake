
cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0011 NEW)
include("$ENV{VCPKG_ROOT}/scripts/cmake/vcpkg_check_features.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
        unicode     IRR_UNICODE_PATH
        fast-fpu    IRR_FAST_MATH
        tools       IRR_BUILD_TOOLS
        win32ui     WITH_WIN32UI
        directx     WITH_DIRECTX
        opengl      WITH_OPENGL
        vulkan      WITH_VULKAN
        webgl       WITH_WEBGL
        angle       WITH_ANGLE
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  set(IRR_SHARED_LIB ON)
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
  set(WITH_WEBGL ON)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  set(WITH_WIN32UI ON)
  #set(WITH_DIRECTX ON)
  set(WITH_ANGLE ON)
  set(IRR_UNICODE_PATH ON)
endif()

if(VCPKG_TARGET_IS_LINUX)
  set(WITH_OPENGL ON)
endif()
