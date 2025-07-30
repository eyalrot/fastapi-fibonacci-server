#!/usr/bin/env python3
import requests
import sys

BASE_URL = "http://localhost:8000"


def test_root():
    print("Testing root endpoint...")
    response = requests.get(f"{BASE_URL}/")
    assert response.status_code == 200
    data = response.json()
    print(f"✓ Root endpoint: {data}")
    return data.get("cpp_module_available", False)


def test_fibonacci_endpoint():
    print("\nTesting Fibonacci endpoint...")

    # Test basic calculation
    response = requests.get(f"{BASE_URL}/fibonacci/10")
    assert response.status_code == 200
    data = response.json()
    assert data["result"] == 55
    print(f"✓ Fibonacci(10) = {data['result']}")

    # Test different algorithms
    algorithms = ["iterative", "recursive", "recursive_memo"]
    for algo in algorithms:
        response = requests.get(f"{BASE_URL}/fibonacci/20?algorithm={algo}")
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == 6765
        print(
            f"✓ Fibonacci(20) with {algo}: {data['result']} (time: {data['computation_time_ms']:.3f}ms)"
        )

    # Test error handling
    response = requests.get(f"{BASE_URL}/fibonacci/-1")
    assert response.status_code == 400
    print("✓ Negative input validation works")

    response = requests.get(f"{BASE_URL}/fibonacci/50?algorithm=recursive")
    assert response.status_code == 400
    print("✓ Recursive limit validation works")


def test_cpp_implementation(cpp_available):
    if not cpp_available:
        print("\n⚠ C++ module not available, skipping C++ tests")
        return

    print("\nTesting C++ implementation...")

    response = requests.get(f"{BASE_URL}/fibonacci/50?implementation=cpp")
    assert response.status_code == 200
    data = response.json()
    assert data["implementation"] == "cpp"
    print(f"✓ C++ implementation: Fibonacci(50) = {data['result']}")

    # Compare with Python
    response_py = requests.get(f"{BASE_URL}/fibonacci/50?implementation=python")
    assert response_py.json()["result"] == data["result"]
    print("✓ C++ and Python results match")


def test_benchmark():
    print("\nTesting benchmark endpoint...")

    response = requests.get(f"{BASE_URL}/benchmark/30")
    assert response.status_code == 200
    data = response.json()

    print("\nBenchmark results for n=30:")
    print("-" * 50)

    for impl, result in sorted(data["results"].items()):
        if "time_ms" in result and result["time_ms"] is not None:
            print(
                f"{impl:20} | {result['time_ms']:10.3f}ms | result: {result['result']}"
            )
        else:
            print(f"{impl:20} | Error: {result.get('error', 'Unknown')}")

    print("-" * 50)

    # Verify all implementations give same result
    results = [r["result"] for r in data["results"].values() if "result" in r]
    assert all(
        r == results[0] for r in results
    ), "All implementations should return the same result"
    print("✓ All implementations return consistent results")


def main():
    try:
        print("=== FastAPI Fibonacci Server Test Suite ===\n")

        # Test root endpoint and check C++ availability
        cpp_available = test_root()

        # Test Fibonacci endpoint
        test_fibonacci_endpoint()

        # Test C++ implementation if available
        test_cpp_implementation(cpp_available)

        # Test benchmark endpoint
        test_benchmark()

        print("\n✅ All tests passed!")

    except requests.exceptions.ConnectionError:
        print(
            "❌ Error: Cannot connect to server. Make sure the server is running on http://localhost:8000"
        )
        sys.exit(1)
    except AssertionError as e:
        print(f"❌ Test failed: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
