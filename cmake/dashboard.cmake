# ======================== Options =========================
status("")
status("  Options: ")

status("    Support for unicode:" WITH_UNICODE_PATH THEN YES ELSE NO)
status("    Fast math optimizations on FP computations (recommended):" WITH_FAST_MATH THEN YES ELSE NO)
status("    Building of tools:" WITH_BUILD_TOOLS THEN YES ELSE NO)

# ========================= Driver =========================
status("")
status("  Drivers: ")

status("    OpenGL:" "${opengl-registry_DIR} (HEADER-ONLY)")
status("    EGL:" "${egl-registry_DIR} (HEADER-ONLY)")

if(WITH_WIN32UI)
  status("    Win32 UI:" HAVE_WIN32UI THEN YES ELSE NO)
else()
  status("    Win32 UI:" UNAVAILABLE)
endif()

if(HAVE_ANGLE)
  status("    Angle:" "${Angle_DIR} (ver ${angle_VERSION})")
else()
  status("    Angle:" UNAVAILABLE)
endif()

if(HAVE_OPENGL)
  status("    OpenGL support:" HAVE_OPENGL THEN "YES (${OPENGL_LIBRARIES})" ELSE NO)
else()
  status("    OpenGL support:" UNAVAILABLE)
endif()

if(HAVE_VULKAN)
  status("")
  status("    Vulkan:" HAVE_VULKAN THEN "YES" ELSE "NO")
  status("      Include path:"  VULKAN_INCLUDE_DIRS THEN "${VULKAN_INCLUDE_DIRS}" ELSE "NO")
  status("      Link libraries:" VULKAN_LIBRARIES THEN "${VULKAN_LIBRARIES}" ELSE "Dynamic load")
else()
  status("    Vulkan:" UNAVAILABLE)
endif()

if(HAVE_DIRECTX)
  status("")
  status("    Direct-X:"   HAVE_DIRECTX THEN "YES" ELSE "NO")
  status("      Include path:"  DIRECTX_INCLUDE_DIRS THEN "${DIRECTX_INCLUDE_DIRS}" ELSE "NO")
  status("      Link libraries:" DIRECTX_LIBRARIES THEN "${DIRECTX_LIBRARIES}" ELSE "Dynamic load")
else()
  status("    Direct-X:" UNAVAILABLE)
endif()

# ========================== MEDIA IO ==========================
status("")
status("  I/O: ")

if(NOT HAVE_ZLIB)
  status("    ZLib:" NO)
else()
  status("    ZLib:" "${ZLIB_LIBRARY} (ver ${ZLIB_VERSION_STRING})")
endif()

if(NOT HAVE_AES)
  status("    AES:" NO)
else()
  status("    AES:" "${AES_LIBRARY} (ver ${AES_VERSION})")
endif()

if(NOT HAVE_BZIP2)
  status("    BZIP2:" NO)
else()
  status("    BZIP2:" "${BZIP2_LIBRARY} (ver ${BZIP2_VERSION_STRING})")
endif()

if(NOT HAVE_JPEG)
  status("    JPEG:" NO)
else()
  status("    JPEG:" "${JPEG_LIBRARY} (ver ${JPEG_VERSION})")
endif()

if(NOT HAVE_PNG)
  status("    PNG:" NO)
else()
  status("    PNG:" "${PNG_LIBRARY} (ver ${PNG_VERSION_STRING})")
endif()

if(NOT HAVE_LZMA)
  status("    LZMA:" NO)
else()
  status("    LZMA:" "${LZMA_LIBRARY} (ver ${LZMA_VERSION})")
endif()
