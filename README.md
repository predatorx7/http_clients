# HTTP Clients

<p align="center">
<a href="https://pub.dev/packages/http_clients"><img src="https://img.shields.io/pub/v/http_clients.svg" alt="Pub"></a>
<a href="https://github.com/predatorx7/http_clients/actions/workflows/http_clients.yaml"><img src="https://github.com/predatorx7/http_clients/actions/workflows/http_clients.yaml/badge.svg" alt="http_clients"></a>
<a href="https://codecov.io/gh/predatorx7/http_clients" >
<img src="https://codecov.io/gh/predatorx7/http_clients/branch/main/graph/badge.svg?token=B30DQIWOMP"/>
</a>
</p>

A composable, Future-based library for making HTTP requests.

This package contains a set of high-level functions and Client classes which has added behavior to make it easy to consume HTTP resources. It's multi-platform, and supports mobile, desktop, and the browser.

## Features

- A RestClient that de/serializes models on request and response.
- A RequestClient that lets you modify request url and headers.
- InterceptorClient, RequestInterceptorClient, and ResponseInterceptorClient where the interceptors are called on request, and response.
- ConverterClient, RequestConverterClient, and ResponseConverterClient where the converters are called before request, and after response to modify them.

## Install

Add to your app or package

### Using git

Add to your dependencies in `pubspec.yaml`
```yaml
  http_clients:
    git: 
      url: https://github.com/predatorx7/http_clients.git
```

## Additional information

- For comparing client performance from this package, I've included benchmarks for these clients, and Client() from the http package with no external dependency in `benchmarks/` directory.
