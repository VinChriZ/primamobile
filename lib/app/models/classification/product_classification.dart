// lib/app/models/classification/product_classification.dart
import 'package:equatable/equatable.dart';

class ProductClassification extends Equatable {
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
  final String category;

  const ProductClassification({
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
    required this.category,
  });

  factory ProductClassification.fromJson(Map<String, dynamic> json) {
    return ProductClassification(
      upc: json['upc'],
      totalSales: json['total_sales'].toDouble(),
      daysSold: json['days_sold'],
      avgDailySales: json['avg_daily_sales'].toDouble(),
      salesFrequency: json['sales_frequency'].toDouble(),
      maxDailySales: json['max_daily_sales'].toDouble(),
      minDailySales: json['min_daily_sales'].toDouble(),
      stdDailySales: json['std_daily_sales'].toDouble(),
      daysSinceLastSale: json['days_since_last_sale'],
      txCount: json['tx_count'],
      cluster: json['cluster'],
      category: json['category'],
    );
  }

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
      'category': category,
    };
  }

  @override
  List<Object?> get props => [
        upc,
        totalSales,
        daysSold,
        avgDailySales,
        salesFrequency,
        maxDailySales,
        minDailySales,
        stdDailySales,
        daysSinceLastSale,
        txCount,
        cluster,
        category,
      ];
}
