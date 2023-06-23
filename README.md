# Handle HTTP Clients & Services

<p align="center">
<a href="https://pub.dev/packages/handle"><img src="https://img.shields.io/pub/v/handle.svg" alt="Pub"></a>
<a href="https://github.com/predatorx7/handle/actions/workflows/handle_test.yaml"><img src="https://github.com/predatorx7/handle/actions/workflows/handle_test.yaml/badge.svg" alt="handle_test"></a>
<a href="https://codecov.io/gh/predatorx7/handle" >
<img src="https://codecov.io/gh/predatorx7/handle/branch/main/graph/badge.svg?token=FIQIP0GYHK"/>
</a>
</p>

A simple library for composing HTTP clients, and creating services to make HTTP requests. Uses the [package:http's Client](https://pub.dev/documentation/http/latest/http/Client-class.html).

This can be used as an alternative to http client generator libraries like [retrofit](https://pub.dev/packages/retrofit), and [chopper](https://pub.dev/packages/chopper).

## Features

Handle has number of features to make HTTP requests flexible, and easy to use:

- Combine different client to create the perfect HTTP client for your needs.
- Compatibility with [package:http's Client](https://pub.dev/documentation/http/latest/http/Client-class.html) - You can wrap with existing http Clients, like [RetryClient](https://pub.dev/documentation/http/latest/retry/RetryClient-class.html)
- Very minimum boilerplate for creating REST requests, and services with no code generation.
- Extensive test suite and benchmarks to ensure reliability, and high performance.

## Documentation
See the API documentation for details on the following topics:

- [Getting started](https://pub.dev/documentation/handle/latest/topics/Get%20started-topic.html)
- [Configuration](https://pub.dev/documentation/handle/latest/topics/Configuration-topic.html)
- [Clients](https://pub.dev/documentation/handle/latest/topics/Clients-topic.html)
- [Services](https://pub.dev/documentation/handle/latest/topics/Services-topic.html)
- [Extensions](https://pub.dev/documentation/handle/latest/topics/Extensions-topic.html)
- [Error handling](https://pub.dev/documentation/handle/latest/topics/Error%20handling-topic.html)
- [Example](https://pub.dev/packages/handle/example)

<!-- ## Migration guides

- [Migrating to 1.0](https://pub.dev/documentation/handle/latest/topics/breaking-changes-v1-topic.html) -->

### Latest benchmark results

For comparing client performance from this package, I've included benchmarks for this library's clients, and [package:http's Client](https://pub.dev/documentation/http/latest/http/Client-class.html) with no external dependency in `benchmarks/` directory.

```
HttpClientListSerializationBenchmark(RunTime): 1788231.5 us.
RestClientListSerializationBenchmark(RunTime): 1745168.5 us.
RestClientListAsyncSerializationBenchmark(RunTime): 1832672.0 us.
HttpClientSingleSerializationBenchmark(RunTime): 1257598.0 us.
RestClientSingleSerializationBenchmark(RunTime): 1257561.0 us.
RestClientSingleAsyncSerializationBenchmark(RunTime): 1262549.0 us.
```

Benchmarks last updated on 20 June, 2023.
