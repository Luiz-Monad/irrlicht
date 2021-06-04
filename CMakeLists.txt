# ----------------------------------------------------------------------------
#  Root CMake file for OpenCV
#
#    From the off-tree build directory, invoke:
#      $ cmake <PATH_TO_OPENCV_ROOT>
#
# ----------------------------------------------------------------------------

# Disable in-source builds to prevent source tree corruption.
if(" ${CMAKE_SOURCE_DIR}" STREQUAL " ${CMAKE_BINARY_DIR}")
  message(FATAL_ERROR "
FATAL: In-source builds are not allowed.
       You should create a separate directory for build files.
")
endif()


include(cmake/OpenCVMinDepVersions.cmake)

if(CMAKE_GENERATOR MATCHES Xcode AND XCODE_VERSION VERSION_GREATER 4.3)
  cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
elseif(CMAKE_SYSTEM_NAME MATCHES WindowsPhone OR CMAKE_SYSTEM_NAME MATCHES WindowsStore)
  cmake_minimum_required(VERSION 3.1 FATAL_ERROR)
  #Required to resolve linker error issues due to incompatibility with CMake v3.0+ policies.
  #CMake fails to find _fseeko() which leads to subsequent linker error.
  #See details here: http://www.cmake.org/Wiki/CMake/Policies
  cmake_policy(VERSION 2.8)
else()
  cmake_minimum_required(VERSION "${MIN_VER_CMAKE}" FATAL_ERROR)
endif()

#
# Configure CMake policies
#
if(POLICY CMP0026)
  cmake_policy(SET CMP0026 NEW)
endif()

if(POLICY CMP0042)
  cmake_policy(SET CMP0042 NEW)  # CMake 3.0+ (2.8.12): MacOS "@rpath" in target's install name
endif()

if(POLICY CMP0046)
  cmake_policy(SET CMP0046 NEW)  # warn about non-existed dependencies
endif()

if(POLICY CMP0051)
  cmake_policy(SET CMP0051 NEW)
endif()

if(POLICY CMP0054)  # CMake 3.1: Only interpret if() arguments as variables or keywords when unquoted.
  cmake_policy(SET CMP0054 NEW)
endif()

if(POLICY CMP0056)
  cmake_policy(SET CMP0056 NEW)  # try_compile(): link flags
endif()

if(POLICY CMP0066)
  cmake_policy(SET CMP0066 NEW)  # CMake 3.7: try_compile(): use per-config flags, like CMAKE_CXX_FLAGS_RELEASE
endif()

if(POLICY CMP0067)
  cmake_policy(SET CMP0067 NEW)  # CMake 3.8: try_compile(): honor language standard variables (like C++11)
endif()

if(POLICY CMP0068)
  cmake_policy(SET CMP0068 NEW)  # CMake 3.9+: `RPATH` settings on macOS do not affect `install_name`.
endif()

if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)  # CMake 3.12+: Include file check macros honor `CMAKE_REQUIRED_LIBRARIES`
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)  # CMake 3.13+: option() honors normal variables.
endif()

#
# Configure OpenCV CMake hooks
#
include(cmake/OpenCVUtils.cmake)
ocv_cmake_reset_hooks()
ocv_check_environment_variables(OPENCV_CMAKE_HOOKS_DIR)
if(DEFINED OPENCV_CMAKE_HOOKS_DIR)
  foreach(__dir ${OPENCV_CMAKE_HOOKS_DIR})
    get_filename_component(__dir "${__dir}" ABSOLUTE)
    ocv_cmake_hook_register_dir(${__dir})
  endforeach()
endif()

ocv_cmake_hook(CMAKE_INIT)

# must go before the project()/enable_language() commands
ocv_update(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configs" FORCE)
if(DEFINED CMAKE_BUILD_TYPE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${CMAKE_CONFIGURATION_TYPES}")
endif()

option(ENABLE_PIC "Generate position independent code (necessary for shared libraries)" TRUE)
set(CMAKE_POSITION_INDEPENDENT_CODE ${ENABLE_PIC})

ocv_cmake_hook(PRE_CMAKE_BOOTSTRAP)

# Bootstap CMake system: setup CMAKE_SYSTEM_NAME and other vars
enable_language(CXX C)

ocv_cmake_hook(POST_CMAKE_BOOTSTRAP)

if(NOT OPENCV_SKIP_CMAKE_SYSTEM_FILE)
  include("cmake/platforms/OpenCV-${CMAKE_SYSTEM_NAME}.cmake" OPTIONAL RESULT_VARIABLE "OPENCV_CMAKE_SYSTEM_FILE")
  if(NOT OPENCV_CMAKE_SYSTEM_FILE)
    message(STATUS "IRR: system-specific configuration file is not found: '${CMAKE_SYSTEM_NAME}'")
  endif()
endif()

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)  # https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT.html
  if(NOT CMAKE_TOOLCHAIN_FILE)
    if(WIN32)
      set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory" FORCE)
    else()
      set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation Directory" FORCE)
    endif()
  else()
    # any cross-compiling
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory" FORCE)
  endif()
endif()

enable_testing()

project(Irrlicht CXX C)
set(OpenCV_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(OpenCV_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

if(MSVC)
  set(CMAKE_USE_RELATIVE_PATHS ON CACHE INTERNAL "" FORCE)
endif()

ocv_cmake_eval(DEBUG_PRE ONCE)

ocv_clear_vars(OpenCVModules_TARGETS)

include(cmake/OpenCVDownload.cmake)

set(BUILD_LIST "" CACHE STRING "Build only listed modules (comma-separated, e.g. 'videoio,dnn,ts')")

# ----------------------------------------------------------------------------
# Break in case of popular CMake configuration mistakes
# ----------------------------------------------------------------------------
if(NOT CMAKE_SIZEOF_VOID_P GREATER 0)
  message(FATAL_ERROR "CMake fails to determine the bitness of the target platform.
  Please check your CMake and compiler installation. If you are cross-compiling then ensure that your CMake toolchain file correctly sets the compiler details.")
endif()

# ----------------------------------------------------------------------------
# Detect compiler and target platform architecture
# ----------------------------------------------------------------------------
include(cmake/OpenCVDetectCXXCompiler.cmake)
ocv_cmake_hook(POST_DETECT_COMPILER)

# Add these standard paths to the search paths for FIND_LIBRARY
# to find libraries from these locations first
if(UNIX AND NOT ANDROID)
  if(X86_64 OR CMAKE_SIZEOF_VOID_P EQUAL 8)
    if(EXISTS /lib64)
      list(APPEND CMAKE_LIBRARY_PATH /lib64)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /lib)
    endif()
    if(EXISTS /usr/lib64)
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib64)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib)
    endif()
  elseif(X86 OR CMAKE_SIZEOF_VOID_P EQUAL 4)
    if(EXISTS /lib32)
      list(APPEND CMAKE_LIBRARY_PATH /lib32)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /lib)
    endif()
    if(EXISTS /usr/lib32)
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib32)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib)
    endif()
  endif()
endif()

# Add these standard paths to the search paths for FIND_PATH
# to find include files from these locations first
if(MINGW)
  if(EXISTS /mingw)
      list(APPEND CMAKE_INCLUDE_PATH /mingw)
  endif()
  if(EXISTS /mingw32)
      list(APPEND CMAKE_INCLUDE_PATH /mingw32)
  endif()
  if(EXISTS /mingw64)
      list(APPEND CMAKE_INCLUDE_PATH /mingw64)
  endif()
endif()

# ----------------------------------------------------------------------------
# OpenCV cmake options
# ----------------------------------------------------------------------------

# 3rd party libs
OCV_OPTION(OPENCV_FORCE_3RDPARTY_BUILD   "Force using 3rdparty code from source" OFF)
OCV_OPTION(BUILD_AES                "Build aes from source"              (WIN32 OR ANDROID OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )
OCV_OPTION(BUILD_BZIP2              "Build bzip2 from source"            (WIN32 OR ANDROID OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )
OCV_OPTION(BUILD_JPEG               "Build libjpeg from source"          (WIN32 OR ANDROID OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )
OCV_OPTION(BUILD_PNG                "Build libpng from source"           (WIN32 OR ANDROID OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )
OCV_OPTION(BUILD_LZMA               "Build lzma from source"             (WIN32 OR ANDROID OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )
OCV_OPTION(BUILD_ZLIB               "Build zlib from source"             (WIN32 OR APPLE OR OPENCV_FORCE_3RDPARTY_BUILD) )

# Optional 3rd party components
# ===================================================
OCV_OPTION(WITH_VULKAN "Include Vulkan support" OFF
  VISIBLE_IF TRUE
  VERIFY HAVE_VULKAN)
OCV_OPTION(WITH_OPENGL "Include OpenGL support" OFF
  VISIBLE_IF NOT ANDROID AND NOT WINRT
  VERIFY HAVE_OPENGL)

OCV_OPTION(WITH_JPEG "Include JPEG support" ON
  VISIBLE_IF TRUE
  VERIFY HAVE_JPEG)

OCV_OPTION(WITH_PNG "Include PNG support" ON
  VISIBLE_IF TRUE
  VERIFY HAVE_PNG)

OCV_OPTION(WITH_WIN32UI "Build with Win32 UI Backend support" ON
  VISIBLE_IF WIN32 AND NOT WINRT
  VERIFY HAVE_WIN32UI)

OCV_OPTION(WITH_OPENMP "Include OpenMP support" OFF
  VISIBLE_IF TRUE
  VERIFY HAVE_OPENMP)
OCV_OPTION(WITH_PTHREADS_PF "Use pthreads-based parallel_for" ON
  VISIBLE_IF NOT WIN32 OR MINGW
  VERIFY HAVE_PTHREADS_PF)

OCV_OPTION(WITH_DIRECTX "Include DirectX support" ON
  VISIBLE_IF WIN32 AND NOT WINRT
  VERIFY HAVE_DIRECTX)


# OpenCV build components
# ===================================================
OCV_OPTION(BUILD_SHARED_LIBS        "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" NOT (ANDROID OR APPLE_FRAMEWORK) )
OCV_OPTION(BUILD_opencv_apps        "Build utility applications (used for example to train classifiers)" (NOT ANDROID AND NOT WINRT) IF (NOT APPLE_FRAMEWORK) )
OCV_OPTION(BUILD_opencv_js          "Build JavaScript bindings by Emscripten" OFF )
OCV_OPTION(BUILD_OBJC               "Enable Objective-C support"                  ON  IF APPLE_FRAMEWORK )

# OpenCV build options
# ===================================================
OCV_OPTION(ENABLE_CCACHE              "Use ccache"                                               (UNIX AND NOT IOS AND (CMAKE_GENERATOR MATCHES "Makefile" OR CMAKE_GENERATOR MATCHES "Ninja")) )
OCV_OPTION(ENABLE_PRECOMPILED_HEADERS "Use precompiled headers"                                  MSVC IF (MSVC OR (NOT IOS AND NOT CMAKE_CROSSCOMPILING) ) )
OCV_OPTION(ENABLE_SOLUTION_FOLDERS    "Solution folder in Visual Studio or in other IDEs"        (MSVC_IDE OR CMAKE_GENERATOR MATCHES Xcode) )
OCV_OPTION(ENABLE_PROFILING           "Enable profiling in the GCC compiler (Add flags: -g -pg)" OFF  IF CV_GCC )
OCV_OPTION(ENABLE_COVERAGE            "Enable coverage collection with  GCov"                    OFF  IF CV_GCC )
OCV_OPTION(OPENCV_ENABLE_MEMORY_SANITIZER "Better support for memory/address sanitizers"         OFF)
OCV_OPTION(ENABLE_OMIT_FRAME_POINTER  "Enable -fomit-frame-pointer for GCC"                      ON   IF CV_GCC )
OCV_OPTION(ENABLE_POWERPC             "Enable PowerPC for GCC"                                   ON   IF (CV_GCC AND CMAKE_SYSTEM_PROCESSOR MATCHES powerpc.*) )
OCV_OPTION(ENABLE_FAST_MATH           "Enable compiler options for fast math optimizations on FP computations (not recommended)" OFF)
if(NOT IOS AND (NOT ANDROID OR OPENCV_ANDROID_USE_LEGACY_FLAGS))  # Use CPU_BASELINE instead
OCV_OPTION(ENABLE_NEON                "Enable NEON instructions"                                 (NEON OR ANDROID_ARM_NEON OR AARCH64) IF (CV_GCC OR CV_CLANG) AND (ARM OR AARCH64 OR IOS) )
OCV_OPTION(ENABLE_VFPV3               "Enable VFPv3-D32 instructions"                            OFF  IF (CV_GCC OR CV_CLANG) AND (ARM OR AARCH64 OR IOS) )
endif()
OCV_OPTION(ENABLE_NOISY_WARNINGS      "Show all warnings even if they are too noisy"             OFF )
OCV_OPTION(OPENCV_WARNINGS_ARE_ERRORS "Treat warnings as errors"                                 OFF )
OCV_OPTION(ENABLE_INSTRUMENTATION     "Instrument functions to collect calls trace and performance" OFF )
OCV_OPTION(ENABLE_GNU_STL_DEBUG       "Enable GNU STL Debug mode (defines _GLIBCXX_DEBUG)"       OFF IF ((NOT CMAKE_VERSION VERSION_LESS "2.8.11") AND CV_GCC) )
OCV_OPTION(ENABLE_BUILD_HARDENING     "Enable hardening of the resulting binaries (against security attacks, detects memory corruption, etc)" OFF)
OCV_OPTION(ENABLE_LTO                 "Enable Link Time Optimization" OFF IF CV_GCC OR MSVC)
OCV_OPTION(ENABLE_THIN_LTO            "Enable Thin LTO" OFF IF CV_CLANG)
OCV_OPTION(CV_ENABLE_INTRINSICS       "Use intrinsic-based optimized code" ON )
OCV_OPTION(CV_DISABLE_OPTIMIZATION    "Disable explicit optimized code (dispatched code/intrinsics/loop unrolling/etc)" OFF )
OCV_OPTION(ENABLE_CONFIG_VERIFICATION "Fail build if actual configuration doesn't match requested (WITH_XXX != HAVE_XXX)" OFF)
OCV_OPTION(OPENCV_ENABLE_MEMALIGN     "Enable posix_memalign or memalign usage" ON)


# ----------------------------------------------------------------------------
#  Get actual OpenCV version number from sources
# ----------------------------------------------------------------------------
include(cmake/OpenCVVersion.cmake)

ocv_cmake_hook(POST_OPTIONS)

# ----------------------------------------------------------------------------
#  Build & install layouts
# ----------------------------------------------------------------------------

if(OPENCV_TEST_DATA_PATH)
  get_filename_component(OPENCV_TEST_DATA_PATH ${OPENCV_TEST_DATA_PATH} ABSOLUTE)
endif()

# Save libs and executables in the same place
set(EXECUTABLE_OUTPUT_PATH "${CMAKE_BINARY_DIR}/bin" CACHE PATH "Output directory for applications")

if(ANDROID)
  set(LIBRARY_OUTPUT_PATH                "${OpenCV_BINARY_DIR}/lib/${ANDROID_NDK_ABI_NAME}")
  ocv_update(3P_LIBRARY_OUTPUT_PATH      "${OpenCV_BINARY_DIR}/3rdparty/lib/${ANDROID_NDK_ABI_NAME}")
else()
  set(LIBRARY_OUTPUT_PATH                "${OpenCV_BINARY_DIR}/lib")
  ocv_update(3P_LIBRARY_OUTPUT_PATH      "${OpenCV_BINARY_DIR}/3rdparty/lib")
endif()

if(ANDROID)
  if(ANDROID_ABI MATCHES "NEON")
    set(ENABLE_NEON ON)
  endif()
  if(ANDROID_ABI MATCHES "VFPV3")
    set(ENABLE_VFPV3 ON)
  endif()
endif()

if(WIN32)
  # Postfix of DLLs:
  ocv_update(OPENCV_DLLVERSION "${OPENCV_VERSION_MAJOR}${OPENCV_VERSION_MINOR}${OPENCV_VERSION_PATCH}")
  ocv_update(OPENCV_DEBUG_POSTFIX d)
else()
  # Postfix of so's:
  ocv_update(OPENCV_DLLVERSION "")
  ocv_update(OPENCV_DEBUG_POSTFIX "")
endif()

if(DEFINED CMAKE_DEBUG_POSTFIX)
  set(OPENCV_DEBUG_POSTFIX "${CMAKE_DEBUG_POSTFIX}")
endif()

include(cmake/OpenCVInstallLayout.cmake)

# ----------------------------------------------------------------------------
#  Path for build/platform -specific headers
# ----------------------------------------------------------------------------
ocv_update(OPENCV_CONFIG_FILE_INCLUDE_DIR "${CMAKE_BINARY_DIR}/" CACHE PATH "Where to create the platform-dependant irrconfig.h")
ocv_include_directories(${OPENCV_CONFIG_FILE_INCLUDE_DIR})

# ----------------------------------------------------------------------------
#  Autodetect if we are in a GIT repository
# ----------------------------------------------------------------------------
find_host_package(Git QUIET)

if(NOT DEFINED OPENCV_VCSVERSION AND GIT_FOUND)
  ocv_git_describe(OPENCV_VCSVERSION "${OpenCV_SOURCE_DIR}")
elseif(NOT DEFINED OPENCV_VCSVERSION)
  # We don't have git:
  set(OPENCV_VCSVERSION "unknown")
endif()


# ----------------------------------------------------------------------------
# OpenCV compiler and linker options
# ----------------------------------------------------------------------------
# In case of Makefiles if the user does not setup CMAKE_BUILD_TYPE, assume it's Release:
if(CMAKE_GENERATOR MATCHES "Makefiles|Ninja" AND "${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(CMAKE_BUILD_TYPE Release)
endif()

ocv_cmake_hook(POST_CMAKE_BUILD_OPTIONS)

include(cmake/OpenCVCompilerOptions.cmake)

ocv_cmake_hook(POST_COMPILER_OPTIONS)

# ----------------------------------------------------------------------------
#       CHECK FOR SYSTEM LIBRARIES, OPTIONS, ETC..
# ----------------------------------------------------------------------------
if(UNIX)
  if(NOT APPLE_FRAMEWORK OR OPENCV_ENABLE_PKG_CONFIG)
    if(CMAKE_CROSSCOMPILING AND NOT DEFINED ENV{PKG_CONFIG_LIBDIR} AND NOT DEFINED ENV{PKG_CONFIG_SYSROOT_DIR}
        AND NOT OPENCV_ENABLE_PKG_CONFIG
    )
      if(NOT PkgConfig_FOUND)
        message(STATUS "We disable pkg-config to avoid using of host libraries. Consider using PKG_CONFIG_LIBDIR to specify target SYSROOT")
      elseif(OPENCV_SKIP_PKG_CONFIG_WARNING)
        message(WARNING "pkg-config is enabled in cross-compilation mode without defining of PKG_CONFIG_LIBDIR environment variable. This may lead to misconfigured host-based dependencies.")
      endif()
    elseif(OPENCV_DISABLE_PKG_CONFIG)
      if(PkgConfig_FOUND)
        message(WARNING "OPENCV_DISABLE_PKG_CONFIG flag has no effect")
      endif()
    else()
      find_package(PkgConfig QUIET)
    endif()
  endif()
  include(CheckFunctionExists)
  include(CheckIncludeFile)
  include(CheckSymbolExists)

  if(NOT APPLE)
    CHECK_INCLUDE_FILE(pthread.h HAVE_PTHREAD)
    if(ANDROID)
      set(OPENCV_LINKER_LIBS ${OPENCV_LINKER_LIBS} dl m log)
    elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD|NetBSD|DragonFly|OpenBSD|Haiku")
      set(OPENCV_LINKER_LIBS ${OPENCV_LINKER_LIBS} m pthread)
    elseif(EMSCRIPTEN)
      # no need to link to system libs with emscripten
    else()
      set(OPENCV_LINKER_LIBS ${OPENCV_LINKER_LIBS} dl m pthread rt)
    endif()
  else()
    set(HAVE_PTHREAD 1)
  endif()

  if(OPENCV_ENABLE_MEMALIGN)
    CHECK_SYMBOL_EXISTS(posix_memalign stdlib.h HAVE_POSIX_MEMALIGN)
    CHECK_INCLUDE_FILE(malloc.h HAVE_MALLOC_H)
    if(HAVE_MALLOC_H)
      CHECK_SYMBOL_EXISTS(memalign malloc.h HAVE_MEMALIGN)
    endif()
    # TODO:
    # - _aligned_malloc() on Win32
    # - std::aligned_alloc() C++17 / C11
  endif()
endif()

include(cmake/OpenCVPCHSupport.cmake)
include(cmake/OpenCVModule.cmake)

# ----------------------------------------------------------------------------
#  Detect endianness of build platform
# ----------------------------------------------------------------------------

if(IOS)
  # test_big_endian needs try_compile, which doesn't work for iOS
  # http://public.kitware.com/Bug/view.php?id=12288
  set(WORDS_BIGENDIAN 0)
else()
  include(TestBigEndian)
  test_big_endian(WORDS_BIGENDIAN)
endif()

# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------------------------------------------------------

if(ANDROID AND WITH_CPUFEATURES)
  add_subdirectory(3rdparty/cpufeatures)
  set(HAVE_CPUFEATURES 1)
endif()

include(cmake/OpenCVFindLibsGrfmt.cmake)
include(cmake/OpenCVFindLibsGUI.cmake)

# ----------------------------------------------------------------------------
#  Detect other 3rd-party libraries/tools
# ----------------------------------------------------------------------------

# --- DirectX ---
if(WITH_DIRECTX)
  include(cmake/OpenCVDetectDirectX.cmake)
endif()

# ----------------------------------------------------------------------------
# Solution folders:
# ----------------------------------------------------------------------------
if(ENABLE_SOLUTION_FOLDERS)
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
  set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMakeTargets")
endif()

# Extra OpenCV targets: uninstall, package_source, perf, etc.
include(cmake/OpenCVExtraTargets.cmake)

# ----------------------------------------------------------------------------
# Process subdirectories
# ----------------------------------------------------------------------------

# Enable compiler options for OpenCV modules/apps/samples only (ignore 3rdparty)
ocv_add_modules_compiler_options()

# OpenCV modules
add_subdirectory(source)

# ----------------------------------------------------------------------------
# Finalization: generate configuration-based files
# ----------------------------------------------------------------------------

ocv_cmake_hook(PRE_FINALIZE)

# Generate platform-dependent and configuration-dependent headers
include(cmake/OpenCVGenHeaders.cmake)

# Generate OpenCVConfig.cmake and OpenCVConfig-version.cmake for cmake projects
include(cmake/OpenCVGenConfig.cmake)

# Generate Info.plist for the IOS framework
if(APPLE_FRAMEWORK)
  include(cmake/OpenCVGenInfoPlist.cmake)
endif()

# Generate environment setup file
if(INSTALL_TESTS AND OPENCV_TEST_DATA_PATH)
  if(ANDROID)
    get_filename_component(TEST_PATH ${OPENCV_TEST_INSTALL_PATH} DIRECTORY)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/opencv_run_all_tests_android.sh.in"
                   "${CMAKE_BINARY_DIR}/unix-install/opencv_run_all_tests.sh" @ONLY)
    install(PROGRAMS "${CMAKE_BINARY_DIR}/unix-install/opencv_run_all_tests.sh"
            DESTINATION ./ COMPONENT tests)
  elseif(WIN32)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/opencv_run_all_tests_windows.cmd.in"
                   "${CMAKE_BINARY_DIR}/win-install/opencv_run_all_tests.cmd" @ONLY)
    install(PROGRAMS "${CMAKE_BINARY_DIR}/win-install/opencv_run_all_tests.cmd"
            DESTINATION ${OPENCV_TEST_INSTALL_PATH} COMPONENT tests)
  elseif(UNIX)
    configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/templates/opencv_run_all_tests_unix.sh.in"
                   "${CMAKE_BINARY_DIR}/unix-install/opencv_run_all_tests.sh" @ONLY)
    install(PROGRAMS "${CMAKE_BINARY_DIR}/unix-install/opencv_run_all_tests.sh"
            DESTINATION ${OPENCV_TEST_INSTALL_PATH} COMPONENT tests)
  endif()
endif()

if(NOT OPENCV_LICENSE_FILE)
  set(OPENCV_LICENSE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/source/source.txt)
endif()

# for UNIX it does not make sense as LICENSE and readme will be part of the package automatically
if(ANDROID OR NOT UNIX)
  install(FILES ${OPENCV_LICENSE_FILE}
        PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
        DESTINATION ./ COMPONENT libs)
endif()

# ----------------------------------------------------------------------------
# Summary:
# ----------------------------------------------------------------------------
status("")
status("General Irrlicht configuration ${OPENCV_VERSION} =======================================")
if(OPENCV_VCSVERSION)
  status("  Version control:" ${OPENCV_VCSVERSION})
endif()

# ========================== build platform ==========================
status("")
status("  Platform:")
if(NOT DEFINED OPENCV_TIMESTAMP
    AND NOT CMAKE_VERSION VERSION_LESS 2.8.11
    AND NOT BUILD_INFO_SKIP_TIMESTAMP
)
  string(TIMESTAMP OPENCV_TIMESTAMP "" UTC)
  set(OPENCV_TIMESTAMP "${OPENCV_TIMESTAMP}" CACHE STRING "Timestamp of build configuration" FORCE)
endif()
if(OPENCV_TIMESTAMP)
  status("    Timestamp:"      ${OPENCV_TIMESTAMP})
endif()
status("    Host:"             ${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_VERSION} ${CMAKE_HOST_SYSTEM_PROCESSOR})
if(CMAKE_CROSSCOMPILING)
  status("    Target:"         ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION} ${CMAKE_SYSTEM_PROCESSOR})
endif()
status("    CMake:"            ${CMAKE_VERSION})
status("    CMake generator:"  ${CMAKE_GENERATOR})
status("    CMake build tool:" ${CMAKE_BUILD_TOOL})
if(MSVC)
  status("    MSVC:"           ${MSVC_VERSION})
endif()
if(CMAKE_GENERATOR MATCHES Xcode)
  status("    Xcode:"          ${XCODE_VERSION})
endif()
if(NOT CMAKE_GENERATOR MATCHES "Xcode|Visual Studio")
  status("    Configuration:"  ${CMAKE_BUILD_TYPE})
endif()


# ========================= CPU code generation mode =========================
status("")
status("  CPU/HW features:")
status("    Baseline:"  "${CPU_BASELINE_FINAL}")
if(NOT CPU_BASELINE STREQUAL CPU_BASELINE_FINAL)
  status("      requested:"  "${CPU_BASELINE}")
endif()
if(CPU_BASELINE_REQUIRE)
  status("      required:"  "${CPU_BASELINE_REQUIRE}")
endif()
if(CPU_BASELINE_DISABLE)
  status("      disabled:"  "${CPU_BASELINE_DISABLE}")
endif()
if(CPU_DISPATCH_FINAL OR CPU_DISPATCH)
  status("    Dispatched code generation:"  "${CPU_DISPATCH_FINAL}")
  if(NOT CPU_DISPATCH STREQUAL CPU_DISPATCH_FINAL)
    status("      requested:"  "${CPU_DISPATCH}")
  endif()
  if(CPU_DISPATCH_REQUIRE)
    status("      required:"  "${CPU_DISPATCH_REQUIRE}")
  endif()
  foreach(OPT ${CPU_DISPATCH_FINAL})
    status("      ${OPT} (${CPU_${OPT}_USAGE_COUNT} files):"  "+ ${CPU_DISPATCH_${OPT}_INCLUDED}")
  endforeach()
endif()

# ========================== C/C++ options ==========================
if(CMAKE_CXX_COMPILER_VERSION)
  set(OPENCV_COMPILER_STR "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} (ver ${CMAKE_CXX_COMPILER_VERSION})")
else()
  set(OPENCV_COMPILER_STR "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1}")
endif()
string(STRIP "${OPENCV_COMPILER_STR}" OPENCV_COMPILER_STR)

status("")
status("  C/C++:")
status("    Built as dynamic libs?:" BUILD_SHARED_LIBS THEN YES ELSE NO)
if(DEFINED CMAKE_CXX_STANDARD AND CMAKE_CXX_STANDARD)
  status("    C++ standard:"           "${CMAKE_CXX_STANDARD}")
endif()
status("    C++ Compiler:"           ${OPENCV_COMPILER_STR})
status("    C++ flags (Release):"    ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE})
status("    C++ flags (Debug):"      ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG})
status("    C Compiler:"             ${CMAKE_C_COMPILER} ${CMAKE_C_COMPILER_ARG1})
status("    C flags (Release):"      ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE})
status("    C flags (Debug):"        ${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_DEBUG})
if(WIN32)
  status("    Linker flags (Release):" ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_RELEASE})
  status("    Linker flags (Debug):"   ${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_DEBUG})
else()
  status("    Linker flags (Release):" ${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_RELEASE})
  status("    Linker flags (Debug):"   ${CMAKE_SHARED_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS_DEBUG})
endif()
status("    ccache:"                  OPENCV_COMPILER_IS_CCACHE THEN YES ELSE NO)
status("    Precompiled headers:"     PCHSupport_FOUND AND ENABLE_PRECOMPILED_HEADERS THEN YES ELSE NO)

# ========================== Dependencies ============================
ocv_get_all_libs(deps_modules deps_extra deps_3rdparty)
status("    Extra dependencies:" ${deps_extra})
status("    3rdparty dependencies:" ${deps_3rdparty})

# ========================== OpenCV modules ==========================
status("")
status("  Modules:")
set(OPENCV_MODULES_BUILD_ST "")
foreach(the_module ${OPENCV_MODULES_BUILD})
  if(NOT OPENCV_MODULE_${the_module}_CLASS STREQUAL "INTERNAL" OR the_module STREQUAL "opencv_ts")
    list(APPEND OPENCV_MODULES_BUILD_ST "${the_module}")
  endif()
endforeach()
string(REPLACE "opencv_" "" OPENCV_MODULES_BUILD_ST          "${OPENCV_MODULES_BUILD_ST}")
string(REPLACE "opencv_" "" OPENCV_MODULES_DISABLED_USER_ST  "${OPENCV_MODULES_DISABLED_USER}")
string(REPLACE "opencv_" "" OPENCV_MODULES_DISABLED_AUTO_ST  "${OPENCV_MODULES_DISABLED_AUTO}")
string(REPLACE "opencv_" "" OPENCV_MODULES_DISABLED_FORCE_ST "${OPENCV_MODULES_DISABLED_FORCE}")
list(SORT OPENCV_MODULES_BUILD_ST)
list(SORT OPENCV_MODULES_DISABLED_USER_ST)
list(SORT OPENCV_MODULES_DISABLED_AUTO_ST)
list(SORT OPENCV_MODULES_DISABLED_FORCE_ST)
status("    To be built:"            OPENCV_MODULES_BUILD          THEN ${OPENCV_MODULES_BUILD_ST}          ELSE "-")
status("    Disabled:"               OPENCV_MODULES_DISABLED_USER  THEN ${OPENCV_MODULES_DISABLED_USER_ST}  ELSE "-")
status("    Disabled by dependency:" OPENCV_MODULES_DISABLED_AUTO  THEN ${OPENCV_MODULES_DISABLED_AUTO_ST}  ELSE "-")
status("    Unavailable:"            OPENCV_MODULES_DISABLED_FORCE THEN ${OPENCV_MODULES_DISABLED_FORCE_ST} ELSE "-")

ocv_build_features_string(apps_status
  IF BUILD_TESTS AND HAVE_opencv_ts THEN "tests"
  IF BUILD_PERF_TESTS AND HAVE_opencv_ts THEN "perf_tests"
  IF BUILD_EXAMPLES THEN "examples"
  IF BUILD_opencv_apps THEN "apps"
  IF BUILD_ANDROID_SERVICE THEN "android_service"
  IF (BUILD_ANDROID_EXAMPLES OR INSTALL_ANDROID_EXAMPLES) AND CAN_BUILD_ANDROID_PROJECTS THEN "android_examples"
  ELSE "-")
status("    Applications:" "${apps_status}")
ocv_build_features_string(docs_status
    IF BUILD_opencv_js OR DEFINED OPENCV_JS_LOCATION THEN "js"
    ELSE "NO"
)
status("    Documentation:" "${docs_status}")

# ================== Windows RT features ==================
if(WIN32)
status("")
status("  Windows RT support:" WINRT THEN YES ELSE NO)
  if(WINRT)
    status("    Building for Microsoft platform: " ${CMAKE_SYSTEM_NAME})
    status("    Building for architectures: " ${CMAKE_VS_EFFECTIVE_PLATFORMS})
    status("    Building for version: " ${CMAKE_SYSTEM_VERSION})
    if (DEFINED ENABLE_WINRT_MODE_NATIVE)
      status("    Building for C++ without CX extensions")
    endif()
  endif()
endif(WIN32)

# ========================== GUI ==========================
status("")
status("  GUI: ")


if(WITH_WIN32UI)
  status("    Win32 UI:" HAVE_WIN32UI THEN YES ELSE NO)
endif()

if(HAVE_COCOA)  # APPLE
  status("    Cocoa:"  YES)
endif()

if(WITH_OPENGL OR HAVE_OPENGL)
  status("    OpenGL support:" HAVE_OPENGL THEN "YES (${OPENGL_LIBRARIES})" ELSE NO)
endif()

# ========================== MEDIA IO ==========================
status("")
status("  Media I/O: ")

status("    ZLib:"   ZLIB_FOUND THEN "${ZLIB_LIBRARIES} (ver ${ZLIB_VERSION_STRING})" ELSE "build (ver ${ZLIB_VERSION_STRING})")

if(WITH_AES OR HAVE_AES)
  if(NOT HAVE_AES)
    status("    AES:" NO)
  elseif(BUILD_AES)
    status("    AES:" "build-${AES_LIBRARY} (ver ${AES_VERSION})")
  else()
    status("    AES:" "${AES_LIBRARY} (ver ${AES_VERSION})")
  endif()
endif()

if(WITH_BZIP2 OR HAVE_BZIP2)
  if(NOT HAVE_BZIP2)
    status("    BZIP2:" NO)
  elseif(BUILD_BZIP2)
    status("    BZIP2:" "build-${BZIP2_LIBRARY} (ver ${BZIP2_VERSION})")
  else()
    status("    BZIP2:" "${BZIP2_LIBRARY} (ver ${BZIP2_VERSION})")
  endif()
endif()

if(WITH_JPEG OR HAVE_JPEG)
  if(NOT HAVE_JPEG)
    status("    JPEG:" NO)
  elseif(BUILD_JPEG)
    status("    JPEG:" "build-${JPEG_LIBRARY} (ver ${JPEG_LIB_VERSION})")
  else()
    status("    JPEG:" "${JPEG_LIBRARY} (ver ${JPEG_LIB_VERSION})")
  endif()
endif()

if(WITH_PNG OR HAVE_PNG)
  if(NOT HAVE_PNG)
    status("    PNG:" NO)
  elseif(BUILD_PNG)
    status("    PNG:" "build-${PNG_LIBRARY} (ver ${PNG_VERSION})")
  else()
    status("    PNG:" "${PNG_LIBRARY} (ver ${PNG_VERSION})")
  endif()
endif()

if(WITH_LZMA OR HAVE_LZMA)
  if(NOT HAVE_LZMA)
    status("    LZMA:" NO)
  elseif(BUILD_LZMA)
    status("    LZMA:" "build-${LZMA_LIBRARY} (ver ${LZMA_VERSION})")
  else()
    status("    LZMA:" "${LZMA_LIBRARY} (ver ${LZMA_VERSION})")
  endif()
endif()

# Order is similar to CV_PARALLEL_FRAMEWORK in core/src/parallel.cpp
ocv_build_features_string(parallel_status EXCLUSIVE
  IF HAVE_OPENMP THEN "OpenMP"
  IF WINRT OR HAVE_CONCURRENCY THEN "Concurrency"
  IF HAVE_PTHREADS_PF THEN "pthreads"
  ELSE "none")
status("")
status("  Parallel framework:" "${parallel_status}")

if(CV_TRACE OR OPENCV_TRACE)
  ocv_build_features_string(trace_status EXCLUSIVE
    "built-in")
  status("")
  status("  Trace: " OPENCV_TRACE THEN "YES (${trace_status})" ELSE NO)
endif()

# ========================== Other third-party libraries ==========================
status("")
status("  Other third-party libraries:")

foreach(s ${CUSTOM_STATUS})
  status(${CUSTOM_STATUS_${s}})
endforeach()

if(WITH_VULKAN OR HAVE_VULKAN)
  status("")
  status("  Vulkan:"     HAVE_VULKAN THEN "YES" ELSE "NO")
  if(HAVE_VULKAN)
    status("    Include path:"  VULKAN_INCLUDE_DIRS THEN "${VULKAN_INCLUDE_DIRS}" ELSE "NO")
    status("    Link libraries:" VULKAN_LIBRARIES THEN "${VULKAN_LIBRARIES}" ELSE "Dynamic load")
  endif()
endif()


# ========================== Objective-C =======================
if(BUILD_OBJC)
  status("")
  status("  Objective-C wrappers:" HAVE_opencv_objc THEN YES ELSE NO)
endif()

ocv_cmake_hook(STATUS_DUMP_EXTRA)

# ========================== auxiliary ==========================
status("")
status("  Install to:" "${CMAKE_INSTALL_PREFIX}")
status("-----------------------------------------------------------------")
status("")

ocv_finalize_status()

if(ENABLE_CONFIG_VERIFICATION)
  ocv_verify_config()
endif()

ocv_cmake_hook(POST_FINALIZE)

# ----------------------------------------------------------------------------
# CPack stuff
# ----------------------------------------------------------------------------

include(cmake/OpenCVPackaging.cmake)

# This should be the last command
ocv_cmake_dump_vars("" TOFILE "CMakeVars.txt")
ocv_cmake_eval(DEBUG_POST ONCE)
