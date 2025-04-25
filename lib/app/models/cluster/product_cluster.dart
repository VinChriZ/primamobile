// lib/app/models/cluster/product_cluster.dart

class ProductCluster {
  final String upc;
  final double totalSales;
  final int daysSold;
  final double avgDailySales;
  final int cluster;

  ProductCluster({
    required this.upc,
    required this.totalSales,
    required this.daysSold,
    required this.avgDailySales,
    required this.cluster,
  });

  // Create a ProductCluster object from JSON
  factory ProductCluster.fromJson(Map<String, dynamic> json) {
    return ProductCluster(
      upc: json['upc'],
      totalSales: (json['total_sales'] as num).toDouble(),
      daysSold: json['days_sold'],
      avgDailySales: (json['avg_daily_sales'] as num).toDouble(),
      cluster: json['cluster'],
    );
  }

  // Convert a ProductCluster object to JSON
  Map<String, dynamic> toJson() {
    return {
      'upc': upc,
      'total_sales': totalSales,
      'days_sold': daysSold,
      'avg_daily_sales': avgDailySales,
      'cluster': cluster,
    };
  }
}
