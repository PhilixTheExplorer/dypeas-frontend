import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Representation of a single classification returned by Roboflow.
class RoboflowClassificationResult {
  RoboflowClassificationResult({
    required this.label,
    required this.confidence,
    this.wasteType,
  });

  final String label;
  final double? confidence;
  final String? wasteType;
}

/// Base exception for Roboflow related failures.
class RoboflowException implements Exception {
  RoboflowException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'RoboflowException(statusCode: $statusCode, message: $message)';
}

/// Thrown when the service is not configured with the required values.
class MissingRoboflowConfigException extends RoboflowException {
  MissingRoboflowConfigException(String message) : super(message);
}

/// Handles communication with the Roboflow hosted model endpoint.
class RoboflowService {
  RoboflowService({
    http.Client? httpClient,
    String? apiKey,
    String? modelId,
    String? modelVersion,
    String? apiUrl,
    Map<String, String>? labelToWasteType,
  }) : _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _apiKey = apiKey ?? const String.fromEnvironment('ROBOFLOW_API_KEY'),
       _modelId = modelId ?? const String.fromEnvironment('ROBOFLOW_MODEL_ID'),
       _modelVersion =
           modelVersion ??
           const String.fromEnvironment(
             'ROBOFLOW_MODEL_VERSION',
             defaultValue: '1',
           ),
       _apiUrl =
           apiUrl ??
           const String.fromEnvironment(
             'ROBOFLOW_API_URL',
             defaultValue: 'https://classify.roboflow.com',
           ),
       _labelToWasteType = labelToWasteType ?? _defaultLabelMapping;

  final http.Client _client;
  final bool _ownsClient;
  final String _apiKey;
  final String _modelId;
  final String _modelVersion;
  final String _apiUrl;
  final Map<String, String> _labelToWasteType;

  static const Map<String, String> _defaultLabelMapping = {
    'compostable': 'compostable',
    'organic': 'compostable',
    'food': 'compostable',
    'vegetable': 'compostable',
    'fruit': 'compostable',
    'recyclable': 'recyclable',
    'plastic': 'recyclable',
    'glass': 'recyclable',
    'paper': 'recyclable',
    'cardboard': 'recyclable',
    'metal': 'recyclable',
    'general': 'general',
    'trash': 'general',
    'landfill': 'general',
    'hazardous': 'hazardous',
    'battery': 'hazardous',
    'chemical': 'hazardous',
    'medical': 'hazardous',
  };

  bool get isConfigured => _apiKey.isNotEmpty && _modelId.isNotEmpty;

  Future<RoboflowClassificationResult?> classifyImage(String imagePath) async {
    if (!isConfigured) {
      throw MissingRoboflowConfigException(
        'Roboflow model is not configured. Provide ROBOFLOW_API_KEY and ROBOFLOW_MODEL_ID.',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw RoboflowException('Image file not found at $imagePath');
    }

    final uri = _buildClassificationUri();

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await _client
        .send(request)
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () =>
              throw RoboflowException('Roboflow request timed out'),
        );

    final responseBody = await streamedResponse.stream.bytesToString();
    if (streamedResponse.statusCode != 200) {
      throw RoboflowException(
        'Roboflow responded with an error: $responseBody',
        streamedResponse.statusCode,
      );
    }

    final decoded = json.decode(responseBody) as Map<String, dynamic>;
    final predictions = decoded['predictions'];

    if (predictions is List && predictions.isNotEmpty) {
      final topPrediction = predictions.first as Map<String, dynamic>;
      final label = (topPrediction['class'] ?? topPrediction['label'] ?? '')
          .toString();
      final confidence = (topPrediction['confidence'] as num?)?.toDouble();
      if (label.isEmpty) {
        return null;
      }
      final normalizedLabel = label.toLowerCase();
      final wasteType = _labelToWasteType[normalizedLabel];
      return RoboflowClassificationResult(
        label: label,
        confidence: confidence,
        wasteType: wasteType,
      );
    }

    return null;
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Uri _buildClassificationUri() {
    final sanitizedBase = _apiUrl.trim();
    if (sanitizedBase.isEmpty) {
      throw MissingRoboflowConfigException(
        'ROBOFLOW_API_URL is empty. Provide a valid Roboflow endpoint.',
      );
    }

    final baseUri = Uri.parse(sanitizedBase);
    final scheme = baseUri.scheme.isEmpty ? 'https' : baseUri.scheme;
    final host = baseUri.host.isEmpty ? sanitizedBase : baseUri.host;
    final port = baseUri.hasPort ? baseUri.port : null;
    final basePath = baseUri.path;
    final normalizedBasePath = basePath.endsWith('/') || basePath.isEmpty
        ? basePath
        : '$basePath/';

    final modelPath = _resolveModelPath();
    final fullPath = '$normalizedBasePath$modelPath'
        .replaceAll(RegExp('/{2,}'), '/')
        .replaceAll(RegExp('^/'), '');

    return Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/$fullPath',
      queryParameters: {'api_key': _apiKey, 'format': 'json'},
    );
  }

  String _resolveModelPath() {
    final trimmed = _modelId.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    if (trimmed.isEmpty) {
      throw MissingRoboflowConfigException(
        'ROBOFLOW_MODEL_ID is empty. Provide your Roboflow model ID.',
      );
    }

    final segments = trimmed.split('/');
    if (segments.length >= 2 && int.tryParse(segments.last) != null) {
      return trimmed;
    }

    final version = _modelVersion.trim();
    if (version.isEmpty) {
      throw MissingRoboflowConfigException(
        'ROBOFLOW_MODEL_VERSION is empty. Set it or include the version in ROBOFLOW_MODEL_ID.',
      );
    }

    return '$trimmed/$version';
  }
}
