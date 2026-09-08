import '../../../../core/utils/app_import.dart';

class DioClient {
  DioClient({
    Dio? dio,
  }) : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
                headers: const {'Accept': 'application/json'},
              ),
            ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          Logging.info('${options.method} ${options.uri}', tag: 'Dio');
          handler.next(options);
        },
        onError: (error, handler) {
          Logging.error(
            'Request failed: ${error.requestOptions.uri} - ${error.message}',
            tag: 'Dio',
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;

  Future<Map<String, dynamic>> getJson(String url) async {
    try {
      final response = await dio.get<dynamic>(url);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw const ServerException('Unexpected response format.');
    } on DioException catch (error) {
      throw ServerException(error.message ?? 'Network request failed.');
    }
  }
}
