import 'package:benchmark_harness/benchmark_harness.dart';

abstract class AsyncBenchmark extends AsyncBenchmarkBase {
  AsyncBenchmark(super.name, [this.tries = 20]);

  final int tries;

  @override
  Future<void> exercise() async {
    for (var i = 0; i < tries; i++) {
      await run();
    }
  }
}

abstract class Benchmark extends BenchmarkBase {
  Benchmark(super.name, [this.tries = 20]);

  final int tries;

  @override
  void exercise() {
    for (var i = 0; i < tries; i++) {
      run();
    }
  }
}

class BenchmarkRunner {
  final List<AsyncBenchmarkBase> asyncBenchmarks;
  final List<BenchmarkBase> benchmarks;

  const BenchmarkRunner({
    this.asyncBenchmarks = const [],
    this.benchmarks = const [],
  });

  Future<void> run() async {
    for (final benchmark in benchmarks) {
      benchmark.report();
    }

    for (final benchmark in asyncBenchmarks) {
      await benchmark.report();
    }
  }
}
