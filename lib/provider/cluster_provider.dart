// lib/provider/cluster_provider.dart
import 'package:primamobile/app/models/cluster/product_cluster.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ClusterProvider {
  // Fetch product clusters using KMeans
  Future<List<ProductCluster>> getProductClusters({
    required DateTime startDate,
    required DateTime endDate,
    required int numberOfClusters,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'start': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'k': numberOfClusters,
    };

    final RequestParam param = RequestParam(parameters: queryParameters);
    final RequestObject request = RequestObjectFunction(requestParam: param);
    try {
      final response = await dioClient.get(
        '/cluster',
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
      print('Error fetching product clusters: $e');
      rethrow;
    }
  }
}
