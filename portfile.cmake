vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "osx" "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luiz-monad/Irrlicht%20SDK
    REF customport
    SHA512 @SHA512@
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/irrlicht/)
endif()

vcpkg_copy_pdbs()

file(
    INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
    RENAME copyright
)
