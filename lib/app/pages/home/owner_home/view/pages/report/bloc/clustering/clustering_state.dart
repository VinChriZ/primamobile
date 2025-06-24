part of 'clustering_bloc.dart';

abstract class ClusteringState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;
  final int volatilityPercentile;
  final int minPeaks;

  const ClusteringState({
    this.startDate,
    this.endDate,
    required this.numberOfClusters,
    this.volatilityPercentile = 75,
    this.minPeaks = 3,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, numberOfClusters, volatilityPercentile, minPeaks];
}

class ClusteringInitial extends ClusteringState {
  const ClusteringInitial() : super(numberOfClusters: 3);
}

class ClusteringLoading extends ClusteringState {
  const ClusteringLoading({
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
    super.minPeaks,
  });
}

class ClusteringTrainingModel extends ClusteringState {
  const ClusteringTrainingModel({
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
    super.minPeaks,
  });
}

class ClusteringModelTrained extends ClusteringState {
  final String message;
  const ClusteringModelTrained({
    required this.message,
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
    super.minPeaks,
  });

  @override
  List<Object?> get props =>
      [message, startDate, endDate, numberOfClusters, minPeaks];
}

class ClusteringLoaded extends ClusteringState {
  final List<ProductClassification> productClassifications;
  final Map<int, String> clusterLabels;
  final Map<int, Color> clusterColors;
  final Map<int, List<ProductClassification>> groupedClusters;
  final bool usesClassificationModel;

  const ClusteringLoaded({
    required this.productClassifications,
    required this.clusterLabels,
    required this.clusterColors,
    required this.groupedClusters,
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
    super.minPeaks,
    this.usesClassificationModel = false,
  });

  @override
  List<Object?> get props => [
        productClassifications,
        clusterLabels,
        clusterColors,
        groupedClusters,
        startDate,
        endDate,
        numberOfClusters,
        usesClassificationModel,
        minPeaks,
      ];
}

class ClusteringError extends ClusteringState {
  final String message;
  const ClusteringError({
    required this.message,
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
    super.minPeaks,
  });

  @override
  List<Object?> get props =>
      [message, startDate, endDate, numberOfClusters, minPeaks];
}
