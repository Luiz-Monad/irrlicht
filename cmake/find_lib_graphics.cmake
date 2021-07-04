# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(TGT irr.graphics)
set(TGT_DIR Irrlicht)
set(TGT_FILE IrrlichtGraphicsTargets.cmake)

add_library(${TGT} INTERFACE)

install(
  TARGETS ${TGT}
  EXPORT ${TGT}-targets
)

# Now export the target itself.
export(
  EXPORT ${TGT}-targets
  FILE ${CMAKE_CURRENT_BINARY_DIR}/${TGT}/${TGT_FILE}
  NAMESPACE ${TGT}::
)

# Deploy the targets to a script.
include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_DATAROOTDIR}/${TGT_DIR})
install(
  EXPORT ${TGT}-targets
  FILE ${TGT_FILE}
  NAMESPACE ${TGT}::
  DESTINATION ${INSTALL_CONFIGDIR}
)

# ----------------------------------------------------------------------------
#  Detect 3rd-party Graphics libraries
# ----------------------------------------------------------------------------

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
  set(VULKAN_INCLUDE_DIRS "${IRR_ROOT_DIR}/3rdparty/include" CACHE PATH "Vulkan include directory")
  set(VULKAN_LIBRARIES "")
  try_compile(VALID_VULKAN
        "${IRR_BIN_DIR}"
        "${IRR_ROOT_DIR}/cmake/checks/vulkan.cpp"
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
    "${IRR_BIN_DIR}"
    "${IRR_ROOT_DIR}/cmake/checks/win32uitest.cpp"
    CMAKE_FLAGS "-DLINK_LIBRARIES:STRING=user32;gdi32")
  set(HAVE_WIN32UI)
endif()

# --- DirectX ---
if(WIN32 AND WITH_DIRECTX)
  try_compile(__VALID_DIRECTX
    "${IRR_BIN_DIR}"
    "${IRR_ROOT_DIR}/cmake/checks/directx.cpp"
    OUTPUT_VARIABLE TRY_OUT
  )
  if(NOT __VALID_DIRECTX)
    message(ERROR "DirectX requested but can't be used")
    return()
  endif()
  try_compile(__VALID_DIRECTX_NV12
    "${IRR_BIN_DIR}"
    "${IRR_ROOT_DIR}/cmake/checks/directx.cpp"
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
