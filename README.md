# HTTP Clients

A composable, Future-based library for making HTTP requests.

This package contains a set of high-level functions and Client classes which has added behavior to make it easy to consume HTTP resources. It's multi-platform, and supports mobile, desktop, and the browser.

## Features

- A RestClient that de/serializes models on request and response.
- A RequestClient that lets you modify request url and headers.
- InterceptorClient, RequestInterceptorClient, and ResponseInterceptorClient where the interceptors are called on request, and response.
- ConverterClient, RequestConverterClient, and ResponseConverterClient where the converters are called before request, and after response to modify them.

## Additional information

- For comparing client performance from this package, I've included benchmarks for these clients, and Client() from the http package with no external dependency in `benchmarks/` directory.
