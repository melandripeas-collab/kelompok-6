class Item {
  final int id;
  final String title;
  final String? description;
  final double price;
  final int categoryId;
  final String? categoryName;

  Item({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
  });

  factory Item.fromJson(Map<String, dynamic> j) => Item(
    id: int.parse(j['id'].toString()),
    title: j['title'] ?? '',
    description: j['description'],
    price: double.tryParse(j['price'].toString()) ?? 0,
    categoryId: int.parse(j['category_id'].toString()),
    categoryName: j['category_name'],
  );
}
