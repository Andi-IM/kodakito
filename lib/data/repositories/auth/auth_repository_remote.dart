import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/data/services/remote/story/story_api.dart';
import 'package:dicoding_story/data/services/remote/auth/story_auth_api.dart';
import 'package:dicoding_story/data/services/shared_preferences_service.dart';
import 'package:dicoding_story/utils/http_exception.dart' show AppException;
import 'package:dicoding_story/utils/result.dart';
import 'package:logging/logging.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required StoryApi storyApi,
    required StoryAuthApi storyAuthApi,
    required SharedPreferencesService sharedPreferencesService,
  }) : _storyApi = storyApi,
       _storyAuthApi = storyAuthApi,
       _sharedPreferencesService = sharedPreferencesService {
    _storyApi.authHeaderProvider = _authHeaderProvider;
  }

  final StoryApi _storyApi;
  final StoryAuthApi _storyAuthApi;
  final SharedPreferencesService _sharedPreferencesService;

  bool? _isAuthenticated;
  String? _token;
  final _log = Logger('AuthRepositoryRemote');

  /// Fetch token from shared preferences
  Future<void> _fetchToken() async {
    final result = await _sharedPreferencesService.getToken();
    switch (result) {
      case Ok(value: final token):
        _token = token;
        _isAuthenticated = token != null;
      case Error(error: final error):
        _log.severe('Failed to fetch token: $error');
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    // Status is cached
    if (_isAuthenticated != null) {
      return _isAuthenticated!;
    }
    await _fetchToken();
    return _isAuthenticated ?? false;
  }

  @override
  Future<Either<AppException, void>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final result = await _storyAuthApi.register(
      registerRequest: RegisterRequest(
        email: email,
        password: password,
        name: name,
      ),
    );
    return result.fold((exception) => Left(exception), (response) async {
      _log.info('Register success');
      return Right(null);
    });
  }

  @override
  Future<Either<AppException, void>> login({
    required String email,
    required String password,
  }) async {
    final result = await _storyAuthApi.login(
      LoginRequest(email: email, password: password),
    );
    return result.fold((exception) => Left(exception), (response) async {
      _log.info('Login success');
      _token = response.loginResult.token;
      _isAuthenticated = true;
      await _sharedPreferencesService.saveToken(response.loginResult.token);
      return Right(null);
    });
  }

  @override
  Future<Either<AppException, void>> logout() async {
    _log.info('User logged out');
    // CLear stored auth token
    final result = await _sharedPreferencesService.saveToken(null);
    if (result is Error<void>) {
      _log.severe('Failed to remove token: ${result.error}');
    }

    // Clear token in client
    _token = null;
    // Clear authentication status
    _isAuthenticated = false;
    return Right(null);
  }

  String? _authHeaderProvider() => _token != null ? 'Bearer $_token' : null;
}
