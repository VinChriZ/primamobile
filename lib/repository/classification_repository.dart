// lib/repository/classification_repository.dart
import 'package:primamobile/app/models/classification/product_classification.dart';
import 'package:primamobile/provider/classification_provider.dart';

class ClassificationRepository {
  final ClassificationProvider _provider = ClassificationProvider();

  // Fetch product classifications with the Random Forest model
  Future<List<ProductClassification>> fetchProductClassifications({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _provider.getProductClassifications(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      // Handle specific error cases with user-friendly messages
      if (e.toString().contains('Model not trained yet')) {
        throw Exception(
            'The classification model needs to be trained before predictions can be made. Please use the "Train Model" button.');
      } else if (e.toString().contains('No sales data available')) {
        throw Exception(
            'No sales data available for the selected period. Please try a different date range.');
      }
      rethrow;
    }
  }

  // Group classifications by category for easier UI rendering
  Future<Map<String, List<ProductClassification>>> getGroupedClassifications({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final classifications = await fetchProductClassifications(
      startDate: startDate,
      endDate: endDate,
    );

    // Group by category
    final Map<String, List<ProductClassification>> groupedResults = {};

    for (var classification in classifications) {
      if (!groupedResults.containsKey(classification.category)) {
        groupedResults[classification.category] = [];
      }
      groupedResults[classification.category]!.add(classification);
    }

    return groupedResults;
  }

  // Retrain the classification model
  Future<String> retrainModel({
    required DateTime startDate,
    required DateTime endDate,
    int k = 3,
  }) async {
    try {
      // Ensure k is within valid range (2-10 as per your backend)
      k = k.clamp(2, 10);

      return await _provider.retrainClassificationModel(
        startDate: startDate,
        endDate: endDate,
        k: k,
      );
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('No data in date range')) {
        throw Exception(
            'No sales data available for training in the selected period. Please choose a different date range.');
      }
      rethrow;
    }
  }

  // Fetch years that have complete data (January to December)
  Future<List<int>> fetchYearsWithCompleteData() async {
    try {
      return await _provider.getYearsWithCompleteData();
    } catch (e) {
      print('Error fetching years with complete data: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  // Get the year when the model was last trained
  Future<int?> fetchTrainedYear() async {
    try {
      return await _provider.getModelTrainedYear();
    } catch (e) {
      print('Error fetching model trained year: $e');
      return null;
    }
  }
}
