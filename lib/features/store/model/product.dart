class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.description,
  });

  final String description;
  final int id;
  final String title;
  final double price;
  final String category;
  final String image;
  final double rating;
  final int reviewCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rating = json['rating'];
    if (json['id'] is! int ||
        json['title'] is! String ||
        json['price'] is! num ||
        json['category'] is! String ||
        json['description'] is! String ||
        json['image'] is! String ||
        rating is! Map<String, dynamic> ||
        rating['rate'] is! num ||
        rating['count'] is! int) {
      throw const FormatException('Invalid product fields');
    }
    final price = (json['price'] as num).toDouble();
    final rate = (rating['rate'] as num).toDouble();
    if (!price.isFinite ||
        price < 0 ||
        !rate.isFinite ||
        rate < 0 ||
        rate > 5 ||
        (rating['count'] as int) < 0) {
      throw const FormatException('Invalid product values');
    }
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: price,
      category: json['category'] as String,
      image: json['image'] as String,
      rating: rate,
      reviewCount: rating['count'] as int,
    );
  }
}
