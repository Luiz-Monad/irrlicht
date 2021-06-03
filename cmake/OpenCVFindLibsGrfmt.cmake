# ----------------------------------------------------------------------------
#  Detect 3rd-party image IO libraries
# ----------------------------------------------------------------------------

set (THIRDPARTY_DIR "${OpenCV_SOURCE_DIR}/source/irrlicht")

# --- zlib (required) ---
if(BUILD_ZLIB)
  ocv_clear_vars(ZLIB_FOUND)
else()
  find_package(ZLIB "${MIN_VER_ZLIB}")
  if(ZLIB_FOUND AND ANDROID)
    if(ZLIB_LIBRARIES MATCHES "/usr/(lib|lib32|lib64)/libz.so$")
      set(ZLIB_LIBRARIES z)
    endif()
  endif()
endif()

if(NOT ZLIB_FOUND)
  ocv_clear_vars(ZLIB_LIBRARY ZLIB_LIBRARIES ZLIB_INCLUDE_DIRS)

  set(ZLIB_LIBRARY zlib)
  add_subdirectory("${THIRDPARTY_DIR}/zlib")
  set(ZLIB_INCLUDE_DIRS "${${ZLIB_LIBRARY}_SOURCE_DIR}" "${${ZLIB_LIBRARY}_BINARY_DIR}")
  set(ZLIB_LIBRARIES ${ZLIB_LIBRARY})

  ocv_parse_header2(ZLIB "${${ZLIB_LIBRARY}_SOURCE_DIR}/zlib.h" ZLIB_VERSION)
endif()

# --- libjpeg (required) ---
if(BUILD_JPEG)
  ocv_clear_vars(JPEG_FOUND)
else()
  include(FindJPEG)
endif()

if(NOT JPEG_FOUND)
  ocv_clear_vars(JPEG_LIBRARY JPEG_LIBRARIES JPEG_INCLUDE_DIR)
  set(JPEG_LIBRARY libjpeg)
  set(JPEG_LIBRARIES ${JPEG_LIBRARY})
  add_subdirectory("${THIRDPARTY_DIR}/jpeglib")
  set(JPEG_INCLUDE_DIR "${${JPEG_LIBRARY}_SOURCE_DIR}")
endif()

macro(ocv_detect_jpeg_version header_file)
  if(NOT DEFINED JPEG_LIB_VERSION AND EXISTS "${header_file}")
    ocv_parse_header("${header_file}" JPEG_VERSION_LINES JPEG_LIB_VERSION)
  endif()
endmacro()
ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jpeglib.h")
if(DEFINED CMAKE_CXX_LIBRARY_ARCHITECTURE)
  ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/${CMAKE_CXX_LIBRARY_ARCHITECTURE}/jconfig.h")
endif()
# no needed for strict platform check here, both files 64/32 should contain the same version
ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig-64.h")
ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig-32.h")
ocv_detect_jpeg_version("${JPEG_INCLUDE_DIR}/jconfig.h")
ocv_detect_jpeg_version("${${JPEG_LIBRARY}_BINARY_DIR}/jconfig.h")
if(NOT DEFINED JPEG_LIB_VERSION)
  set(JPEG_LIB_VERSION "unknown")
endif()
set(HAVE_JPEG YES)

# --- libpng (required, should be searched after zlib) ---
if(BUILD_PNG)
  ocv_clear_vars(PNG_FOUND)
else()
  include(FindPNG)
  if(PNG_FOUND)
    include(CheckIncludeFile)
    check_include_file("${PNG_PNG_INCLUDE_DIR}/libpng/png.h" HAVE_LIBPNG_PNG_H)
    if(HAVE_LIBPNG_PNG_H)
      ocv_parse_header("${PNG_PNG_INCLUDE_DIR}/libpng/png.h" PNG_VERSION_LINES PNG_LIBPNG_VER_MAJOR PNG_LIBPNG_VER_MINOR PNG_LIBPNG_VER_RELEASE)
    else()
      ocv_parse_header("${PNG_PNG_INCLUDE_DIR}/png.h" PNG_VERSION_LINES PNG_LIBPNG_VER_MAJOR PNG_LIBPNG_VER_MINOR PNG_LIBPNG_VER_RELEASE)
    endif()
  endif()
endif()

if(NOT PNG_FOUND)
  ocv_clear_vars(PNG_LIBRARY PNG_LIBRARIES PNG_INCLUDE_DIR PNG_PNG_INCLUDE_DIR HAVE_LIBPNG_PNG_H PNG_DEFINITIONS)

  set(PNG_LIBRARY libpng)
  set(PNG_LIBRARIES ${PNG_LIBRARY})
  add_subdirectory("${THIRDPARTY_DIR}/libpng")
  set(PNG_INCLUDE_DIR "${${PNG_LIBRARY}_SOURCE_DIR}")
  set(PNG_DEFINITIONS "")
  ocv_parse_header("${PNG_INCLUDE_DIR}/png.h" PNG_VERSION_LINES PNG_LIBPNG_VER_MAJOR PNG_LIBPNG_VER_MINOR PNG_LIBPNG_VER_RELEASE)
endif()

set(HAVE_PNG YES)
set(PNG_VERSION "${PNG_LIBPNG_VER_MAJOR}.${PNG_LIBPNG_VER_MINOR}.${PNG_LIBPNG_VER_RELEASE}")

# --- lzma (required) ---
if(BUILD_LZMA)
  ocv_clear_vars(LIBLZMA_FOUND)
else()
  include(FindLibLZMA)
  if(LIBLZMA_FOUND)
    include(CheckIncludeFile)
    check_include_file("${LZMA_INCLUDE_DIR}/LzmaDec.h" HAVE_LIBLZMA_H)
    ocv_parse_header("${LZMA_INCLUDE_DIR}/version.h" LZMA_VER_LINES LZMA_VER_MAJOR LZMA_VER_MINOR LZMA_VER_RELEASE)
  endif()
endif()

if(NOT LIBLZMA_FOUND)
  ocv_clear_vars(LZMA_LIBRARY LZMA_LIBRARIES LZMA_INCLUDE_DIR HAVE_LIBLZMA_H LZMA_DEFINITIONS)

  set(LZMA_LIBRARY liblzma)
  set(LZMA_LIBRARIES ${LZMA_LIBRARY})
  add_subdirectory("${THIRDPARTY_DIR}/lzma")
  set(LZMA_INCLUDE_DIR "${${LZMA_LIBRARY}_SOURCE_DIR}")
  set(LZMA_DEFINITIONS "")
  ocv_parse_header("${LZMA_INCLUDE_DIR}/version.h" LZMA_VER_LINES LZMA_VER_MAJOR LZMA_VER_MINOR LZMA_VER_RELEASE)
endif()

set(HAVE_LZMA YES)
set(LZMA_VERSION "${LZMA_VER_MAJOR}.${LZMA_VER_MINOR}.${LZMA_VER_RELEASE}")

# --- bzip2 (required) ---
if(BUILD_BZIP2)
  ocv_clear_vars(BZIP2_FOUND)
else()
  include(FindBZIP2)
  if(BZIP2_FOUND)
    include(CheckIncludeFile)
    check_include_file("${BZIP2_INCLUDE_DIR}/bzlib.h" HAVE_LIBBZIP2_H)
  #  ocv_parse_header_str("${BZIP2_INCLUDE_DIR}/bzlib_private.h" BZIP2_VER_LINES BZIP2_VER_MAJOR BZIP2_VER_MINOR BZIP2_VER_RELEASE)
  endif()
endif()

if(NOT BZIP2_FOUND)
  ocv_clear_vars(BZIP2_LIBRARY BZIP2_LIBRARIES BZIP2_INCLUDE_DIR HAVE_LIBBZIP2_H BZIP2_DEFINITIONS)

  set(BZIP2_LIBRARY libbzip2)
  set(BZIP2_LIBRARIES ${BZIP2_LIBRARY})
  add_subdirectory("${THIRDPARTY_DIR}/bzip2")
  set(BZIP2_INCLUDE_DIR "${${BZIP2_LIBRARY}_SOURCE_DIR}")
  set(BZIP2_DEFINITIONS "")
  ocv_parse_header2(${BZIP2_LIBRARY} "${BZIP2_INCLUDE_DIR}/bzlib_private.h" BZ_VERSION)
endif()

set(HAVE_BZIP2 YES)
set(BZIP2_VERSION "${${BZIP2_LIBRARY}_VERSION_MAJOR}.${${BZIP2_LIBRARY}_VERSION_MINOR}.${${BZIP2_LIBRARY}_VERSION_PATCH}")

# --- aes-gladman (required) ---
if(BUILD_AES)
  ocv_clear_vars(AES_FOUND)
else()
  #include(FindAES)
  include(cmake/OpenCVFindAes.cmake)
  if(AES_FOUND)
    include(CheckIncludeFile)
    check_include_file("${AES_INCLUDE_DIR}/aes.h" HAVE_LIBAES_H)
    ocv_parse_header("${AES_INCLUDE_DIR}/version.h" AES_VER_LINES AES_VER_MAJOR AES_VER_MINOR AES_VER_RELEASE)
  endif()
endif()

if(NOT AES_FOUND)
  ocv_clear_vars(AES_LIBRARY AES_LIBRARIES AES_INCLUDE_DIR HAVE_LIBAES_H AES_DEFINITIONS)

  set(AES_LIBRARY libaes)
  set(AES_LIBRARIES ${AES_LIBRARY})
  add_subdirectory("${THIRDPARTY_DIR}/aesGladman")
  set(AES_INCLUDE_DIR "${${AES_LIBRARY}_SOURCE_DIR}")
  set(AES_DEFINITIONS "")
  ocv_parse_header("${AES_INCLUDE_DIR}/version.h" AES_VER_LINES AES_VER_MAJOR AES_VER_MINOR AES_VER_RELEASE)
endif()

set(HAVE_AES YES)
set(AES_VERSION "${AES_VER_MAJOR}.${AES_VER_MINOR}.${AES_VER_RELEASE}")
