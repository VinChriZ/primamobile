// lib/provider/cluster_provider.dart
import 'package:primamobile/app/models/cluster/product_cluster.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ClusterProvider {
  // Fetch product clusters
  Future<List<ProductCluster>> getProductClusters({
    required DateTime startDate,
    required DateTime endDate,
    int clusters = 3,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'start': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'k': clusters,
    };

    final RequestParam param = RequestParam(parameters: queryParameters);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/clusters/',
        queryParameters: await request.toJson(),
      );
      print('Get Product Clusters Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((item) => ProductCluster.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to fetch product clusters with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle the specific ValueError for n_samples < n_clusters
      if (e.toString().contains('n_samples=') &&
          e.toString().contains('should be >= n_clusters=')) {
        // Retry with fewer clusters - try with 2 clusters
        print(
            'Too few samples for requested clusters. Retrying with 2 clusters.');
        if (clusters > 2) {
          return getProductClusters(
            startDate: startDate,
            endDate: endDate,
            clusters: 2, // Try with minimum valid clusters
          );
        }
      }
      // If no data at all, throw a more specific error
      if (e.toString().contains('n_samples=0') ||
          e.toString().contains('Empty dataset')) {
        throw Exception('No sales data available for the selected date range.');
      }

      print('Error fetching product clusters: $e');
      rethrow;
    }
  }
}
