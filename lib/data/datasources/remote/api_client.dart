import 'package:dio/dio.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/constants/app_constants.dart';
import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/auth_model.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/product_list_response.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/product_model.dart';

class ApiClient {
  ApiClient({String? token}) {
    _token = token;
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_AuthInterceptor(() => _token));

    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => print(o), // ignore: avoid_print
        ),
      );
      return true;
    }());
  }

  late final Dio _dio;
  String? _token;

  void updateToken(String? token) => _token = token;

  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 60,
        },
      );
      return AuthModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ProductListResponse> getProducts({
    int limit = AppConstants.pageSize,
    int skip = 0,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products',
        queryParameters: {'limit': limit, 'skip': skip},
      );
      return ProductListResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ProductListResponse> searchProducts(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/products/search',
        queryParameters: {'q': query},
      );
      return ProductListResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/products/$id');
      return ProductModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  AppException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
              'Unauthorised';
      return AuthException(message);
    }

    if (statusCode == 404) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
              'Resource not found';
      return NotFoundException(message);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network.',
        );
      default:
        return NetworkException(
          e.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._tokenProvider);

  final String? Function() _tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
