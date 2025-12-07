import 'package:logging/logging.dart';

mixin LogMixin {
  Logger get log => Logger(runtimeType.toString());
}
