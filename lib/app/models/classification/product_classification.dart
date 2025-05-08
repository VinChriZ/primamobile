// lib/app/models/classification/product_classification.dart
import 'package:equatable/equatable.dart';

class ProductClassification extends Equatable {
  final String upc;
  final int cluster;
  final String category;

  const ProductClassification({
    required this.upc,
    required this.cluster,
    required this.category,
  });

  factory ProductClassification.fromJson(Map<String, dynamic> json) {
    return ProductClassification(
      upc: json['upc'],
      cluster: json['cluster'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upc': upc,
      'cluster': cluster,
      'category': category,
    };
  }

  @override
  List<Object?> get props => [upc, cluster, category];
}
