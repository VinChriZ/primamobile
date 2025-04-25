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
    return await _provider.getProductClusters(
      startDate: startDate,
      endDate: endDate,
      clusters: numberOfClusters,
    );
  }
}
