SET(OPENCV_VERSION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/source/irrlicht/version.hpp")
file(STRINGS "${OPENCV_VERSION_FILE}" OPENCV_VERSION_PARTS REGEX "#define CV_VERSION_[A-Z]+[ ]+" )

string(REGEX REPLACE ".+CV_VERSION_MAJOR[ ]+([0-9]+).*" "\\1" OPENCV_VERSION_MAJOR "${OPENCV_VERSION_PARTS}")
string(REGEX REPLACE ".+CV_VERSION_MINOR[ ]+([0-9]+).*" "\\1" OPENCV_VERSION_MINOR "${OPENCV_VERSION_PARTS}")
string(REGEX REPLACE ".+CV_VERSION_REVISION[ ]+([0-9]+).*" "\\1" OPENCV_VERSION_PATCH "${OPENCV_VERSION_PARTS}")
string(REGEX REPLACE ".+CV_VERSION_STATUS[ ]+\"([^\"]*)\".*" "\\1" OPENCV_VERSION_STATUS "${OPENCV_VERSION_PARTS}")

set(OPENCV_VERSION_PLAIN "${OPENCV_VERSION_MAJOR}.${OPENCV_VERSION_MINOR}.${OPENCV_VERSION_PATCH}")

set(OPENCV_VERSION "${OPENCV_VERSION_PLAIN}${OPENCV_VERSION_STATUS}")

set(OPENCV_SOVERSION "${OPENCV_VERSION_MAJOR}.${OPENCV_VERSION_MINOR}")
set(OPENCV_LIBVERSION "${OPENCV_VERSION_MAJOR}.${OPENCV_VERSION_MINOR}.${OPENCV_VERSION_PATCH}")

# create a dependency on the version file
# we never use the output of the following command but cmake will rerun automatically if the version file changes
configure_file("${OPENCV_VERSION_FILE}" "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/_junk/version.junk" COPYONLY)

ocv_update(OPENCV_VS_VER_FILEVERSION_QUAD "${OPENCV_VERSION_MAJOR},${OPENCV_VERSION_MINOR},${OPENCV_VERSION_PATCH},0")
ocv_update(OPENCV_VS_VER_PRODUCTVERSION_QUAD "${OPENCV_VERSION_MAJOR},${OPENCV_VERSION_MINOR},${OPENCV_VERSION_PATCH},0")
ocv_update(OPENCV_VS_VER_FILEVERSION_STR "${OPENCV_VERSION}")
ocv_update(OPENCV_VS_VER_PRODUCTVERSION_STR "${OPENCV_VERSION}")
ocv_update(OPENCV_VS_VER_PRODUCTNAME_STR "Irrlicht library")
ocv_update(OPENCV_VS_VER_COMMENTS_STR "http://irrlicht.sourceforge.net/")
