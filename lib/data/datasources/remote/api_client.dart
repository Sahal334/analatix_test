import 'package:dio/dio.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/constants/app_constants.dart';
import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/secure_storage_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/auth_model.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/product_list_response.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/models/product_model.dart';

class ApiClient {
  ApiClient({
    String? token,
    SecureStorageService? secureStorage,
  }) {
    _token = token;
    _secureStorage = secureStorage;
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

    _dio.interceptors.add(
      _AuthInterceptor(
        tokenProvider: () => _token,
        onTokenUpdated: (newToken) => _token = newToken,
        secureStorage: _secureStorage,
        dio: _dio,
      ),
    );

    assert(() {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
      return true;
    }());
  }

  late final Dio _dio;
  String? _token;
  late final SecureStorageService? _secureStorage;

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

  Future<AuthModel> refreshSession(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
          'expiresInMins': 60,
        },
      );
      final model = AuthModel.fromJson(response.data!);
      updateToken(model.accessToken);
      return model;
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
              'Invalid credentials or session expired';
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
        return const NetworkException('Request timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const NetworkException(
          'No internet connection. Please check your network.',
        );
      default:
        return NetworkException(
          e.message ?? 'An unexpected network error occurred.',
        );
    }
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  _AuthInterceptor({
    required String? Function() tokenProvider,
    required void Function(String?) onTokenUpdated,
    required SecureStorageService? secureStorage,
    required Dio dio,
  }) {
    _tokenProvider = tokenProvider;
    _onTokenUpdated = onTokenUpdated;
    _secureStorage = secureStorage;
    _dio = dio;
  }

  late final String? Function() _tokenProvider;
  late final void Function(String?) _onTokenUpdated;
  late final SecureStorageService? _secureStorage;
  late final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenProvider();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/login') &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        _secureStorage != null) {
      try {
        final refreshToken = await _secureStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: AppConstants.baseUrl,
              headers: {'Content-Type': 'application/json'},
            ),
          );

          final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {
              'refreshToken': refreshToken,
              'expiresInMins': 60,
            },
          );

          final data = refreshResponse.data;
          final newAccessToken =
              (data?['accessToken'] ?? data?['token']) as String?;
          final newRefreshToken = data?['refreshToken'] as String?;

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            _onTokenUpdated(newAccessToken);
            await _secureStorage.saveToken(newAccessToken);
            if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
              await _secureStorage.saveRefreshToken(newRefreshToken);
            }

            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final response = await _dio.fetch(options);
            return handler.resolve(response);
          }
        }
      } catch (_) {
        await _secureStorage.clearAll();
      }
    }
    handler.next(err);
  }
}
