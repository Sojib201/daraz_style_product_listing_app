import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/product.dart';
import '../models/user.dart';

class ApiRepository {
  static const _base = 'https://fakestoreapi.com';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _base,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );

  Future<String> login({
    required String username,
    required String password,
  }) async {
    debugPrint("LOGIN API CALLED");
    debugPrint("URL: $_base/auth/login");
    debugPrint("BODY: {username: $username, password: $password}");

    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    debugPrint("STATUS CODE: ${res.statusCode}");
    debugPrint("RESPONSE: ${res.data}");

    return res.data!['token'] as String;
  }

  Future<UserModel> getUser(int id) async {
    debugPrint("GET USER API CALLED");
    debugPrint("URL: $_base/users/$id");

    final res = await _dio.get<Map<String, dynamic>>('/users/$id');

    debugPrint("STATUS CODE: ${res.statusCode}");
    debugPrint("RESPONSE: ${res.data}");

    return UserModel.fromJson(res.data!);
  }

  Future<List<Product>> getAllProducts() async {
    debugPrint("GET ALL PRODUCTS API CALLED");
    debugPrint("URL: $_base/products");

    final res = await _dio.get<List<dynamic>>('/products');

    debugPrint("STATUS CODE: ${res.statusCode}");
    debugPrint("RESPONSE: ${res.data}");

    return res.data!.cast<Map<String, dynamic>>().map(Product.fromJson).toList();
  }

  Future<List<Product>> getByCategory(String category) async {
    debugPrint("GET PRODUCTS BY CATEGORY API CALLED");
    debugPrint("URL: $_base/products/category/$category");

    final res = await _dio.get<List<dynamic>>('/products/category/$category');

    debugPrint("STATUS CODE: ${res.statusCode}");
    debugPrint("RESPONSE: ${res.data}");

    return res.data!.cast<Map<String, dynamic>>().map(Product.fromJson).toList();
  }
}


