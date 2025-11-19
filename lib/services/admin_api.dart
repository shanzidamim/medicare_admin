import 'dart:io';
import 'package:dio/dio.dart';

import 'config.dart';

class AdminApi {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: API_URL,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  // ---------------- Get Doctors ----------------
  Future<List> getDoctors() async {
    final res = await _dio.get('/doctors');
    return res.data['data'] ?? [];
  }

  // ---------------- Create Doctor ----------------
  Future<int> createDoctor(Map data) async {
    final res = await _dio.post('/doctors', data: data);
    if (res.data['id'] != null) {
      return res.data['id']; // Return created doctor ID
    }
    throw Exception('Create doctor failed');
  }

  // ---------------- Update Doctor ----------------
  Future<void> updateDoctor(int id, Map data) async =>
      _dio.put('/doctors/$id', data: data);

  // ---------------- Delete Doctor ----------------
  Future<void> deleteDoctor(int id) async =>
      _dio.delete('/doctors/$id');

  // ---------------- Upload Doctor Image ----------------
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
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }


  // ---------------- Shops  ----------------
  // ---------------- Shops  ----------------
  Future<List> getShops() async {
    // baseUrl: API_URL (e.g. http://.../api/admin)
    // → this hits  /api/admin/shops   (matches app.js)
    final res = await _dio.get('/shops');
    return res.data['data'] ?? [];
  }

  Future<Response> createShop(Map data) async {
    final res = await _dio.post('/shops', data: data);
    return res; // <--- VERY IMPORTANT
  }


  Future<void> updateShop(int id, Map data) async =>
      _dio.put('/shops/$id', data: data);

  Future<void> deleteShop(int id) async =>
      _dio.delete('/shops/$id');

  Future<void> uploadShopImage(int id, File file) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    // public route: /api/shop/:id/upload
    await _dio.post(
      '/shop/$id/upload',
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

// ------- Divisions for dropdown (works even if API_URL has /admin) ------
  Future<List> fetchDivisions() async {
    // Make a second Dio that points to /api instead of /api/admin
    final dioDiv = Dio(BaseOptions(
      baseUrl: API_URL.replaceFirst('/admin', ''),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    final res = await dioDiv.get('/divisions'); // -> /api/divisions
    return res.data['data'] ?? [];
  }




  Future<List> getUsers() async {
    final res = await _dio.get('/users');
    return res.data['data'] ?? [];
  }

  Future<void> deleteUser(int id) async =>
      _dio.delete('/users/$id');

  Future<List> getAppointments() async {
    final res = await _dio.get('/appointments');
    return res.data['data'] ?? [];
  }

  Future<void> deleteAppointment(int id) async =>
      _dio.delete('/appointments/$id');

  Future<Map?> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }
}
