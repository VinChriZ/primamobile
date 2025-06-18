part of 'clustering_bloc.dart';

abstract class ClusteringEvent extends Equatable {
  const ClusteringEvent();

  @override
  List<Object?> get props => [];
}

class LoadClusteringEvent extends ClusteringEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;
  final int? volatilityPercentile;

  const LoadClusteringEvent({
    this.startDate,
    this.endDate,
    required this.numberOfClusters,
    this.volatilityPercentile,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, numberOfClusters, volatilityPercentile];
}

class LoadClusteringByYearEvent extends ClusteringEvent {
  final int year;
  final int numberOfClusters;
  final int? volatilityPercentile;

  const LoadClusteringByYearEvent({
    required this.year,
    this.numberOfClusters = 3,
    this.volatilityPercentile,
  });

  @override
  List<Object?> get props => [year, numberOfClusters, volatilityPercentile];
}

class ChangeClusteringFilterEvent extends ClusteringEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;
  final int? volatilityPercentile;

  const ChangeClusteringFilterEvent({
    this.startDate,
    this.endDate,
    required this.numberOfClusters,
    this.volatilityPercentile,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, numberOfClusters, volatilityPercentile];
}

class RetrainModelEvent extends ClusteringEvent {
  const RetrainModelEvent();
}
