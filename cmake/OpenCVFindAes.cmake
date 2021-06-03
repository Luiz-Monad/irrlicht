#=============================================================================
# Find AES library
#=============================================================================
# Find the native AES headers and libraries.
#
#  AES_INCLUDE_DIRS - where to find aes.h, etc.
#  AES_LIBRARIES    - List of libraries when using webp.
#  AES_FOUND        - True if webp is found.
#=============================================================================

# Look for the header file.

unset(AES_FOUND)

FIND_PATH(AES_INCLUDE_DIR NAMES aes.h)

if(NOT AES_INCLUDE_DIR)
    unset(AES_FOUND)
else()
    MARK_AS_ADVANCED(AES_INCLUDE_DIR)

    # Look for the library.
    FIND_LIBRARY(AES_LIBRARY NAMES webp)
    MARK_AS_ADVANCED(AES_LIBRARY)

    # handle the QUIETLY and REQUIRED arguments and set AES_FOUND to TRUE if
    # all listed variables are TRUE
    INCLUDE(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(AES DEFAULT_MSG AES_LIBRARY AES_INCLUDE_DIR)

    SET(AES_LIBRARIES ${AES_LIBRARY})
    SET(AES_INCLUDE_DIRS ${AES_INCLUDE_DIR})
endif()
