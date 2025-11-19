import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Represents a single classifier candidate returned by the backend.
class WasteClassificationCandidate {
  const WasteClassificationCandidate({required this.label, this.confidence});

  final String label;
  final double? confidence;
}

/// Top level result for a classification request.
class WasteClassificationResult {
  WasteClassificationResult({
    required this.label,
    this.confidence,
    this.wasteType,
    this.candidates = const <WasteClassificationCandidate>[],
  });

  final String label;
  final double? confidence;
  final String? wasteType;
  final List<WasteClassificationCandidate> candidates;
}

/// Base exception for backend interactions.
class BackendException implements Exception {
  BackendException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'BackendException(statusCode: $statusCode, message: $message)';
}

/// Thrown when the backend client is missing required configuration.
class BackendConfigException extends BackendException {
  BackendConfigException(super.message);
}

/// Handles communication with the Dypeas backend FastAPI service.
class DypeasBackendService {
  DypeasBackendService({
    http.Client? httpClient,
    String? baseUrl,
    String? predictEndpoint,
    Map<String, String>? labelToWasteType,
    Duration? timeout,
  }) : _client = httpClient ?? http.Client(),
       _ownsClient = httpClient == null,
       _baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'DYPEAS_BACKEND_URL',
             defaultValue: 'https://7a6150e559dc.ngrok-free.app',
           ),
       _predictEndpoint = predictEndpoint ?? '/predict',
       _labelToWasteType = labelToWasteType ?? _defaultLabelMapping,
       _timeout = timeout ?? const Duration(seconds: 20);

  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;
  final String _predictEndpoint;
  final Map<String, String> _labelToWasteType;
  final Duration _timeout;

  static const Map<String, String> _defaultLabelMapping = {
    'battery': 'hazardous',
    'bread': 'compostable',
    'bulb': 'hazardous',
    'cardboard': 'recyclable',
    'carton': 'recyclable',
    'clothes': 'general',
    'e_waste': 'hazardous',
    'fruit': 'compostable',
    'glass': 'recyclable',
    'glass_bottle': 'recyclable',
    'glass_jars': 'recyclable',
    'metal': 'recyclable',
    'nailpolishbottle': 'hazardous',
    'paper': 'recyclable',
    'paper_container': 'recyclable',
    'paper_cup': 'general',
    'plastic_bag': 'general',
    'plastic_bottle': 'recyclable',
    'plastic_container': 'recyclable',
    'plastic_cup': 'recyclable',
    'plastic_cutlery': 'general',
    'plastic_straw': 'general',
    'styrofoam': 'general',
    'tabletcapsule': 'hazardous',
    'tissue': 'general',
    'trash': 'general',
  };

  bool get isConfigured => _baseUrl.trim().isNotEmpty;

  Future<WasteClassificationResult?> classifyImage(String imagePath) async {
    if (!isConfigured) {
      throw BackendConfigException(
        'Dypeas backend URL is not configured. Provide DYPEAS_BACKEND_URL.',
      );
    }

    final file = File(imagePath);
    if (!await file.exists()) {
      throw BackendException('Image file not found at $imagePath');
    }

    final uri = _buildPredictUri();

    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          contentType: _guessMediaType(file.path),
        ),
      );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request).timeout(_timeout);
    } on SocketException catch (_) {
      throw BackendException(
        'Unable to reach the backend. Check your network connection.',
      );
    } on TimeoutException catch (_) {
      throw BackendException('Classification request timed out.');
    }

    final response = await http.Response.fromStream(streamedResponse);
    final body = response.body;

    if (response.statusCode != 200) {
      throw BackendException(_extractErrorMessage(body), response.statusCode);
    }

    Map<String, dynamic> decoded;
    try {
      decoded = json.decode(body) as Map<String, dynamic>;
    } on FormatException catch (_) {
      throw BackendException('Backend returned invalid JSON.');
    }

    final prediction = decoded['prediction'];
    if (prediction is! Map<String, dynamic>) {
      return null;
    }

    final top1 = prediction['top1'];
    if (top1 is! Map<String, dynamic>) {
      return null;
    }

    final label = (top1['label'] ?? '').toString().trim();
    final confidence = (top1['confidence'] as num?)?.toDouble();

    if (label.isEmpty) {
      return null;
    }

    final candidates = <WasteClassificationCandidate>[];
    final top5 = prediction['top5'];
    if (top5 is List) {
      for (final dynamic candidate in top5) {
        if (candidate is! Map<String, dynamic>) {
          continue;
        }
        final candidateLabel = (candidate['label'] ?? '').toString().trim();
        if (candidateLabel.isEmpty) {
          continue;
        }
        final candidateConfidence = (candidate['confidence'] as num?)
            ?.toDouble();
        candidates.add(
          WasteClassificationCandidate(
            label: candidateLabel,
            confidence: candidateConfidence,
          ),
        );
      }
    }

    final normalizedLabel = label.toLowerCase();
    final wasteType = _labelToWasteType[normalizedLabel];

    final existingIndex = candidates.indexWhere(
      (candidate) => candidate.label.toLowerCase() == normalizedLabel,
    );

    if (existingIndex == -1) {
      candidates.insert(
        0,
        WasteClassificationCandidate(label: label, confidence: confidence),
      );
    } else {
      final current = candidates.removeAt(existingIndex);
      candidates.insert(
        0,
        WasteClassificationCandidate(
          label: current.label,
          confidence: current.confidence ?? confidence,
        ),
      );
    }

    return WasteClassificationResult(
      label: label,
      confidence: confidence,
      wasteType: wasteType,
      candidates: candidates,
    );
  }

  void dispose() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Uri _buildPredictUri() {
    final trimmedBase = _baseUrl.trim();
    if (trimmedBase.isEmpty) {
      throw BackendConfigException(
        'Dypeas backend URL is empty. Provide DYPEAS_BACKEND_URL.',
      );
    }

    final sanitizedBase = _ensureScheme(trimmedBase);
    final baseUri = Uri.parse(sanitizedBase);
    final endpoint = _predictEndpoint.trim().isEmpty
        ? '/predict'
        : _predictEndpoint.trim();
    final endpointUri = Uri.parse(
      endpoint.startsWith('/') ? endpoint : '/$endpoint',
    );

    return baseUri.resolveUri(endpointUri);
  }

  static String _ensureScheme(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return 'http://$value';
  }

  static MediaType? _guessMediaType(String path) {
    final lowerPath = path.toLowerCase();
    for (final entry in _knownImageTypes.entries) {
      if (lowerPath.endsWith(entry.key)) {
        return MediaType.parse(entry.value);
      }
    }
    return null;
  }

  static const Map<String, String> _knownImageTypes = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.heic': 'image/heic',
    '.heif': 'image/heif',
    '.webp': 'image/webp',
  };

  static String _extractErrorMessage(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] is String) {
            return first['msg'] as String;
          }
        }
        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Ignore JSON parse errors and fall back to raw body.
    }
    return body.isEmpty ? 'Backend responded with an error.' : body.trim();
  }
}
