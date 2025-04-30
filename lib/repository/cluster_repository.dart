// lib/repository/cluster_repository.dart
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/provider/cluster_provider.dart';

class ClusterRepository {
  final ClusterProvider _provider = ClusterProvider();

  // Fetch product clusters with optional clustering parameters
  Future<List<ProductCluster>> fetchProductClusters({
    required DateTime startDate,
    required DateTime endDate,
    int numberOfClusters = 3,
  }) async {
    try {
      // Ensure numberOfClusters is valid (between 2-5)
      numberOfClusters = numberOfClusters.clamp(2, 5);

      return await _provider.getProductClusters(
        startDate: startDate,
        endDate: endDate,
        clusters: numberOfClusters,
      );
    } catch (e) {
      // Check if this is a "too few samples" error and provide a more user-friendly message
      if (e.toString().contains('n_samples=') &&
          e.toString().contains('should be >=')) {
        throw Exception(
            'Not enough sales data in the selected period to form $numberOfClusters clusters. Try selecting a different time period or reducing the number of clusters.');
      } else if (e.toString().contains('No sales data available')) {
        throw Exception(
            'No sales data available for the selected period. Please try a different date range.');
      }
      rethrow;
    }
  }

  // Helper method to determine the maximum possible clusters based on data size
  Future<int> getRecommendedClusterCount({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Try with 2 clusters as a baseline
      final data = await _provider.getProductClusters(
        startDate: startDate,
        endDate: endDate,
        clusters: 2,
      );

      // Based on the data size, recommend a cluster count
      if (data.length < 3) return 2;
      if (data.length < 10) return 2;
      if (data.length < 20) return 3;
      return 3; // Default for larger datasets
    } catch (e) {
      // If any error occurs, recommend the minimum
      return 2;
    }
  }
}
