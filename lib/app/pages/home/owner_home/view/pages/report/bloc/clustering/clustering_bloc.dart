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

      // First group products by cluster
      for (var product in productClusters) {
        if (!groupedClusters.containsKey(product.cluster)) {
          groupedClusters[product.cluster] = [];
        }
        groupedClusters[product.cluster]!.add(product);
      }

      // Calculate metrics for all clusters for comparison
      List<Map<String, dynamic>> clusterMetrics = [];

      groupedClusters.forEach((clusterId, products) {
        double totalSales = 0;
        double dailySales = 0;
        double daysSold = 0;

        for (var product in products) {
          totalSales += product.totalSales;
          dailySales += product.avgDailySales;
          daysSold += product.daysSold;
        }

        clusterMetrics.add({
          'id': clusterId,
          'avgTotalSales': totalSales / products.length,
          'avgDailySales': dailySales / products.length,
          'avgDaysSold': daysSold / products.length,
          'count': products.length,
        });
      });

      // Sort clusters by total sales (highest first)
      clusterMetrics
          .sort((a, b) => b['avgTotalSales'].compareTo(a['avgTotalSales']));

      // Always assign exactly 3 categories based on relative performance
      for (int i = 0; i < clusterMetrics.length; i++) {
        int clusterId = clusterMetrics[i]['id'];

        if (i == 0) {
          // Best performing cluster
          clusterLabels[clusterId] = 'Best Selling';
          clusterColors[clusterId] = Colors.green[700]!;
        } else if (i == clusterMetrics.length - 1) {
          // Worst performing cluster
          clusterLabels[clusterId] = 'Low Selling';
          clusterColors[clusterId] = Colors.red[700]!;
        } else {
          // Middle clusters
          clusterLabels[clusterId] = 'Seasonal';
          clusterColors[clusterId] = Colors.amber[700]!;
        }
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
