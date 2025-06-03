// lib/app/models/cluster/product_cluster.dart

class ProductCluster {
  final String upc;
  final double totalSales;
  final int daysSold;
  final double avgDailySales;
  final double salesFrequency;
  final double maxDailySales;
  final double minDailySales;
  final double stdDailySales;
  final int daysSinceLastSale;
  final int txCount;
  final int cluster;
  final String? category; // Added category field

  ProductCluster({
    required this.upc,
    required this.totalSales,
    required this.daysSold,
    required this.avgDailySales,
    required this.salesFrequency,
    required this.maxDailySales,
    required this.minDailySales,
    required this.stdDailySales,
    required this.daysSinceLastSale,
    required this.txCount,
    required this.cluster,
    this.category,
  });
  // Create a ProductCluster object from JSON
  factory ProductCluster.fromJson(Map<String, dynamic> json) {
    return ProductCluster(
      upc: json['upc'],
      totalSales: (json['total_sales'] as num).toDouble(),
      daysSold: json['days_sold'],
      avgDailySales: (json['avg_daily_sales'] as num).toDouble(),
      salesFrequency: (json['sales_frequency'] as num).toDouble(),
      maxDailySales: (json['max_daily_sales'] as num).toDouble(),
      minDailySales: (json['min_daily_sales'] as num).toDouble(),
      stdDailySales: (json['std_daily_sales'] as num).toDouble(),
      daysSinceLastSale: json['days_since_last_sale'],
      txCount: json['tx_count'],
      cluster: json['cluster'],
      category: json['category'], // Parse category from JSON
    );
  }
  // Convert a ProductCluster object to JSON
  Map<String, dynamic> toJson() {
    return {
      'upc': upc,
      'total_sales': totalSales,
      'days_sold': daysSold,
      'avg_daily_sales': avgDailySales,
      'sales_frequency': salesFrequency,
      'max_daily_sales': maxDailySales,
      'min_daily_sales': minDailySales,
      'std_daily_sales': stdDailySales,
      'days_since_last_sale': daysSinceLastSale,
      'tx_count': txCount,
      'cluster': cluster,
      'category': category, // Include category in JSON
    };
  }
}
