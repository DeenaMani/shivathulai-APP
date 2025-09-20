// lib/models/category_model.dart

class Category {
  final int id;
  final String name;
  final String image;

  Category({required this.id, required this.name, required this.image});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }
}
