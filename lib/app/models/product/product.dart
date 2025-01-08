class Product {
  final String upc;
  final String name;
  final double netPrice;
  final double displayPrice;
  final int stock;
  final String category;
  final String brand;
  final String? imageUrl; // New attribute
  final DateTime lastUpdated;

  Product({
    required this.upc,
    required this.name,
    required this.netPrice,
    required this.displayPrice,
    required this.stock,
    required this.category,
    required this.brand,
    this.imageUrl, // Optional
    required this.lastUpdated,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      upc: json['UPC'],
      name: json['Name'],
      netPrice: json['NetPrice'],
      displayPrice: json['DisplayPrice'],
      stock: json['Stock'],
      category: json['Category'],
      brand: json['Brand'],
      imageUrl: json['image_url'], // Can be null
      lastUpdated: DateTime.parse(json['last_updated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UPC': upc,
      'Name': name,
      'NetPrice': netPrice,
      'DisplayPrice': displayPrice,
      'Stock': stock,
      'Category': category,
      'Brand': brand,
      if (imageUrl != null) 'image_url': imageUrl,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
