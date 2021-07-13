# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(TGT irr.graphics)
set(TGT_NS Irrlicht)
set(TGT_FILE Graphics)

if((NOT TARGET ${TGT}) AND (NOT TARGET ${TGT_NS}::${TGT}))

  include(cmake/targets.cmake)
  qvr_install_dependency(${TGT} NS ${TGT_NS} FILE ${TGT_FILE})

endif()

# ----------------------------------------------------------------------------
#  Detect 3rd-party Graphics libraries (VCPKG)
# ----------------------------------------------------------------------------

# Make all local VCPKG available
foreach(PREFIX ${CMAKE_PREFIX_PATH})
  list(APPEND CMAKE_MODULE_PATH ${PREFIX} ${PREFIX}/share)
endforeach()

# --- EGL (headers) ---
find_package(egl-registry REQUIRED)
target_link_libraries(${TGT} INTERFACE egl-registry::libGLESv2)

# --- Angle ---
unset(HAVE_ANGLE)
if(WITH_ANGLE)
  find_package(Angle REQUIRED)
  set(HAVE_ANGLE)
  target_link_libraries(${TGT} INTERFACE Angle::Angle)
endif()

# --- OpenGl ---
unset(HAVE_OPENGL)
if(WITH_OPENGL)
  find_package(OpenGL REQUIRED)
  set(HAVE_OPENGL)
  target_link_libraries(${TGT} INTERFACE OpenGL::GL)
endif()

# --- Vulkan ---
if(WITH_VULKAN)
  set(VULKAN_INCLUDE_DIRS "${QVR_ROOT_DIR}/3rdparty/include" CACHE PATH "Vulkan include directory")
  set(VULKAN_LIBRARIES "")
  try_compile(VALID_VULKAN
        "${QVR_BIN_DIR}"
        "${QVR_ROOT_DIR}/cmake/checks/vulkan.cpp"
        CMAKE_FLAGS "-DINCLUDE_DIRECTORIES:STRING=${VULKAN_INCLUDE_DIRS}"
        OUTPUT_VARIABLE TRY_OUT
        )
  if(NOT ${VALID_VULKAN})
    message(ERROR "Vulkan requested but can't be used")
    return()
  endif()
  set(HAVE_VULKAN 1)
  target_link_libraries(${TGT} INTERFACE Vulkan::Vulkan)
endif()

#--- Win32 UI ---
unset(HAVE_WIN32UI)
if(WITH_WIN32UI)
  try_compile(HAVE_WIN32UI
    "${QVR_BIN_DIR}"
    "${QVR_ROOT_DIR}/cmake/checks/win32uitest.cpp"
    CMAKE_FLAGS "-DLINK_LIBRARIES:STRING=user32;gdi32")
  set(HAVE_WIN32UI)
endif()

# --- DirectX ---
if(WIN32 AND WITH_DIRECTX)
  try_compile(__VALID_DIRECTX
    "${QVR_BIN_DIR}"
    "${QVR_ROOT_DIR}/cmake/checks/directx.cpp"
    OUTPUT_VARIABLE TRY_OUT
  )
  if(NOT __VALID_DIRECTX)
    message(ERROR "DirectX requested but can't be used")
    return()
  endif()
  try_compile(__VALID_DIRECTX_NV12
    "${QVR_BIN_DIR}"
    "${QVR_ROOT_DIR}/cmake/checks/directx.cpp"
    COMPILE_DEFINITIONS "-DCHECK_NV12"
    OUTPUT_VARIABLE TRY_OUT
  )
  if(__VALID_DIRECTX_NV12)
    set(HAVE_DIRECTX_NV12 ON)
  else()
    message(STATUS "No support for DirectX NV12 format (install Windows 8 SDK)")
  endif()
  set(HAVE_DIRECTX ON)
  set(HAVE_D3D11 ON)
  set(HAVE_D3D10 ON)
  set(HAVE_D3D9 ON)
  if(HAVE_OPENCL AND WITH_OPENCL_D3D11_NV AND EXISTS "${OPENCL_INCLUDE_DIR}/CL/cl_d3d11_ext.h")
    set(HAVE_OPENCL_D3D11_NV ON)
  endif()
  target_link_libraries(${TGT} INTERFACE DirectX::DirectX)
endif()
