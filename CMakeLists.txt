cmake_minimum_required(VERSION 3.12)
project(fibonacci_cpp)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(pybind11 REQUIRED)

pybind11_add_module(fibonacci_cpp src/fibonacci.cpp)

target_compile_definitions(fibonacci_cpp PRIVATE VERSION_INFO=${EXAMPLE_VERSION_INFO})