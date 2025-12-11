import 'package:dicoding_story/data/services/api/local/cache_datasource.dart';
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final CacheDatasource cacheDatasource;

  AuthInterceptor(this.cacheDatasource);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenEither = await cacheDatasource.getToken();
    tokenEither.fold((l) => handler.next(options), (r) {
      options.headers['Authorization'] = 'Bearer ${r.token}';
      handler.next(options);
    });
  }
}
