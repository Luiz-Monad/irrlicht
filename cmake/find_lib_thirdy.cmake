# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(_TGT irr.3rdparty)
set(_TGT_NS Irrlicht)

find_package(pmake-cmake-targets)
pmake_target_create(${_TGT} NS ${_TGT_NS})

# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries (VCPKG)
# ----------------------------------------------------------------------------

# --- zlib (required) ---
find_package(ZLIB REQUIRED)
if(ZLIB_FOUND)
  if(ANDROID AND ZLIB_LIBRARIES MATCHES "/usr/(lib|lib32|lib64)/libz.so$")
    set(ZLIB_LIBRARIES z)
  endif()
  set(HAVE_ZLIB YES)
  pmake_target_link_libraries(${_TGT} INTERFACE ZLIB::ZLIB)
endif()

# --- libjpeg (required) ---
find_package(JPEG REQUIRED)
if(JPEG_FOUND)
  set(HAVE_JPEG YES)
  set(LIB JPEG)
  pmake_target_link_libraries(${_TGT} INTERFACE JPEG::JPEG)
endif()

# --- libpng (required) ---
find_package(PNG REQUIRED)
if(PNG_FOUND)
  set(HAVE_PNG YES)
  pmake_target_link_libraries(${_TGT} INTERFACE PNG::PNG)
endif()

# --- lzma (required) ---
find_package(LZMA REQUIRED)
if(LZMA_FOUND)
  set(HAVE_LZMA YES)
  pmake_target_link_libraries(${_TGT} INTERFACE LZMA::LZMA)
endif()

# --- bzip2 (required) ---
find_package(BZip2 REQUIRED)
if(BZip2_FOUND)
  set(HAVE_BZIP2 YES)
  pmake_target_link_libraries(${_TGT} INTERFACE BZip2::BZip2)
endif()

# --- aes-gladman (optional) ---
# find_package(AES)
# if(AES_FOUND)
#   set(HAVE_AES YES)
#   pmake_target_link_libraries(${_TGT} INTERFACE AES::AES)
# endif()
