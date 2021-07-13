# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(TGT irr.3rdparty)
set(TGT_NS Irrlicht)
set(TGT_FILE 3rdparty)

if((NOT TARGET ${TGT}) AND (NOT TARGET ${TGT_NS}::${TGT}))

  include(cmake/targets.cmake)
  qvr_install_dependency(${TGT} NS ${TGT_NS} FILE ${TGT_FILE})

endif()

# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries (VCPKG)
# ----------------------------------------------------------------------------

# Make all local VCPKG available
foreach(PREFIX ${CMAKE_PREFIX_PATH})
  list(APPEND CMAKE_MODULE_PATH ${PREFIX} ${PREFIX}/share)
endforeach()

# --- zlib (required) ---
find_package(ZLIB REQUIRED)
if(ZLIB_FOUND AND ANDROID)
  if(ZLIB_LIBRARIES MATCHES "/usr/(lib|lib32|lib64)/libz.so$")
    set(ZLIB_LIBRARIES z)
  endif()
  set(HAVE_ZLIB YES)
  target_link_libraries(${TGT} INTERFACE ZLIB::ZLIB)
endif()

# --- libjpeg (required) ---
find_package(JPEG REQUIRED)
if(JPEG_FOUND)
  set(HAVE_JPEG YES)
  set(LIB JPEG)
  target_link_libraries(${TGT} INTERFACE JPEG::JPEG)
endif()

# --- libpng (required) ---
find_package(PNG REQUIRED)
if(PNG_FOUND)
  set(HAVE_PNG YES)
  target_link_libraries(${TGT} INTERFACE PNG::PNG)
endif()

# --- lzma (required) ---
find_package(LZMA REQUIRED)
if(LZMA_FOUND)
  set(HAVE_LZMA YES)
  get_target_property(LZMA_LIBRARY LZMA::LZMA IMPORTED_LOCATION_RELEASE)
  target_link_libraries(${TGT} INTERFACE LZMA::LZMA)
endif()

# --- bzip2 (required) ---
find_package(BZip2 REQUIRED)
if(BZip2_FOUND)
  set(HAVE_BZIP2 YES)
  target_link_libraries(${TGT} INTERFACE BZip2::BZip2)
endif()

# --- aes-gladman (optional) ---
# find_package(AES)
# if(AES_FOUND)
#   set(HAVE_AES YES)
#   target_link_libraries(${TGT} INTERFACE AES::AES)
# endif()
