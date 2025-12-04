import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'KodaKito'**
  String get appTitle;

  /// No description provided for @authGreeting.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang'**
  String get authGreeting;

  /// No description provided for @authRegisterTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun'**
  String get authRegisterTitle;

  /// No description provided for @authBtnLogin.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authBtnLogin;

  /// No description provided for @authBtnRegister.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get authBtnRegister;

  /// No description provided for @authFieldEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email *'**
  String get authFieldEmailLabel;

  /// No description provided for @authFieldEmailHint.
  ///
  /// In id, this message translates to:
  /// **'email@domain.com'**
  String get authFieldEmailHint;

  /// No description provided for @authFieldPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi *'**
  String get authFieldPasswordLabel;

  /// No description provided for @authFieldPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'********'**
  String get authFieldPasswordHint;

  /// No description provided for @authFieldFullNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap *'**
  String get authFieldFullNameLabel;

  /// No description provided for @authFieldFullNameHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama anda'**
  String get authFieldFullNameHint;

  /// No description provided for @authMsgNoAccount.
  ///
  /// In id, this message translates to:
  /// **'Belum Punya Akun? '**
  String get authMsgNoAccount;

  /// No description provided for @authLinkRegisterNow.
  ///
  /// In id, this message translates to:
  /// **'Daftar Sekarang'**
  String get authLinkRegisterNow;

  /// No description provided for @authMsgHaveAccount.
  ///
  /// In id, this message translates to:
  /// **'Sudah Punya Akun? '**
  String get authMsgHaveAccount;

  /// No description provided for @authLinkLoginNow.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get authLinkLoginNow;

  /// No description provided for @storyBtnAddSemantic.
  ///
  /// In id, this message translates to:
  /// **'Tambah Cerita Baru'**
  String get storyBtnAddSemantic;

  /// No description provided for @storyDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Cerita'**
  String get storyDetailTitle;

  /// No description provided for @addStoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah Cerita'**
  String get addStoryTitle;

  /// No description provided for @addStoryBtnPost.
  ///
  /// In id, this message translates to:
  /// **'Posting'**
  String get addStoryBtnPost;

  /// No description provided for @addStoryBtnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get addStoryBtnCancel;

  /// No description provided for @addStoryImageLabel.
  ///
  /// In id, this message translates to:
  /// **'Foto Cerita'**
  String get addStoryImageLabel;

  /// No description provided for @addStoryUploadPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Unggah Gambar'**
  String get addStoryUploadPlaceholder;

  /// No description provided for @addStoryDescriptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get addStoryDescriptionLabel;

  /// No description provided for @addStoryDescriptionHint.
  ///
  /// In id, this message translates to:
  /// **'Ceritakan pengalamanmu...'**
  String get addStoryDescriptionHint;

  /// No description provided for @addStoryBtnCamera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get addStoryBtnCamera;

  /// No description provided for @addStoryBtnGallery.
  ///
  /// In id, this message translates to:
  /// **'Galeri'**
  String get addStoryBtnGallery;

  /// No description provided for @addStorySuccessMessage.
  ///
  /// In id, this message translates to:
  /// **'Cerita berhasil diposting!'**
  String get addStorySuccessMessage;

  /// No description provided for @addStoryErrorEmptyDescription.
  ///
  /// In id, this message translates to:
  /// **'Silakan masukkan deskripsi'**
  String get addStoryErrorEmptyDescription;

  /// No description provided for @addStoryErrorEmptyImage.
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih gambar'**
  String get addStoryErrorEmptyImage;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsBtnLogout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get settingsBtnLogout;

  /// No description provided for @settingsBtnLogoutPrompt.
  ///
  /// In id, this message translates to:
  /// **'Logout dari aplikasi'**
  String get settingsBtnLogoutPrompt;

  /// No description provided for @settingsBtnLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsBtnLanguage;

  /// No description provided for @settingsBtnLanguagePrompt.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa'**
  String get settingsBtnLanguagePrompt;

  /// No description provided for @settingsBtnDefault.
  ///
  /// In id, this message translates to:
  /// **'System'**
  String get settingsBtnDefault;

  /// No description provided for @settingsBtnLanguageID.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get settingsBtnLanguageID;

  /// No description provided for @settingsBtnLanguageEN.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Inggris'**
  String get settingsBtnLanguageEN;

  /// No description provided for @settingsBtnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get settingsBtnCancel;

  /// No description provided for @settingsBtnTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get settingsBtnTheme;

  /// No description provided for @settingsBtnThemePrompt.
  ///
  /// In id, this message translates to:
  /// **'Pilih tema aplikasi'**
  String get settingsBtnThemePrompt;

  /// No description provided for @settingsBtnThemeLight.
  ///
  /// In id, this message translates to:
  /// **'Tema Terang'**
  String get settingsBtnThemeLight;

  /// No description provided for @settingsBtnThemeDark.
  ///
  /// In id, this message translates to:
  /// **'Tema Gelap'**
  String get settingsBtnThemeDark;

  /// Version text in settings dialog
  ///
  /// In id, this message translates to:
  /// **'versi {version}'**
  String settingsTextVersion(String version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
