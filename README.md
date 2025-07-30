# FastAPI Fibonacci Server

[![CI](https://github.com/eyalrot/fastapi-fibonacci-server/actions/workflows/ci.yml/badge.svg)](https://github.com/eyalrot/fastapi-fibonacci-server/actions/workflows/ci.yml)
[![Python Versions](https://img.shields.io/badge/python-3.8%20%7C%203.9%20%7C%203.10%20%7C%203.11%20%7C%203.12-blue)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A high-performance Fibonacci calculator API with both Python and C++ implementations.

## Features

- FastAPI-based REST API
- Multiple Fibonacci algorithms (iterative, recursive, recursive with memoization)
- Both Python and C++ implementations for performance comparison
- Automatic API documentation via FastAPI
- Input validation and error handling

## Installation

### Prerequisites
- Python 3.8+
- C++ compiler (g++ or clang++)
- pip

### Setup

1. Install Python dependencies:
```bash
pip install -r requirements.txt
```

2. Build the C++ extension:
```bash
python setup.py build_ext --inplace
```

## Running the Server

```bash
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

Or run directly:
```bash
python main.py
```

## API Endpoints

### GET /
Returns API information and C++ module availability status.

### GET /fibonacci/{n}
Calculate the nth Fibonacci number.

Parameters:
- `n` (path): The index of the Fibonacci number (0-10000)
- `algorithm` (query, optional): Algorithm to use
  - `iterative` (default)
  - `recursive` (limited to n<=40)
  - `recursive_memo`
- `implementation` (query, optional): Implementation to use
  - `auto` (default) - uses C++ if available
  - `python`
  - `cpp`

Example:
```bash
curl "http://localhost:8000/fibonacci/100?algorithm=iterative&implementation=cpp"
```

### GET /benchmark/{n}
Compare performance of all implementations for calculating the nth Fibonacci number.

Example:
```bash
curl http://localhost:8000/benchmark/35
```

### GET /docs
Interactive API documentation (Swagger UI)

## Performance Comparison

The C++ implementation provides significant performance improvements:

- **Iterative**: ~1.5x faster than Python
- **Recursive**: ~67x faster than Python
- **Recursive with memoization**: ~7x faster than Python

Example benchmark results for n=35:
- Python recursive: ~2084ms
- C++ recursive: ~31ms
- Python iterative: ~0.017ms
- C++ iterative: ~0.011ms

## Project Structure

```
/workspace/
├── main.py              # FastAPI application
├── src/
│   └── fibonacci.cpp    # C++ implementation
├── setup.py            # Build configuration
├── CMakeLists.txt      # CMake configuration (optional)
├── requirements.txt    # Python dependencies
├── test_api.py        # API test script
└── README.md          # This file
```

## Testing

Run the test script to verify the API:
```bash
python test_api.py
```

## Notes

- The recursive algorithm without memoization is limited to n<=40 to prevent excessive computation time
- The C++ module will automatically be used when available for better performance
- All Fibonacci calculations use 64-bit integers to handle large numbers

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/eyalrot/fastapi-fibonacci-server.git
   cd fastapi-fibonacci-server
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   pip install black flake8 pytest
   ```

4. Build the C++ extension:
   ```bash
   python setup.py build_ext --inplace
   ```

### Code Style

- Use Black for Python code formatting
- Follow PEP 8 guidelines
- Add type hints where possible
- Write meaningful commit messages

### Running Tests Locally

Before submitting a PR, ensure all tests pass:

```bash
# Format code
black main.py test_api.py

# Lint code
flake8 main.py test_api.py --max-line-length=127

# Run tests
python test_api.py
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- FastAPI for the excellent web framework
- pybind11 for seamless Python/C++ integration
- The Python and C++ communities for their amazing tools and libraries