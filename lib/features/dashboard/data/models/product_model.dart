import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String description;
  final int stock;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.stock,
  });

  // Tambahkan getter ini di ProductModel
  double get dummyRating {
    final ratings = [
      4.8,
      4.5,
      4.9,
      4.7,
      4.6,
      4.8,
      4.5,
      4.7,
      4.9,
      4.6,
      4.8,
      4.7,
      4.5,
      4.9,
    ];
    return ratings[id % ratings.length];
  }

  int get dummyReviewCount {
    final counts = [12, 8, 15, 10, 7, 20, 5, 9, 18, 11, 6, 14, 8, 16];
    return counts[id % counts.length];
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] ?? 0,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'] as String,
    category: json['category'] as String,
    description: json['description'] ?? '',
    stock: json['stock'] ?? 0,
  );

  @override
  List<Object?> get props => [id, name, price, category, description, stock];
}
