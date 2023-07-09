# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(plugin_filtering_library VERSION 0.0.1 LANGUAGES C CXX)
set (CMAKE_CXX_STANDARD 11)
add_library(plugin_filtering SHARED
        "plugin_filtering.cpp"
        "include/dart_api_dl.c"
        "streamswtqua.cpp"
        "commalgorithm.cpp"
        "swt.cpp"

)

set_target_properties(plugin_filtering PROPERTIES
  PUBLIC_HEADER plugin_filtering.h
  OUTPUT_NAME "plugin_filtering"
)

target_compile_definitions(plugin_filtering PUBLIC DART_SHARED_LIB)
