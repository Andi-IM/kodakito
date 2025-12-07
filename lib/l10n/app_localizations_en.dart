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
  String get authGreeting => 'Welcome back';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authBtnLogin => 'Login';

  @override
  String get authBtnRegister => 'Register';

  @override
  String get authFieldEmailLabel => 'Email *';

  @override
  String get authFieldEmailHint => 'email@domain.com';

  @override
  String get authFieldPasswordLabel => 'Password *';

  @override
  String get authFieldPasswordHint => '********';

  @override
  String get authFieldFullNameLabel => 'Full Name *';

  @override
  String get authFieldFullNameHint => 'Enter your name';

  @override
  String get authMsgNoAccount => 'Don\'t have an account? ';

  @override
  String get authLinkRegisterNow => 'Register now';

  @override
  String get authMsgHaveAccount => 'Already have an account? ';

  @override
  String get authLinkLoginNow => 'Login';

  @override
  String get authRegisterSuccessMessage => 'Register success, please login';

  @override
  String get storyBtnAddSemantic => 'Add new story';

  @override
  String get storyDetailTitle => 'Story Detail';

  @override
  String get addStoryTitle => 'Add Story';

  @override
  String get addStoryBtnPost => 'Post';

  @override
  String get addStoryBtnCancel => 'Cancel';

  @override
  String get addStoryImageLabel => 'Story Photo';

  @override
  String get addStoryUploadPlaceholder => 'Upload Image';

  @override
  String get addStoryDescriptionLabel => 'Description';

  @override
  String get addStoryDescriptionHint => 'Tell your experience...';

  @override
  String get addStoryBtnCamera => 'Camera';

  @override
  String get addStoryBtnGallery => 'Gallery';

  @override
  String get addStorySuccessMessage => 'Story posted successfully!';

  @override
  String get addStoryErrorEmptyDescription => 'Please enter a description';

  @override
  String get addStoryErrorEmptyImage => 'Please select an image';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBtnLogout => 'Logout';

  @override
  String get settingsBtnLogoutPrompt => 'Logout from app';

  @override
  String get settingsBtnLanguage => 'Language';

  @override
  String get settingsBtnLanguagePrompt => 'Select Language';

  @override
  String get settingsBtnDefault => 'System';

  @override
  String get settingsBtnLanguageID => 'Indonesian';

  @override
  String get settingsBtnLanguageEN => 'English';

  @override
  String get settingsBtnCancel => 'Cancel';

  @override
  String get settingsBtnTheme => 'Theme';

  @override
  String get settingsBtnThemePrompt => 'Choose app theme';

  @override
  String get settingsBtnThemeLight => 'Light';

  @override
  String get settingsBtnThemeDark => 'Dark';

  @override
  String settingsTextVersion(String version) {
    return 'version $version';
  }

  @override
  String get validatorRequired => 'This field cannot be empty';

  @override
  String get validatorEmailInvalid => 'Please enter a valid email address';

  @override
  String validatorMinLength(int length) {
    return 'Password must be at least $length characters long';
  }
}
