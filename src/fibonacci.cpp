#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <unordered_map>
#include <cstdint>

namespace py = pybind11;

int64_t fibonacci_iterative(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    
    int64_t a = 0, b = 1;
    for (int i = 2; i <= n; ++i) {
        int64_t temp = a + b;
        a = b;
        b = temp;
    }
    return b;
}

int64_t fibonacci_recursive(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    return fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2);
}

static std::unordered_map<int, int64_t> memo;

int64_t fibonacci_recursive_memo(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;
    
    auto it = memo.find(n);
    if (it != memo.end()) {
        return it->second;
    }
    
    int64_t result = fibonacci_recursive_memo(n - 1) + fibonacci_recursive_memo(n - 2);
    memo[n] = result;
    return result;
}

void clear_memo() {
    memo.clear();
}

PYBIND11_MODULE(fibonacci_cpp, m) {
    m.doc() = "Fibonacci C++ implementation with pybind11";
    
    m.def("fibonacci_iterative", &fibonacci_iterative, "Calculate Fibonacci number iteratively",
          py::arg("n"));
    
    m.def("fibonacci_recursive", &fibonacci_recursive, "Calculate Fibonacci number recursively",
          py::arg("n"));
    
    m.def("fibonacci_recursive_memo", &fibonacci_recursive_memo, 
          "Calculate Fibonacci number recursively with memoization",
          py::arg("n"));
    
    m.def("clear_memo", &clear_memo, "Clear the memoization cache");
}