class School {
  final int id;
  final String name;
  final String description;
  final String imagePath;
  final String location;
  final double rating;

  School({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.location,
    this.rating = 4.5,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      location: json['location'],
      rating: (json['rating'] ?? 4.5).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'location': location,
      'rating': rating,
    };
  }
}
