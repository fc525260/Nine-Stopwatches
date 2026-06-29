cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

set(STOPWATCH_CORE_DIR "${CMAKE_SOURCE_DIR}/../rust/stopwatch_core")
set(STOPWATCH_CORE_TARGET_DIR "${CMAKE_BINARY_DIR}/stopwatch_core")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(STOPWATCH_CORE_PROFILE "debug")
  set(STOPWATCH_CORE_RELEASE_FLAG "")
else()
  set(STOPWATCH_CORE_PROFILE "release")
  set(STOPWATCH_CORE_RELEASE_FLAG "--release")
endif()
set(STOPWATCH_CORE_LIB
  "${STOPWATCH_CORE_TARGET_DIR}/${STOPWATCH_CORE_PROFILE}/stopwatch_core.lib")

add_custom_command(
  OUTPUT "${STOPWATCH_CORE_LIB}"
  COMMAND cargo build ${STOPWATCH_CORE_RELEASE_FLAG}
    --manifest-path "${STOPWATCH_CORE_DIR}/Cargo.toml"
    --target-dir "${STOPWATCH_CORE_TARGET_DIR}"
  WORKING_DIRECTORY "${STOPWATCH_CORE_DIR}"
  COMMENT "Building Rust stopwatch core"
  VERBATIM
)

add_custom_target(stopwatch_core_rust DEPENDS "${STOPWATCH_CORE_LIB}")

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
add_dependencies(${BINARY_NAME} stopwatch_core_rust)
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib" "ntdll.lib")
target_link_libraries(${BINARY_NAME} PRIVATE "${STOPWATCH_CORE_LIB}")
target_link_options(${BINARY_NAME} PRIVATE
  "/INCLUDE:nine_stopwatches_add_ms"
  "/INCLUDE:nine_stopwatches_format"
  "/EXPORT:nine_stopwatches_add_ms"
  "/EXPORT:nine_stopwatches_format"
)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
