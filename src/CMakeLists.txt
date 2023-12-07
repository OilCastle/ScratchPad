# module path for CMake modules to be loaded by the include()
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR})

# app.cmake
include(app)

# Create the executable
add_executable(${PROJECT_NAME} ${app_srcs})

# include directories
target_include_directories(${PROJECT_NAME} PRIVATE
        ${app_include_dirs}) 

# compile options
target_compile_options(${PROJECT_NAME} PRIVATE
        ${app_compile_options})

# compile definitions
target_compile_definitions(${PROJECT_NAME} PRIVATE
        ${app_compile_definitions})

# Link the library
target_link_libraries(${PROJECT_NAME} PRIVATE m)
