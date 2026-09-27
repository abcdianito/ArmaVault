import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/firearm.dart';

class ApiService {
  // ============================================================
  // API URL
  // ============================================================

  static const String baseUrl =
      'http://localhost/gun-model-crud-app/backend/api';

  static bool isDataUri(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.startsWith('data:image/');
  }

  static Uint8List? decodeImageBytes(String? value) {
    final normalized = value?.trim() ?? '';
    if (!isDataUri(normalized)) {
      return null;
    }

    final commaIndex = normalized.indexOf(',');
    if (commaIndex == -1) {
      return null;
    }

    final payload = normalized.substring(commaIndex + 1).trim();
    try {
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  static String proxiedImageUrl(String imageUrl) {
    final url = imageUrl.trim();
    return url;
  }

  static Widget buildImageWidget(
    String? imageValue, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
  }) {
    final safeValue = imageValue?.trim() ?? '';

    if (safeValue.isEmpty) {
      return placeholder ??
          const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF64748B),
            size: 40,
          );
    }

    if (isDataUri(safeValue)) {
      final imageBytes = decodeImageBytes(safeValue);
      if (imageBytes == null) {
        return placeholder ??
            const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF64748B),
              size: 40,
            );
      }

      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ??
            const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF64748B),
              size: 40,
            ),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return Image.network(
      proxiedImageUrl(safeValue),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) =>
          placeholder ??
          const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF64748B),
            size: 40,
          ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  // ============================================================
  // GET ALL FIREARMS
  // ============================================================

  Future<List<Firearm>> getFirearms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/read.php'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load firearms. '
        'HTTP ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Failed to load firearms.',
      );
    }

    final List data = body['data'] ?? [];

    return data
        .map(
          (item) => Firearm.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE FIREARM
  // ============================================================

  Future<Firearm> getFirearm(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/read_single.php?id=$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load firearm. '
        'HTTP ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['success'] != true) {
      throw Exception(
        body['message'] ?? 'Firearm not found.',
      );
    }

    return Firearm.fromJson(
      Map<String, dynamic>.from(body['data']),
    );
  }

  // ============================================================
  // CREATE
  // ============================================================

  Future<void> createFirearm(Firearm firearm) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        firearm.toJson(),
      ),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create firearm. '
        'HTTP ${response.statusCode}\n'
        '${response.body}',
      );
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateFirearm(Firearm firearm) async {
    if (firearm.id == null) {
      throw Exception('Cannot update firearm without an ID.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        firearm.toJson(),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update firearm. '
        'HTTP ${response.statusCode}\n'
        '${response.body}',
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteFirearm(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete.php?id=$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete firearm. '
        'HTTP ${response.statusCode}\n'
        '${response.body}',
      );
    }
  }
}