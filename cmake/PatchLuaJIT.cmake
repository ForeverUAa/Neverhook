if(NOT DEFINED LUAJIT_CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "LUAJIT_CMAKE_SOURCE_DIR is required")
endif()

set(LUAJIT_CMAKE_FILE "${LUAJIT_CMAKE_SOURCE_DIR}/LuaJIT.cmake")
file(READ "${LUAJIT_CMAKE_FILE}" CONTENT)

# The wrapper uses an old Geode/Xcode helper which no longer exists.
string(REPLACE
    "set_xcode_property(libluajit IPHONEOS_DEPLOYMENT_TARGET \"9.0\" \"all\")"
    "set_target_properties(libluajit PROPERTIES XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET \"9.0\")"
    CONTENT "${CONTENT}"
)

# luajit-cmake's iOS assembly rule uses the old ARCHS variable. On modern
# CMake, CMAKE_OSX_ARCHITECTURES is the authoritative value; ARCHS can be
# empty, which produces the broken '-arch -isysroot' command.
string(REPLACE
    "COMPILE_FLAGS \"-arch \${ARCHS} -isysroot \${CMAKE_OSX_SYSROOT} \${BITCODE}\""
    "COMPILE_FLAGS \"-arch \${CMAKE_OSX_ARCHITECTURES} -isysroot \${CMAKE_OSX_SYSROOT} \${BITCODE}\""
    CONTENT "${CONTENT}"
)

# buildvm is a HOST executable even when LuaJIT itself is cross-compiled.
# The upstream wrapper creates a nested CMake project, so explicitly clear
# the Android toolchain/target and use the host compiler for that project.
string(REPLACE
    [=[            ${CMAKE_CURRENT_LIST_DIR}/host/buildvm
            -DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
            -DLUAJIT_DIR=${LUAJIT_DIR}]=]
    [=[            ${CMAKE_CURRENT_LIST_DIR}/host/buildvm
            -DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
            -DLUAJIT_DIR=${LUAJIT_DIR}
            -DCMAKE_C_FLAGS=
            -DCMAKE_C_COMPILER=cc
            -DCMAKE_C_COMPILER_TARGET=
            -DCMAKE_TOOLCHAIN_FILE=
            -DEXTRA_COMPILER_FLAGS=-DLUAJIT_TARGET=LUAJIT_ARCH_ARM]=]
    CONTENT "${CONTENT}"
)

file(WRITE "${LUAJIT_CMAKE_FILE}" "${CONTENT}")

# buildvm must be a native host executable, but it must generate code for
# the target architecture. Android32 needs a 32-bit host tool, while iOS and
# Android64 can use the native 64-bit host compiler.
string(REPLACE
    "-DEXTRA_COMPILER_FLAGS=-DLUAJIT_TARGET=LUAJIT_ARCH_ARM]"
    "-DEXTRA_COMPILER_FLAGS=-DLUAJIT_TARGET=LUAJIT_ARCH_ARM64]"
    CONTENT "${CONTENT}"
)
