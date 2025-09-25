import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // TODO: handle token expiration or errors globally
        return handler.next(e);
      },
    ));

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, dynamic data) async {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, dynamic data) async {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) async {
    return _dio.delete<T>(path);
  }
}
