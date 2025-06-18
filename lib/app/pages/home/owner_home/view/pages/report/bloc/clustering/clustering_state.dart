part of 'clustering_bloc.dart';

abstract class ClusteringState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;
  final int volatilityPercentile;

  const ClusteringState({
    this.startDate,
    this.endDate,
    required this.numberOfClusters,
    this.volatilityPercentile = 75,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, numberOfClusters, volatilityPercentile];
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
  });
}

class ClusteringTrainingModel extends ClusteringState {
  const ClusteringTrainingModel({
    super.startDate,
    super.endDate,
    required super.numberOfClusters,
    super.volatilityPercentile,
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
  });

  @override
  List<Object?> get props => [message, startDate, endDate, numberOfClusters];
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
  });

  @override
  List<Object?> get props => [message, startDate, endDate, numberOfClusters];
}
