class Product {
  final String upc;
  final String name;
  final double netPrice;
  final double displayPrice;
  final int stock;
  final String category;
  final String brand;
  final bool active;
  final DateTime? lastUpdated;
  Product({
    required this.upc,
    required this.name,
    required this.netPrice,
    required this.displayPrice,
    required this.stock,
    required this.category,
    required this.brand,
    required this.active,
    this.lastUpdated,
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
      active: json['active'] as bool,
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
      'active': active,
      if (lastUpdated != null) 'last_updated': lastUpdated!.toIso8601String(),
    };
  }

  // Method for partial update JSON (exclude upc and last_updated)
  Map<String, dynamic> toPartialJson() {
    final map = <String, dynamic>{};
    // Only include fields that can be updated
    map['name'] = name;
    map['net_price'] = netPrice;
    map['display_price'] = displayPrice;
    map['stock'] = stock;
    map['category'] = category;
    map['brand'] = brand;
    // Exclude 'upc', 'active', and 'last_updated'
    return map;
  }
}
