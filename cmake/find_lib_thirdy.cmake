# ----------------------------------------------------------------------------
#  Target
# ----------------------------------------------------------------------------

set(TGT irr.3rdparty)

add_library(${TGT} INTERFACE)

install(
  TARGETS ${TGT}
  EXPORT ${TGT}-targets
)

# Deploy the targets to a script.
include(GNUInstallDirs)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${TGT})
install(
  EXPORT ${TGT}-targets
  FILE ${TGT}Targets.cmake
  NAMESPACE ${TGT}::
  DESTINATION ${INSTALL_CONFIGDIR}
)

# Now export the target itself.
export(
  EXPORT ${TGT}-targets
  FILE ${CMAKE_CURRENT_BINARY_DIR}/${TGT}/${TGT}Targets.cmake
  NAMESPACE ${TGT}::
)

# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------------------------------------------------------

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
