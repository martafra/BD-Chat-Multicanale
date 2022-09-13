cmake_minimum_required(VERSION 3.13)
project(treno C)

set(CMAKE_C_STANDARD 11)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
find_package(MySQL REQUIRED)


add_executable( ${PROJECT_NAME}
    main.c
    amministratore.c
    capotreno.c
    manutentore.c
    passegero.c
    macchinista.c
)

add_subdirectory(support)

target_include_directories(${PROJECT_NAME} PUBLIC support)

target_link_directories(${PROJECT_NAME} PRIVATE support)

target_link_libraries(${PROJECT_NAME} support)

include_directories(${MYSQL_INCLUDE_DIR})

target_link_libraries(${PROJECT_NAME}  ${MYSQL_LIBRARIES})

if(MSVC)
    add_compile_options(PRIVATE /W4 /WX)
else()
    add_compile_options(PRIVATE -Wall -Wextra -Wpedantic -Werror)
endif()
