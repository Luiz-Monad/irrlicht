# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(_TGT irr.graphics)
set(_TGT_NS Irrlicht)

include(cmake/targets.cmake)
qvr_target_create(${_TGT} NS ${_TGT_NS})

# ----------------------------------------------------------------------------
#  Detect 3rd-party Graphics libraries (VCPKG)
# ----------------------------------------------------------------------------

# --- EGL (headers) ---
find_package(egl-registry REQUIRED)
qvr_target_link_libraries(${_TGT} INTERFACE egl-registry::EGLHeaders)

# --- OpenGL (headers) ---
find_package(opengl-registry REQUIRED)

# --- Angle ---
unset(HAVE_ANGLE)
if(WITH_ANGLE)
  find_package(Angle REQUIRED)
  set(HAVE_ANGLE YES)
  qvr_target_link_libraries(${_TGT} INTERFACE angle::libGLESv2)
  qvr_target_option(${_TGT} WITH_ANGLE)
endif()

# --- OpenGl ---
unset(HAVE_OPENGL)
if(WITH_OPENGL)
  find_package(OpenGL REQUIRED)
  set(HAVE_OPENGL YES)
  qvr_target_link_libraries(${_TGT} INTERFACE OpenGL::GL)
  qvr_target_option(${_TGT} WITH_OPENGL)
endif()

# --- Vulkan ---
unset(HAVE_VULKAN)
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
  set(HAVE_VULKAN YES)
  qvr_target_link_libraries(${_TGT} INTERFACE Vulkan::Vulkan)
  qvr_target_option(${_TGT} WITH_VULKAN)
endif()

#--- Win32 UI ---
unset(HAVE_WIN32UI)
if(WITH_WIN32UI)
  try_compile(HAVE_WIN32UI
    "${QVR_BIN_DIR}"
    "${QVR_ROOT_DIR}/cmake/checks/win32uitest.cpp"
    CMAKE_FLAGS "-DLINK_LIBRARIES:STRING=user32;gdi32")
  set(HAVE_WIN32UI YES)
  qvr_target_option(${_TGT} WITH_WIN32UI)
endif()

# --- DirectX ---
unset(HAVE_DIRECTX)
if(WITH_DIRECTX)
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
    set(HAVE_DIRECTX_NV12 YES)
  else()
    message(STATUS "No support for DirectX NV12 format (install Windows 8 SDK)")
  endif()
  set(HAVE_DIRECTX YES)
  set(HAVE_D3D11 YES)
  set(HAVE_D3D10 YES)
  set(HAVE_D3D9 YES)
  if(HAVE_OPENCL AND WITH_OPENCL_D3D11_NV AND EXISTS "${OPENCL_INCLUDE_DIR}/CL/cl_d3d11_ext.h")
    set(HAVE_OPENCL_D3D11_NV YES)
  endif()
  qvr_target_link_libraries(${_TGT} INTERFACE DirectX::DirectX)
  qvr_target_option(${_TGT} WITH_DIRECTX)
endif()
