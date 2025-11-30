// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'KodaKito';

  @override
  String get authBtnLogin => 'Login';

  @override
  String get authBtnRegister => 'Register';

  @override
  String get authFieldEmailHint => 'Email';

  @override
  String get authFieldPasswordHint => 'Password';

  @override
  String get authFieldFullNameHint => 'Full Name';

  @override
  String get authMsgNoAccount => 'Don\'t have an account?';

  @override
  String get authLinkRegisterNow => 'Register now';

  @override
  String get authMsgHaveAccount => 'Already have an account?';

  @override
  String get authLinkLoginNow => 'Login';

  @override
  String get storyBtnAddSemantic => 'Add new story';

  @override
  String get storyDetailTitle => 'Story Detail';

  @override
  String get addStoryTitle => 'Add Story';

  @override
  String get addStoryBtnPost => 'Post';

  @override
  String get addStoryImageLabel => 'Story Photo';

  @override
  String get addStoryUploadPlaceholder => 'Upload Image';

  @override
  String get addStoryDescriptionLabel => 'Description';

  @override
  String get addStoryDescriptionHint => 'Tell your experience...';
}
