import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/bloc/clustering/clustering_bloc.dart';
import 'package:primamobile/app/pages/home/owner_home/view/pages/report/view/clustering_screen.dart';
import 'package:primamobile/repository/classification_repository.dart';
import 'package:primamobile/repository/cluster_repository.dart';
import 'package:primamobile/repository/product_repository.dart';

class ClusteringPage extends StatelessWidget {
  const ClusteringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClusteringBloc>(
      create: (context) => ClusteringBloc(
        clusterRepository: RepositoryProvider.of<ClusterRepository>(context),
        productRepository: RepositoryProvider.of<ProductRepository>(context),
        classificationRepository:
            RepositoryProvider.of<ClassificationRepository>(context),
      )..add(const LoadClusteringEvent(
          numberOfClusters: 3,
          minPeaks: 3,
        )),
      child: const ClusteringScreen(),
    );
  }
}
