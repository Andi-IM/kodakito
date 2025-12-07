import 'package:dicoding_story/common/localizations.dart';
import 'package:flutter/widgets.dart';

class Validators {
  static String? required(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validatorRequired;
    }
    return null;
  }

  static String? email(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.l10n.validatorRequired;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return context.l10n.validatorEmailInvalid;
    }
    return null;
  }

  static String? minLength(BuildContext context, String? value, int length) {
    if (value == null || value.isEmpty) {
      return context.l10n.validatorRequired;
    }
    if (value.length < length) {
      return context.l10n.validatorMinLength(length);
    }
    return null;
  }
}
