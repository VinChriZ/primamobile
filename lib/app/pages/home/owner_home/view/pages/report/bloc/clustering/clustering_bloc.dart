import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/repository/cluster_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'clustering_event.dart';
part 'clustering_state.dart';

class ClusteringBloc extends Bloc<ClusteringEvent, ClusteringState> {
  final ClusterRepository clusterRepository;
  final ProductRepository productRepository;

  ClusteringBloc({
    required this.clusterRepository,
    required this.productRepository,
  }) : super(ClusteringInitial()) {
    on<LoadClusteringEvent>(_onLoadClustering);
    on<ChangeClusteringFilterEvent>(_onChangeFilter);
    on<LoadClusteringByYearEvent>(_onLoadClusteringByYear);
  }

  Future<void> _onLoadClustering(
      LoadClusteringEvent event, Emitter<ClusteringState> emit) async {
    emit(ClusteringLoading(
      startDate: event.startDate,
      endDate: event.endDate,
      numberOfClusters: event.numberOfClusters,
    ));
    try {
      // If dates are not provided, default to the entire current year
      final DateTime now = DateTime.now();
      final DateTime endDate = event.endDate ?? DateTime(now.year, 12, 31);
      final DateTime startDate = event.startDate ?? DateTime(now.year, 1, 1);

      // Get a safe number of clusters based on data availability
      int safeNumberOfClusters = event.numberOfClusters;
      if (safeNumberOfClusters > 2) {
        try {
          safeNumberOfClusters =
              await clusterRepository.getRecommendedClusterCount(
            startDate: startDate,
            endDate: endDate,
          );

          // Only inform if we needed to reduce the number of clusters
          if (safeNumberOfClusters < event.numberOfClusters) {
            print(
                'Reduced clusters from ${event.numberOfClusters} to $safeNumberOfClusters due to limited data');
          }
        } catch (e) {
          // If recommendation fails, use a safe default
          safeNumberOfClusters = 2;
          print('Using default of $safeNumberOfClusters clusters due to: $e');
        }
      }

      // Fetch product clusters based on the date range and safe cluster count
      final productClusters = await clusterRepository.fetchProductClusters(
        startDate: startDate,
        endDate: endDate,
        numberOfClusters: safeNumberOfClusters,
      );

      // Create cluster labels and colors
      final Map<int, String> clusterLabels = {};
      final Map<int, Color> clusterColors = {};
      final Map<int, List<ProductCluster>> groupedClusters = {};

      // Define cluster types based on the actual number of clusters
      List<String> clusterTypes = [];
      List<Color> colors = [];

      if (safeNumberOfClusters == 2) {
        clusterTypes = ['Best Selling', 'Low Selling'];
        colors = [Colors.green, Colors.red];
      } else {
        clusterTypes = ['Best Selling', 'Seasonal', 'Low Selling'];
        colors = [Colors.green, Colors.amber, Colors.red];

        // Add more colors if needed for higher cluster counts
        if (safeNumberOfClusters > 3) {
          for (int i = 3; i < safeNumberOfClusters; i++) {
            clusterTypes.add('Cluster ${i + 1}');
            colors.add(Colors.blue);
          }
        }
      }

      // Group products by cluster
      for (var cluster in productClusters) {
        if (!groupedClusters.containsKey(cluster.cluster)) {
          groupedClusters[cluster.cluster] = [];

          // Assign label and color based on cluster ID
          int index = cluster.cluster;
          if (index < clusterTypes.length) {
            clusterLabels[index] = clusterTypes[index];
            clusterColors[index] = colors[index];
          } else {
            clusterLabels[index] = 'Cluster ${index + 1}';
            clusterColors[index] = Colors.blue;
          }
        }
        groupedClusters[cluster.cluster]!.add(cluster);
      }

      emit(ClusteringLoaded(
        productClusters: productClusters,
        clusterLabels: clusterLabels,
        clusterColors: clusterColors,
        groupedClusters: groupedClusters,
        startDate: startDate,
        endDate: endDate,
        numberOfClusters: safeNumberOfClusters,
      ));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const ClusteringError(
            message: "Login expired, please restart the app and login again"));
      } else if (e.toString().contains("404") ||
          e.toString().contains("No sales data available")) {
        emit(ClusteringError(
            message:
                "No clustering data available for ${event.startDate?.year}. Please try a different year.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
      } else if (e.toString().contains("Not enough sales data")) {
        emit(ClusteringError(
            message:
                "Not enough product sales data to form clusters. Try another year with more sales data.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
      } else {
        emit(ClusteringError(
          message: "Failed to load clustering data. Please try again later.",
          startDate: event.startDate,
          endDate: event.endDate,
          numberOfClusters: event.numberOfClusters,
        ));
      }
    }
  }

  Future<void> _onLoadClusteringByYear(
      LoadClusteringByYearEvent event, Emitter<ClusteringState> emit) async {
    final startDate = DateTime(event.year, 1, 1);
    final endDate = DateTime(event.year, 12, 31);

    add(LoadClusteringEvent(
      startDate: startDate,
      endDate: endDate,
      numberOfClusters: event.numberOfClusters,
    ));
  }

  Future<void> _onChangeFilter(
      ChangeClusteringFilterEvent event, Emitter<ClusteringState> emit) async {
    add(LoadClusteringEvent(
      startDate: event.startDate,
      endDate: event.endDate,
      numberOfClusters: event.numberOfClusters,
    ));
  }
}
