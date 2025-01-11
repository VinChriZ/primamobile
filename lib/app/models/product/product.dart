class Product {
  final String upc;
  final String name;
  final double netPrice;
  final double displayPrice;
  final int stock;
  final String category;
  final String brand;
  final String? imageUrl; // Optional
  final DateTime? lastUpdated; // New attribute

  Product({
    required this.upc,
    required this.name,
    required this.netPrice,
    required this.displayPrice,
    required this.stock,
    required this.category,
    required this.brand,
    this.imageUrl, // Optional
    this.lastUpdated, // Optional
  });

  // Factory constructor for deserializing from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      upc: json['upc'] as String,
      name: json['name'] as String,
      netPrice: (json['net_price'] as num).toDouble(),
      displayPrice: (json['display_price'] as num).toDouble(),
      stock: json['stock'] as int,
      category: json['category'] as String,
      brand: json['brand'] as String,
      imageUrl: json['image_url'] as String?,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null, // Parse date if available
    );
  }

  // Method for serializing to JSON
  Map<String, dynamic> toJson() {
    return {
      'upc': upc,
      'name': name,
      'net_price': netPrice,
      'display_price': displayPrice,
      'stock': stock,
      'category': category,
      'brand': brand,
      if (imageUrl != null) 'image_url': imageUrl,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }
}
