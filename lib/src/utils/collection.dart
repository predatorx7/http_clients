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
