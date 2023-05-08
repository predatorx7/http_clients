import 'dart:convert';

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

Map<T, V>? mergeMapIfNotEmptyElseNull<T, V>(Iterable<Map<T, V>> lists) {
  final Map<T, V> items = {};
  for (final list in lists) {
    if (list.isNotEmpty) {
      items.addAll(list);
    }
  }

  if (items.isNotEmpty) return items;
  return null;
}

Object? tryDecodeJson(String source) {
  if (source.isEmpty) return null;
  try {
    return json.decode(source);
  } catch (_) {
    return null;
  }
}
