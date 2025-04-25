part of 'clustering_bloc.dart';

abstract class ClusteringState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;

  const ClusteringState({
    this.startDate,
    this.endDate,
    this.numberOfClusters = 3,
  });

  @override
  List<Object?> get props => [startDate, endDate, numberOfClusters];
}

class ClusteringInitial extends ClusteringState {}

class ClusteringLoading extends ClusteringState {
  const ClusteringLoading({
    super.startDate,
    super.endDate,
    super.numberOfClusters,
  });
}

class ClusteringLoaded extends ClusteringState {
  final List<ProductCluster> productClusters;
  final Map<int, String> clusterLabels;
  final Map<int, Color> clusterColors;
  final Map<int, List<ProductCluster>> groupedClusters;

  const ClusteringLoaded({
    required this.productClusters,
    required this.clusterLabels,
    required this.clusterColors,
    required this.groupedClusters,
    super.startDate,
    super.endDate,
    super.numberOfClusters,
  });

  @override
  List<Object?> get props => [
        productClusters,
        clusterLabels,
        clusterColors,
        groupedClusters,
        startDate,
        endDate,
        numberOfClusters,
      ];
}

class ClusteringError extends ClusteringState {
  final String message;

  const ClusteringError({
    required this.message,
    super.startDate,
    super.endDate,
    super.numberOfClusters,
  });

  @override
  List<Object?> get props => [message, startDate, endDate, numberOfClusters];
}
