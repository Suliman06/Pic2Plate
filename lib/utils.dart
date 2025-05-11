
List<String> ensureStringList(dynamic items) {
  if (items == null) return [];
  if (items is String) return [items];
  if (items is List) return items.map((e) => e.toString()).toList();
  return [];
}