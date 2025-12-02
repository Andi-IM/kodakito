import 'package:dicoding_story/data/services/local/shared_prefs_storage_service.dart';
import 'package:dicoding_story/data/services/remote/dio_netowork_service.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'domain_providers.g.dart';

@riverpod
SharedPrefsService storageService(storageServiceProvider) {
  final prefsService = SharedPrefsService();
  prefsService.init();
  return prefsService;
}

@riverpod
DioNetworkService dioNetworkService(networkServiceProvider) =>
    DioNetworkService(Dio());
