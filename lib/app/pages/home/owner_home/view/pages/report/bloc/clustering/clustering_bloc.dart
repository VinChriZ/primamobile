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
  }

  Future<void> _onLoadClustering(
      LoadClusteringEvent event, Emitter<ClusteringState> emit) async {
    emit(ClusteringLoading(
      startDate: event.startDate,
      endDate: event.endDate,
      numberOfClusters: event.numberOfClusters,
    ));
    try {
      // If dates are not provided, default to the entire year
      final DateTime endDate = event.endDate ?? DateTime.now();
      final DateTime startDate = event.startDate ??
          DateTime(endDate.year - 1, endDate.month, endDate.day);

      // Fetch product clusters based on the date range
      final productClusters = await clusterRepository.fetchProductClusters(
        startDate: startDate,
        endDate: endDate,
        numberOfClusters: event.numberOfClusters,
      );

      // Create cluster labels and colors
      final Map<int, String> clusterLabels = {};
      final Map<int, Color> clusterColors = {};
      final Map<int, List<ProductCluster>> groupedClusters = {};

      // Define cluster types (Best Selling, Seasonal, Low Selling)
      final List<String> clusterTypes = [
        'Best Selling',
        'Seasonal',
        'Low Selling'
      ];
      final List<Color> colors = [
        Colors.green, // Best Selling
        Colors.amber, // Seasonal
        Colors.red, // Low Selling
      ];

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
        numberOfClusters: event.numberOfClusters,
      ));
    } catch (e) {
      if (e.toString().contains("401")) {
        emit(const ClusteringError(
            message: "Login expired, please restart the app and login again"));
      } else if (e.toString().contains("404")) {
        emit(const ClusteringError(
            message:
                "No clustering data available for the selected date range."));
      } else {
        emit(ClusteringError(
          message: "Failed to load clustering data: ${e.toString()}",
          startDate: event.startDate,
          endDate: event.endDate,
          numberOfClusters: event.numberOfClusters,
        ));
      }
    }
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
