import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:primamobile/app/models/models.dart';
import 'package:primamobile/app/models/classification/product_classification.dart';
import 'package:primamobile/repository/classification_repository.dart';
import 'package:primamobile/repository/cluster_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

part 'clustering_event.dart';
part 'clustering_state.dart';

class ClusteringBloc extends Bloc<ClusteringEvent, ClusteringState> {
  final ClusterRepository clusterRepository;
  final ProductRepository productRepository;
  final ClassificationRepository classificationRepository;
  int?
      lastTrainedYear; // Store the year when the model was last trained - public access
  ClusteringBloc({
    required this.clusterRepository,
    required this.productRepository,
    required this.classificationRepository,
  }) : super(ClusteringInitial()) {
    on<LoadClusteringEvent>(_onLoadClustering);
    on<ChangeClusteringFilterEvent>(_onChangeFilter);
    on<LoadClusteringByYearEvent>(_onLoadClusteringByYear);
    on<RetrainModelEvent>(_onRetrainModel);

    // Initialize lastTrainedYear when creating the bloc
    _initTrainedYear();
  }

  // Fetch the trained year from the backend
  Future<void> _initTrainedYear() async {
    try {
      lastTrainedYear = await classificationRepository.fetchTrainedYear();
      print('Model was trained for year: $lastTrainedYear');
    } catch (e) {
      print('Error fetching trained year: $e');
      lastTrainedYear = null;
    }
  }

  Future<void> _onLoadClustering(
      LoadClusteringEvent event, Emitter<ClusteringState> emit) async {
    emit(ClusteringLoading(
      startDate: event.startDate,
      endDate: event.endDate,
      numberOfClusters: event.numberOfClusters,
    ));

    try {
      // Set default dates if not provided
      final DateTime now = DateTime.now();
      DateTime endDate = event.endDate ?? DateTime(now.year, 12, 31);
      DateTime startDate = event.startDate ?? DateTime(now.year, 1, 1);

      // If dates are not provided, try to get the latest year with complete data
      if (event.startDate == null || event.endDate == null) {
        try {
          final years =
              await classificationRepository.fetchYearsWithCompleteData();
          if (years.isNotEmpty) {
            // Use the most recent year with complete data
            final latestYear = years.last;
            startDate = DateTime(latestYear, 1, 1);
            endDate = DateTime(latestYear, 12, 31);
          }
        } catch (e) {
          // If there's an error fetching years, use the defaults already set
          print('Error fetching years with complete data: $e');
        }
      }

      // Always use 3 clusters as specified
      final int safeNumberOfClusters = 3;
      print('Using fixed number of clusters: $safeNumberOfClusters');

      try {
        // Directly use classification API which now returns all product metrics
        final List<ProductClassification> productClassifications =
            await classificationRepository.fetchProductClassifications(
          startDate: startDate,
          endDate: endDate,
        );

        // Maps for cluster labels and colors
        final Map<int, String> clusterLabels = {};
        final Map<int, Color> clusterColors = {};
        final Map<int, List<ProductClassification>> groupedClusters = {};

        // Process each classification result
        for (var classification in productClassifications) {
          // Set cluster label - keep the full label including "Seasonal" prefix
          clusterLabels[classification.cluster] = classification.category;

          // Set color based on base category (ignoring seasonal modifier)
          String baseCategory = classification.category;
          if (baseCategory.startsWith("Seasonal ")) {
            baseCategory = baseCategory.substring(9);
          }

          if (baseCategory == "Top Seller") {
            clusterColors[classification.cluster] = Colors.green[700]!;
          } else if (baseCategory == "Low Seller") {
            clusterColors[classification.cluster] = Colors.red[700]!;
          } else {
            clusterColors[classification.cluster] = Colors.blue[700]!;
          }

          // Add to grouped clusters
          if (!groupedClusters.containsKey(classification.cluster)) {
            groupedClusters[classification.cluster] = [];
          }
          groupedClusters[classification.cluster]!.add(classification);
        }

        if (productClassifications.isNotEmpty) {
          emit(ClusteringLoaded(
            productClassifications: productClassifications,
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
                "No clustering data available for ${event.startDate?.year ?? DateTime.now().year}. Please try training the model first or select a different year.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
      } else if (e.toString().contains("Not enough sales data")) {
        emit(ClusteringError(
            message:
                "Not enough product sales data to form clusters. Try training the model or select another year with more sales data.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
      } else if (e.toString().contains("Model not trained yet")) {
        emit(ClusteringError(
            message:
                "The classification model needs to be trained before it can be used. Please use the 'Train Model' button below to create a new model.",
            startDate: event.startDate,
            endDate: event.endDate,
            numberOfClusters: event.numberOfClusters));
      } else {
        emit(ClusteringError(
          message:
              "Failed to load clustering data. Please try training the model first or try again later.",
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
        )); // Update the last trained year to the year we trained on, not the current year
        lastTrainedYear = startDate.year;

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
