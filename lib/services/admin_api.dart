import 'dart:io';
import 'package:dio/dio.dart';
import 'config.dart';

class AdminApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: API_URL, // e.g. http://localhost:3002/api/admin
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // =====================================================
  //                     DOCTORS
  // =====================================================

  Future<List> getDoctors() async {
    final res = await _dio.get('/doctors');
    return res.data['data'] ?? [];
  }

  Future<int> createDoctor(Map data) async {
    final res = await _dio.post('/doctors', data: data);
    if (res.data['id'] != null) return res.data['id'];
    throw Exception('Create doctor failed');
  }

  Future<void> updateDoctor(int id, Map data) async {
    await _dio.put('/doctors/$id', data: data);
  }

  Future<void> deleteDoctor(int id) async {
    await _dio.delete('/doctors/$id');
  }

  Future<void> uploadDoctorImage(int id, File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    await _dio.post(
      '/doctors/$id/upload',
      data: formData,
      options: Options(headers: {
        'Content-Type': 'multipart/form-data',
      }),
    );
  }

  // =====================================================
  //                     SHOPS
  // =====================================================

  Future<List> getShops() async {
    final res = await _dio.get('/shops');
    return res.data['data'] ?? [];
  }

  Future<Response> createShop(Map data) async {
    return await _dio.post('/shops', data: data);
  }

  Future<void> updateShop(int id, Map data) async {
    await _dio.put('/shops/$id', data: data);
  }

  Future<void> deleteShop(int id) async {
    await _dio.delete('/shops/$id');
  }

  /// ------------------- FIXED ROUTE HERE -------------------
  /// Backend route:  POST /api/admin/shops/:id/upload
  Future<void> uploadShopImage(int id, File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    await _dio.post(
      '/shops/$id/upload',
      data: formData,
      options: Options(headers: {
        'Content-Type': 'multipart/form-data',
      }),
    );
  }

  // =====================================================
  //                   DIVISIONS
  // =====================================================

  Future<List> fetchDivisions() async {
    final dioDiv = Dio(
      BaseOptions(
        baseUrl: API_URL.replaceFirst('/admin', ''), // /api
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    final res = await dioDiv.get('/divisions');
    return res.data['data'] ?? [];
  }

  // =====================================================
  //                    USERS
  // =====================================================

  Future<List> getUsers() async {
    final res = await _dio.get('/users');
    return res.data['data'] ?? [];
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('/users/$id');
  }

  // =====================================================
  //                APPOINTMENTS
  // =====================================================

  Future<List> getAppointments() async {
    final res = await _dio.get('/appointments');
    return res.data['data'] ?? [];
  }

  Future<void> deleteAppointment(int id) async {
    await _dio.delete('/appointments/$id');
  }

  // =====================================================
  //                      LOGIN
  // =====================================================

  Future<Map?> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
  String fixImage(String? url) {
    if (url == null || url.isEmpty) return "";

    // Already full URL
    if (url.startsWith("http")) return url;

    // Get base host (remove /api/admin)
    final base = API_URL.replaceAll("/api/admin", "");

    // ensure leading slash
    if (!url.startsWith("/")) url = "/$url";

    return "$base$url";
  }

}
