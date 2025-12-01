import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dicoding_story/utils/result.dart';

class SharedPreferencesService {
  static const _tokenKey = 'TOKEN';
  final _log = Logger('SharedPreferencesService');

  Future<Result<void>> saveToken(String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token == null) {
        _log.finer('Removed token');
        await prefs.remove(_tokenKey);
      } else {
        _log.finer('Saving token: $token');
        await prefs.setString(_tokenKey, token);
      }
      return Ok(null);
    } on Exception catch (e) {
      _log.warning('Failed to save token: $e');
      return Error(e);
    }
  }

  Future<Result<String?>> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _log.finer('Getting token');
      return Ok(prefs.getString(_tokenKey));
    } on Exception catch (e) {
      _log.warning('Failed to get token: $e');
      return Error(e);
    }
  }
}
