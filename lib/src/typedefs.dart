typedef PathJoinCallback = Iterable<String> Function(
  Uri url,
  Uri original,
);

typedef FromJsonCallback<T> = T? Function(Object? json);
