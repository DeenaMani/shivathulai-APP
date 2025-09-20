class Group {
  final int id;
  final String name;
  final String image;

  Group({required this.id, required this.name, required this.image});

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(id: json['id'], name: json['name'], image: json['image']);
  }
}
