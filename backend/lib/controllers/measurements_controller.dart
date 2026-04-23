import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:fitman_common/fitman_common.dart';

import '../config/database.dart';
import '../services/recommendations/recommendation_service.dart';

class MeasurementsController {
  static const _headers = {'Content-Type': 'application/json'};

  static Future<Response> getVisualizationData(Request request) async {
    try {
      final clientRepository = Database().clients;
      final recommendationService = RecommendationService();

      final requestBody = await request.readAsString();
      final body = jsonDecode(requestBody) as Map<String, dynamic>;
      final measurementIds = (body['measurement_ids'] as List).cast<String>();

      if (measurementIds.isEmpty) {
        return Response.ok(jsonEncode({'data': []}), headers: _headers);
      }

      final measurements = await clientRepository.getMeasurementsByIds(measurementIds);
      if (measurements.isEmpty) {
        return Response.ok(jsonEncode({'data': []}), headers: _headers);
      }

      final visualizationData = <VisualizationDataPoint>[];

      for (final measurement in measurements) {
        if (measurement.id == null) continue;

        final whtrProfile = await recommendationService.getWhtrForMeasurement(measurement.id!);
        final metabolicProfile = await recommendationService.calculateMetabolicRate(
          measurement.userId,
          measurement.id!,
        );

        visualizationData.add(
          VisualizationDataPoint(
            dateTime: measurement.dateTime,
            weight: measurement.weight,
            shouldersCirc: measurement.shouldersCirc,
            breastCirc: measurement.breastCirc,
            waistCirc: measurement.waistCirc,
            hipsCirc: measurement.hipsCirc,
            fatPercentage: measurement.fatPercentage,
            muscleMass: measurement.muscleMass,
            whtrRatio: whtrProfile?.ratio,
            bmr: metabolicProfile?.bmr,
            tdee: metabolicProfile?.tdee,
          ),
        );
      }

      final jsonResponse =
          jsonEncode({'data': visualizationData.map((d) => d.toJson()).toList()});
      return Response.ok(jsonResponse, headers: _headers);
      
    } catch (e, s) {
      print('Error in getVisualizationData: $e');
      print(s);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Internal Server Error: $e'}),
        headers: _headers,
      );
    }
  }
}

