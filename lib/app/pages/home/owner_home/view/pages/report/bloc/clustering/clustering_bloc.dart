import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/repository/classification_repository.dart';
import 'package:primamobile/repository/cluster_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'clustering_event.dart';
part 'clustering_state.dart';

class ClusteringBloc extends Bloc<ClusteringEvent, ClusteringState> {
  final ClusterRepository clusterRepository;
  final ProductRepository productRepository;
  final ClassificationRepository classificationRepository;

  ClusteringBloc({
    required this.clusterRepository,
    required this.productRepository,
    required this.classificationRepository,
  }) : super(ClusteringInitial()) {
    on<LoadClusteringEvent>(_onLoadClustering);
    on<ChangeClusteringFilterEvent>(_onChangeFilter);
    on<LoadClusteringByYearEvent>(_onLoadClusteringByYear);
    on<RetrainModelEvent>(_onRetrainModel);
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

      // Use the number of clusters provided, no need to get recommendation from the server
      int safeNumberOfClusters = event.numberOfClusters;
      // If number of clusters is too large, use a reasonable default
      if (safeNumberOfClusters > 5) {
        safeNumberOfClusters = 3;
        print('Using default of $safeNumberOfClusters clusters');
      }

      try {
        // Directly use classification API which now returns all product metrics
        final List<ProductClassification> classifications =
            await classificationRepository.fetchProductClassifications(
          startDate: startDate,
          endDate: endDate,
        );

        // Create cluster labels and colors map based on categories
        final Map<String, Color> categoryColors = {
          "Top Seller": Colors.green[700]!,
          "Seasonal": Colors.amber[700]!,
          "Low Seller": Colors.red[700]!,
        };

        // Maps for cluster labels and colors
        final Map<int, String> clusterLabels = {};
        final Map<int, Color> clusterColors = {};
        final Map<int, List<ProductCluster>> groupedClusters = {};
        final List<ProductCluster> productClusters = [];

        // Process each classification result
        for (var classification in classifications) {
          // Set cluster label and color
          clusterLabels[classification.cluster] = classification.category;
          clusterColors[classification.cluster] =
              categoryColors[classification.category] ?? Colors.blue;

          // Create a ProductCluster directly from classification data
          final ProductCluster classifiedProduct = ProductCluster(
            upc: classification.upc,
            totalSales: classification.totalSales,
            daysSold: classification.daysSold,
            avgDailySales: classification.avgDailySales,
            salesFrequency: classification.salesFrequency,
            maxDailySales: classification.maxDailySales,
            minDailySales: classification.minDailySales,
            stdDailySales: classification.stdDailySales,
            daysSinceLastSale: classification.daysSinceLastSale,
            txCount: classification.txCount,
            cluster: classification.cluster,
          );

          // Add to list of all product clusters
          productClusters.add(classifiedProduct);

          // Add to grouped clusters
          if (!groupedClusters.containsKey(classification.cluster)) {
            groupedClusters[classification.cluster] = [];
          }
          groupedClusters[classification.cluster]!.add(classifiedProduct);
        }

        if (productClusters.isNotEmpty) {
          emit(ClusteringLoaded(
            productClusters: productClusters,
            clusterLabels: clusterLabels,
            clusterColors: clusterColors,
            groupedClusters: groupedClusters,
            startDate: startDate,
            endDate: endDate,
            numberOfClusters: safeNumberOfClusters,
            usesClassificationModel: true,
          ));
          return;
        }

        throw Exception("No classification data received");
      } catch (e) {
        print('Error during classification: $e');

        if (e.toString().contains("Model not trained yet")) {
          emit(ClusteringError(
              message:
                  "The classification model needs to be trained before it can be used. Use the 'Train Model' button to create a new model.",
              startDate: startDate,
              endDate: endDate,
              numberOfClusters: safeNumberOfClusters));
          return;
        }

        // For any other classification errors, show a general error
        emit(ClusteringError(
          message:
              "Failed to load product classification data: ${e.toString()}",
          startDate: startDate,
          endDate: endDate,
          numberOfClusters: safeNumberOfClusters,
        ));
      }
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
      } else if (e.toString().contains("Model not trained yet")) {
        emit(ClusteringError(
            message:
                "The classification model needs to be trained before it can be used. Use the 'Train Model' button to create a new model.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
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

  Future<void> _onRetrainModel(
      RetrainModelEvent event, Emitter<ClusteringState> emit) async {
    final currentState = state;

    if (currentState is ClusteringLoaded || currentState is ClusteringError) {
      final startDate = currentState.startDate ??
          DateTime.now().subtract(const Duration(days: 365));
      final endDate = currentState.endDate ?? DateTime.now();
      final numberOfClusters = currentState.numberOfClusters;

      emit(ClusteringTrainingModel(
        startDate: startDate,
        endDate: endDate,
        numberOfClusters: numberOfClusters,
      ));

      try {
        final result = await classificationRepository.retrainModel(
          startDate: startDate,
          endDate: endDate,
          k: numberOfClusters,
        );

        emit(ClusteringModelTrained(
          message: result,
          startDate: startDate,
          endDate: endDate,
          numberOfClusters: numberOfClusters,
        ));

        // Reload data after 3 seconds to allow the model to finish training
        await Future.delayed(const Duration(seconds: 3));

        add(LoadClusteringEvent(
          startDate: startDate,
          endDate: endDate,
          numberOfClusters: numberOfClusters,
        ));
      } catch (e) {
        emit(ClusteringError(
          message: "Failed to train model: ${e.toString()}",
          startDate: startDate,
          endDate: endDate,
          numberOfClusters: numberOfClusters,
        ));
      }
    }
  }
}
