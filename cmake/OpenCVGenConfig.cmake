# --------------------------------------------------------------------------------------------
#  Installation for CMake Module:  OpenCVConfig.cmake
#  Part 1/3: ${BIN_DIR}/OpenCVConfig.cmake              -> For use *without* "make install"
#  Part 2/3: ${BIN_DIR}/unix-install/OpenCVConfig.cmake -> For use with "make install"
#  Part 3/3: ${BIN_DIR}/win-install/OpenCVConfig.cmake  -> For use within binary installers/packages
# -------------------------------------------------------------------------------------------

if(INSTALL_TO_MANGLED_PATHS)
  set(OpenCV_USE_MANGLED_PATHS_CONFIGCMAKE TRUE)
else()
  set(OpenCV_USE_MANGLED_PATHS_CONFIGCMAKE FALSE)
endif()

set(OPENCV_MODULES_CONFIGCMAKE ${OPENCV_MODULES_PUBLIC})

if(BUILD_OBJC AND HAVE_opencv_objc)
  list(APPEND OPENCV_MODULES_CONFIGCMAKE opencv_objc)
endif()


# -------------------------------------------------------------------------------------------
#  Part 1/3: ${BIN_DIR}/OpenCVConfig.cmake              -> For use *without* "make install"
# -------------------------------------------------------------------------------------------
set(OpenCV_INCLUDE_DIRS_CONFIGCMAKE "\"${OPENCV_CONFIG_FILE_INCLUDE_DIR}\" \"${OpenCV_SOURCE_DIR}/include\"")

foreach(m ${OPENCV_MODULES_BUILD})
  if(EXISTS "${OPENCV_MODULE_${m}_LOCATION}/include")
    set(OpenCV_INCLUDE_DIRS_CONFIGCMAKE "${OpenCV_INCLUDE_DIRS_CONFIGCMAKE} \"${OPENCV_MODULE_${m}_LOCATION}/include\"")
  endif()
endforeach()

export(EXPORT OpenCVModules FILE "${CMAKE_BINARY_DIR}/IrrlichtModules.cmake")

ocv_cmake_hook(PRE_CMAKE_CONFIG_BUILD)
configure_file("${OpenCV_SOURCE_DIR}/cmake/templates/OpenCVConfig.cmake.in" "${CMAKE_BINARY_DIR}/IrrlichtConfig.cmake" @ONLY)
#support for version checking when finding opencv. find_package(OpenCV 2.3.1 EXACT) should now work.
configure_file("${OpenCV_SOURCE_DIR}/cmake/templates/OpenCVConfig-version.cmake.in" "${CMAKE_BINARY_DIR}/IrrlichtConfig-version.cmake" @ONLY)

# --------------------------------------------------------------------------------------------
#  Part 2/3: ${BIN_DIR}/unix-install/OpenCVConfig.cmake -> For use *with* "make install"
# -------------------------------------------------------------------------------------------
file(RELATIVE_PATH OpenCV_INSTALL_PATH_RELATIVE_CONFIGCMAKE "${CMAKE_INSTALL_PREFIX}/${OPENCV_CONFIG_INSTALL_PATH}/" ${CMAKE_INSTALL_PREFIX})
if (IS_ABSOLUTE ${OPENCV_INCLUDE_INSTALL_PATH})
  set(OpenCV_INCLUDE_DIRS_CONFIGCMAKE "\"${OPENCV_INCLUDE_INSTALL_PATH}\"")
else()
  set(OpenCV_INCLUDE_DIRS_CONFIGCMAKE "\"\${Irrlicht_INSTALL_PATH}/${OPENCV_INCLUDE_INSTALL_PATH}\"")
endif()

function(ocv_gen_config TMP_DIR NESTED_PATH ROOT_NAME)
  ocv_path_join(__install_nested "${OPENCV_CONFIG_INSTALL_PATH}" "${NESTED_PATH}")
  ocv_path_join(__tmp_nested "${TMP_DIR}" "${NESTED_PATH}")

  file(RELATIVE_PATH OpenCV_INSTALL_PATH_RELATIVE_CONFIGCMAKE "${CMAKE_INSTALL_PREFIX}/${__install_nested}" "${CMAKE_INSTALL_PREFIX}/")

  ocv_cmake_hook(PRE_CMAKE_CONFIG_INSTALL)
  configure_file("${OpenCV_SOURCE_DIR}/cmake/templates/OpenCVConfig-version.cmake.in" "${TMP_DIR}/IrrlichtConfig-version.cmake" @ONLY)

  configure_file("${OpenCV_SOURCE_DIR}/cmake/templates/OpenCVConfig.cmake.in" "${__tmp_nested}/IrrlichtConfig.cmake" @ONLY)
  install(EXPORT OpenCVModules DESTINATION "${__install_nested}" FILE IrrlichtModules.cmake COMPONENT dev)
  install(FILES
      "${TMP_DIR}/IrrlichtConfig-version.cmake"
      "${__tmp_nested}/IrrlichtConfig.cmake"
      DESTINATION "${__install_nested}" COMPONENT dev)

  if(ROOT_NAME)
    # Root config file
    configure_file("${OpenCV_SOURCE_DIR}/cmake/templates/${ROOT_NAME}" "${TMP_DIR}/IrrlichtConfig.cmake" @ONLY)
    install(FILES
        "${TMP_DIR}/IrrlichtConfig-version.cmake"
        "${TMP_DIR}/IrrlichtConfig.cmake"
        DESTINATION "${OPENCV_CONFIG_INSTALL_PATH}" COMPONENT dev)
  endif()
endfunction()

if((CMAKE_HOST_SYSTEM_NAME MATCHES "Linux" OR UNIX) AND NOT ANDROID)
  ocv_gen_config("${CMAKE_BINARY_DIR}/unix-install" "" "")
endif()

if(ANDROID)
  ocv_gen_config("${CMAKE_BINARY_DIR}/unix-install"
                 "abi-${ANDROID_NDK_ABI_NAME}"
                 "OpenCVConfig.root-ANDROID.cmake.in")
  #install(FILES "${OpenCV_SOURCE_DIR}/platforms/android/android.toolchain.cmake" DESTINATION "${OPENCV_CONFIG_INSTALL_PATH}" COMPONENT dev)
endif()

# --------------------------------------------------------------------------------------------
#  Part 3/3: ${BIN_DIR}/win-install/OpenCVConfig.cmake  -> For use within binary installers/packages
# --------------------------------------------------------------------------------------------
if(WIN32)
  if(CMAKE_HOST_SYSTEM_NAME MATCHES Windows AND NOT OPENCV_SKIP_CMAKE_ROOT_CONFIG)
    ocv_gen_config("${CMAKE_BINARY_DIR}/win-install"
                   "${OPENCV_INSTALL_BINARIES_PREFIX}${OPENCV_INSTALL_BINARIES_SUFFIX}"
                   "OpenCVConfig.root-WIN32.cmake.in")
  else()
    ocv_gen_config("${CMAKE_BINARY_DIR}/win-install" "" "")
  endif()
endif()
