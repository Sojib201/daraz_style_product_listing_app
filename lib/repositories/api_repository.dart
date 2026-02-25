// lib/repositories/api_repository.dart
//
// Single source of truth for all network calls.
// Using Dio for HTTP + interceptors (easy to extend with auth headers).

import 'package:dio/dio.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiRepository {
  static const _baseUrl = 'https://fakestoreapi.com';

  final Dio _dio;

  ApiRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// Returns a JWT token string on success.
  Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );
    return response.data!['token'] as String;
  }

  /// Fetches a single user by id (used after login to populate profile).
  Future<UserModel> getUser(int userId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/users/$userId');
    return UserModel.fromJson(response.data!);
  }

  // ── Products ────────────────────────────────────────────────────────────────

  Future<List<Product>> getAllProducts() async {
    final response = await _dio.get<List<dynamic>>('/products');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final response =
        await _dio.get<List<dynamic>>('/products/category/$category');
    return response.data!
        .cast<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get<List<dynamic>>('/products/categories');
    return response.data!.cast<String>();
  }
}
