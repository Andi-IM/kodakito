import 'package:logging/logging.dart';

mixin LogMixin {
  Logger get log => Logger(runtimeType.toString());
}

void logError(String message, String runtimeType) {
  final logger = Logger(runtimeType);
  logger.warning(message);
}
