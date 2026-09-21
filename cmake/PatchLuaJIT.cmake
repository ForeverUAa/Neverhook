if(NOT DEFINED LUAJIT_CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "LUAJIT_CMAKE_SOURCE_DIR is required")
endif()

set(LUAJIT_CMAKE_FILE "\${LUAJIT_CMAKE_SOURCE_DIR}/LuaJIT.cmake")

file(READ "\${LUAJIT_CMAKE_FILE}" CONTENT)

string(REPLACE
    "set_xcode_property(libluajit IPHONEOS_DEPLOYMENT_TARGET \\"9.0\\" \\"all\\")"
    "set_target_properties(libluajit PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET \\"9.0\\")"
    CONTENT "\${CONTENT}"
)

string(REPLACE
    "            \${CMAKE_CURRENT_LIST_DIR}/host/buildvm
            -DCMAKE_SIZEOF_VOID_P=\${CMAKE_SIZEOF_VOID_P}"
    "            \${CMAKE_CURRENT_LIST_DIR}/host/buildvm
            -DCMAKE_SIZEOF_VOID_P=\${CMAKE_SIZEOF_VOID_P}
            -DCMAKE_C_COMPILER=cc
            -DCMAKE_C_COMPILER_TARGET=
            -DCMAKE_TOOLCHAIN_FILE="
    CONTENT "\${CONTENT}"
)

file(WRITE "\${LUAJIT_CMAKE_FILE}" "\${CONTENT}")
