bool isNullOrBlank(String? value) {
  return value == null ||
      value.isEmpty ||
      value.replaceAll(RegExp(r'\s+'), '').isEmpty;
}

String? whereStringNotBlankElseNull(Iterable<String> strings) {
  for (final it in strings) {
    if (!isNullOrBlank(it)) return it;
  }
  return null;
}
