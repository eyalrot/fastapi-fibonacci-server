from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, Literal
import time

app = FastAPI(title="Fibonacci API", version="1.0.0")


class FibonacciResponse(BaseModel):
    n: int
    result: int
    algorithm: str
    computation_time_ms: float
    implementation: str


def fibonacci_iterative(n: int) -> int:
    if n <= 0:
        return 0
    elif n == 1:
        return 1

    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def fibonacci_recursive(n: int) -> int:
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2)


_memo = {}


def fibonacci_recursive_memo(n: int) -> int:
    if n in _memo:
        return _memo[n]

    if n <= 0:
        result = 0
    elif n == 1:
        result = 1
    else:
        result = fibonacci_recursive_memo(n - 1) + fibonacci_recursive_memo(n - 2)

    _memo[n] = result
    return result


cpp_available = False
try:
    import fibonacci_cpp

    cpp_available = True
except ImportError:
    pass


@app.get("/")
def root():
    return {
        "message": "Fibonacci API",
        "endpoints": ["/fibonacci/{n}", "/docs"],
        "cpp_module_available": cpp_available,
    }


@app.get("/fibonacci/{n}", response_model=FibonacciResponse)
def get_fibonacci(
    n: int,
    algorithm: Optional[Literal["iterative", "recursive", "recursive_memo"]] = Query(
        default="iterative", description="Algorithm to use for calculation"
    ),
    implementation: Optional[Literal["python", "cpp", "auto"]] = Query(
        default="auto",
        description="Implementation to use (auto will use C++ if available)",
    ),
):
    if n < 0:
        raise HTTPException(status_code=400, detail="n must be non-negative")

    if n > 40 and algorithm == "recursive":
        raise HTTPException(
            status_code=400,
            detail="For recursive algorithm without memoization, n must be <= 40 to avoid excessive computation time",
        )

    if n > 10000:
        raise HTTPException(status_code=400, detail="n must be <= 10000")

    use_cpp = False
    if implementation == "cpp":
        if not cpp_available:
            raise HTTPException(status_code=400, detail="C++ module not available")
        use_cpp = True
    elif implementation == "auto" and cpp_available:
        use_cpp = True

    start_time = time.perf_counter()

    try:
        if use_cpp:
            if algorithm == "iterative":
                result = fibonacci_cpp.fibonacci_iterative(n)
            elif algorithm == "recursive":
                result = fibonacci_cpp.fibonacci_recursive(n)
            else:  # recursive_memo
                result = fibonacci_cpp.fibonacci_recursive_memo(n)
        else:
            if algorithm == "iterative":
                result = fibonacci_iterative(n)
            elif algorithm == "recursive":
                result = fibonacci_recursive(n)
            else:  # recursive_memo
                _memo.clear()  # Clear memoization cache for consistent results
                result = fibonacci_recursive_memo(n)
    except RecursionError:
        raise HTTPException(
            status_code=400,
            detail=f"Recursion limit exceeded for n={n}. Use iterative algorithm or smaller n.",
        )

    end_time = time.perf_counter()
    computation_time_ms = (end_time - start_time) * 1000

    return FibonacciResponse(
        n=n,
        result=result,
        algorithm=algorithm,
        computation_time_ms=computation_time_ms,
        implementation="cpp" if use_cpp else "python",
    )


@app.get("/benchmark/{n}")
def benchmark_fibonacci(n: int):
    if n < 0:
        raise HTTPException(status_code=400, detail="n must be non-negative")

    results = {}

    # Python implementations
    algorithms = ["iterative", "recursive_memo"]
    if n <= 35:  # Only test recursive without memo for small n
        algorithms.append("recursive")

    for algo in algorithms:
        start_time = time.perf_counter()
        try:
            if algo == "iterative":
                result = fibonacci_iterative(n)
            elif algo == "recursive":
                result = fibonacci_recursive(n)
            else:  # recursive_memo
                _memo.clear()
                result = fibonacci_recursive_memo(n)

            end_time = time.perf_counter()
            results[f"python_{algo}"] = {
                "result": result,
                "time_ms": (end_time - start_time) * 1000,
            }
        except RecursionError:
            results[f"python_{algo}"] = {
                "error": "Recursion limit exceeded",
                "time_ms": None,
            }

    # C++ implementations if available
    if cpp_available:
        for algo in algorithms:
            start_time = time.perf_counter()
            try:
                if algo == "iterative":
                    result = fibonacci_cpp.fibonacci_iterative(n)
                elif algo == "recursive":
                    result = fibonacci_cpp.fibonacci_recursive(n)
                else:  # recursive_memo
                    result = fibonacci_cpp.fibonacci_recursive_memo(n)

                end_time = time.perf_counter()
                results[f"cpp_{algo}"] = {
                    "result": result,
                    "time_ms": (end_time - start_time) * 1000,
                }
            except Exception as e:
                results[f"cpp_{algo}"] = {"error": str(e), "time_ms": None}

    return {"n": n, "results": results, "cpp_available": cpp_available}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
