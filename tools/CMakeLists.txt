
if(NOT WITH_BUILD_TOOLS)
  return()
endif()

set(CD ${CMAKE_CURRENT_LIST_DIR})

function(glob_sources result folder)
    file(GLOB res
        "${folder}/*.cpp"
        "${folder}/*.h")
    set(${result} ${res} PARENT_SCOPE)
endfunction()

# ----------------------------------------------------------------------------
# Tools.
# ----------------------------------------------------------------------------

glob_sources(IRR_TOOL_FILES_FILE_TO_HEADER    ${CD}/FileToHeader/)
glob_sources(IRR_TOOL_FILES_GUI_EDITOR        ${CD}/GUIEditor/)
glob_sources(IRR_TOOL_FILES_FONT_TOOL         ${CD}/IrrFontTool/newFontTool/)
glob_sources(IRR_TOOL_FILES_MESH_CONVERTER    ${CD}/MeshConverter/)

add_executable(FileToHeader         ${IRR_TOOL_FILES_FILE_TO_HEADER})

add_executable(GUIEditor            ${IRR_TOOL_FILES_GUI_EDITOR})
target_link_libraries(GUIEditor     Irrlicht)

add_executable(FontTool             ${IRR_TOOL_FILES_FONT_TOOL})
target_link_libraries(FontTool      Irrlicht)

add_executable(MeshConverter        ${IRR_TOOL_FILES_MESH_CONVERTER})
target_link_libraries(MeshConverter Irrlicht)

# Deploy the binary targets.
install(
  TARGETS FileToHeader GUIEditor FontTool MeshConverter
  RUNTIME DESTINATION tools/irrlicht/
  CONFIGURATIONS Release
)
