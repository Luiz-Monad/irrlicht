
cmake_policy(SET CMP0057 NEW)
cmake_policy(SET CMP0011 NEW)
include("$ENV{VCPKG_ROOT}/scripts/cmake/vcpkg_check_features.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS FEATURES
        unicode     WITH_UNICODE_PATH
        fast-fpu    WITH_FAST_MATH
        tools       WITH_BUILD_TOOLS
        win32ui     WITH_WIN32UI
        directx     WITH_DIRECTX
        opengl      WITH_OPENGL
        vulkan      WITH_VULKAN
        webgl       WITH_WEBGL
        angle       WITH_ANGLE
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  if(NOT BUILD_SHARED_LIBS)
    message(ERROR "VCPKG_LIBRARY_LINKAGE is dynamic but BUILD_SHARED_LIBS is off.")
  endif()
endif()

if(VCPKG_TARGET_IS_EMSCRIPTEN)
  set(WITH_WEBGL ON)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
  #set(WITH_WIN32UI ON)
  #set(WITH_DIRECTX ON)
  set(WITH_ANGLE ON)
  set(WITH_UNICODE_PATH ON)
endif()

if(VCPKG_TARGET_IS_LINUX)
  set(WITH_OPENGL ON)
endif()

if(IOS)
  # test_big_endian needs try_compile, which doesn't work for iOS
  # http://public.kitware.com/Bug/view.php?id=12288
  set(WORDS_BIGENDIAN 0)
else()
  include(TestBigEndian)
  test_big_endian(WORDS_BIGENDIAN)
endif()
