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

  const LoadClusteringEvent({
    this.startDate,
    this.endDate,
    this.numberOfClusters = 3,
  });

  @override
  List<Object?> get props => [startDate, endDate, numberOfClusters];
}

class LoadClusteringByYearEvent extends ClusteringEvent {
  final int year;
  final int numberOfClusters;

  const LoadClusteringByYearEvent({
    required this.year,
    this.numberOfClusters = 3,
  });

  @override
  List<Object> get props => [year, numberOfClusters];
}

class ChangeClusteringFilterEvent extends ClusteringEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int numberOfClusters;

  const ChangeClusteringFilterEvent({
    this.startDate,
    this.endDate,
    this.numberOfClusters = 3,
  });

  @override
  List<Object?> get props => [startDate, endDate, numberOfClusters];
}

class RetrainModelEvent extends ClusteringEvent {
  const RetrainModelEvent();
}
