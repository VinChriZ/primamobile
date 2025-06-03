// lib/app/models/cluster/product_cluster.dart

class ProductCluster {
  final String upc;
  final double totalSales;
  final int daysSold;
  final double avgDailySales;
  final double maxDailySales;
  final double stdDailySales;
  final int daysSinceLastSale;
  final int txCount;
  final int cluster;

  ProductCluster({
    required this.upc,
    required this.totalSales,
    required this.daysSold,
    required this.avgDailySales,
    required this.maxDailySales,
    required this.stdDailySales,
    required this.daysSinceLastSale,
    required this.txCount,
    required this.cluster,
  });
  // Create a ProductCluster object from JSON
  factory ProductCluster.fromJson(Map<String, dynamic> json) {
    return ProductCluster(
      upc: json['upc'],
      totalSales: (json['total_sales'] as num).toDouble(),
      daysSold: json['days_sold'],
      avgDailySales: (json['avg_daily_sales'] as num).toDouble(),
      maxDailySales: (json['max_daily_sales'] as num).toDouble(),
      stdDailySales: (json['std_daily_sales'] as num).toDouble(),
      daysSinceLastSale: json['days_since_last_sale'],
      txCount: json['tx_count'],
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
      'max_daily_sales': maxDailySales,
      'std_daily_sales': stdDailySales,
      'days_since_last_sale': daysSinceLastSale,
      'tx_count': txCount,
      'cluster': cluster,
    };
  }
}
