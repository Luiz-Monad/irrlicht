# ----------------------------------------------------------------------------
#  Root CMake file for Irrlicht
# ----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.20)
cmake_policy(VERSION 3.20)

include(${CMAKE_CURRENT_SOURCE_DIR}/vcpkg.cmake)

enable_language(CXX C)
project(Irrlicht VERSION "1.9.0" LANGUAGES CXX C)

set(QVR_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(QVR_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})

# ----------------------------------------------------------------------------
# Optional graphical components
# ----------------------------------------------------------------------------

option(WITH_VULKAN         "Include Vulkan support" OFF)
option(WITH_ANGLE          "Include Angle support" OFF)
option(WITH_OPENGL         "Include OpenGL support" OFF)
option(WITH_WIN32UI        "Include Win32 UI support" OFF)
option(WITH_DIRECTX        "Include DirectX support" OFF)

# ----------------------------------------------------------------------------
# Build options
# ----------------------------------------------------------------------------

#option(BUILD_SHARED_LIBS  "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" OFF)
option(WITH_UNICODE_PATH   "Enable support for unicode" OFF)
option(WITH_FAST_MATH      "Enable options for fast math optimizations on FP computations (recommended)" ON)
option(WITH_BUILD_TOOLS    "Enable building of tools" OFF)

# ----------------------------------------------------------------------------
# Other 3rd-party libraries/tools
# ----------------------------------------------------------------------------

include(cmake/find_lib_thirdy.cmake)
include(cmake/find_lib_graphics.cmake)

# ----------------------------------------------------------------------------
# Solution folders:
# ----------------------------------------------------------------------------

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMakeTargets")

# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------

add_subdirectory(source)
add_subdirectory(tools)

# ----------------------------------------------------------------------------
# Summary:
# ----------------------------------------------------------------------------

find_package(pmake-cmake-dashboard)
pmake_dashboard(
  VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/source/irrlicht/version.hpp
  VERSION_ID IRR
)
