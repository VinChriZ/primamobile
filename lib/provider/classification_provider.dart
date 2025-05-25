// lib/provider/classification_provider.dart
import 'package:primamobile/app/models/classification/product_classification.dart';
import 'package:primamobile/provider/dio/dio_client.dart';
import 'package:primamobile/provider/models/request_api/request_api.dart';

class ClassificationProvider {
  // Predict product classifications using pre-trained model
  Future<List<ProductClassification>> getProductClassifications({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'start': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
    };

    final RequestParam param = RequestParam(parameters: queryParameters);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.get(
        '/classify/predict',
        queryParameters: await request.toJson(),
      );
      print('Get Product Classifications Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data
            .map((item) => ProductClassification.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch product classifications with status code: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('503') ||
          e.toString().contains('Model not trained yet')) {
        throw Exception(
            'Classification model not trained yet. Try running a training first.');
      } else if (e.toString().contains('404') ||
          e.toString().contains('No data in date range')) {
        throw Exception('No sales data available for the selected date range.');
      }

      print('Error fetching product classifications: $e');
      rethrow;
    }
  }

  // Retrain classification model with new data
  Future<String> retrainClassificationModel({
    required DateTime startDate,
    required DateTime endDate,
    int k = 3,
  }) async {
    final Map<String, dynamic> queryParameters = {
      'start': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'end': endDate.toIso8601String().split('T')[0], // YYYY-MM-DD format
      'k': k,
    };

    final RequestParam param = RequestParam(parameters: queryParameters);
    final RequestObject request = RequestObjectFunction(requestParam: param);

    try {
      final response = await dioClient.post(
        '/classify/retrain',
        queryParameters: await request.toJson(),
      );
      print('Retrain Classification Model Response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data['detail'] ?? 'Model training started successfully';
      } else {
        throw Exception(
            'Failed to start model training with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retraining classification model: $e');
      rethrow;
    }
  }
  // Get years that have complete data (January to December)
  Future<List<int>> getYearsWithCompleteData() async {
    try {
      final response =
          await dioClient.get('/classify/years-with-complete-data');
      print('Get Years With Complete Data Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((year) => year as int).toList();
      } else {
        print('Non-200 status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching years with complete data: $e');
      return [];
    }
  }
  
  // Get the year when the model was last trained
  Future<int?> getModelTrainedYear() async {
    try {
      final response = await dioClient.get('/classify/model-trained-year');
      print('Get Model Trained Year Response: ${response.data}');

      if (response.statusCode == 200) {
        // The response is just an integer or null
        return response.data as int?;
      } else {
        print('Non-200 status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching model trained year: $e');
      return null;
    }
  }
}
