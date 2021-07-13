# ----------------------------------------------------------------------------
#  Root CMake file for Irrlicht
# ----------------------------------------------------------------------------

cmake_minimum_required(VERSION 3.20)
cmake_policy(VERSION 3.20)

enable_language(CXX C)
project(Irrlicht VERSION "1.9.0" LANGUAGES CXX C)

set(QVR_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(QVR_BIN_DIR ${CMAKE_CURRENT_BINARY_DIR})

set(QVR_VERSION_FILE ${CMAKE_CURRENT_SOURCE_DIR}/source/irrlicht/version.hpp)
set(QVR_VERSION_ID IRR)

# ----------------------------------------------------------------------------
# Optional graphical components
# ----------------------------------------------------------------------------

option(WITH_WIN32UI        "Include Win32 UI support" OFF)
option(WITH_VULKAN         "Include Vulkan support" OFF)
option(WITH_OPENGL         "Include OpenGL support" OFF)
option(WITH_DIRECTX        "Include DirectX support" OFF)

# ----------------------------------------------------------------------------
# Build options
# ----------------------------------------------------------------------------

option(BUILD_SHARED_LIBS   "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" OFF)
option(IRR_UNICODE_PATH    "Enable compiler support for unicode" OFF)
option(IRR_FAST_MATH       "Enable compiler options for fast math optimizations on FP computations (recommended)" ON)
option(IRR_BUILD_TOOLS     "Enable building of tools" OFF)

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

include(cmake/summary/dashboard.cmake)
