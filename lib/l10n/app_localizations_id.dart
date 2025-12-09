// coverage:ignore-file
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'KodaKito';

  @override
  String get authGreeting => 'Selamat Datang';

  @override
  String get authRegisterTitle => 'Buat Akun';

  @override
  String get authBtnLogin => 'Masuk';

  @override
  String get authBtnRegister => 'Daftar';

  @override
  String get authFieldEmailLabel => 'Email *';

  @override
  String get authFieldEmailHint => 'email@domain.com';

  @override
  String get authFieldPasswordLabel => 'Kata Sandi *';

  @override
  String get authFieldPasswordHint => '********';

  @override
  String get authFieldFullNameLabel => 'Nama Lengkap *';

  @override
  String get authFieldFullNameHint => 'Masukkan nama anda';

  @override
  String get authMsgNoAccount => 'Belum Punya Akun? ';

  @override
  String get authLinkRegisterNow => 'Daftar Sekarang';

  @override
  String get authMsgHaveAccount => 'Sudah Punya Akun? ';

  @override
  String get authLinkLoginNow => 'Masuk';

  @override
  String get authRegisterSuccessMessage =>
      'Register berhasil, silahkan login terlebih dahulu';

  @override
  String get storyBtnAddSemantic => 'Tambah Cerita Baru';

  @override
  String get storyDetailTitle => 'Detail Cerita';

  @override
  String get addStoryTitle => 'Tambah Cerita';

  @override
  String get addStoryBtnPost => 'Posting';

  @override
  String get addStoryBtnCancel => 'Batal';

  @override
  String get addStoryImageLabel => 'Foto Cerita';

  @override
  String get addStoryUploadPlaceholder => 'Unggah Gambar';

  @override
  String get addStoryDescriptionLabel => 'Deskripsi';

  @override
  String get addStoryDescriptionHint => 'Ceritakan pengalamanmu...';

  @override
  String get addStoryBtnCamera => 'Kamera';

  @override
  String get addStoryBtnCameraCrop => 'Potong';

  @override
  String get addStoryBtnGallery => 'Galeri';

  @override
  String get addStorySuccessMessage => 'Cerita berhasil diposting!';

  @override
  String get addStoryErrorEmptyDescription => 'Silakan masukkan deskripsi';

  @override
  String get addStoryErrorEmptyImage => 'Silakan pilih gambar';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsBtnLogout => 'Keluar';

  @override
  String get settingsBtnLogoutPrompt => 'Logout dari aplikasi';

  @override
  String get settingsBtnLanguage => 'Bahasa';

  @override
  String get settingsBtnLanguagePrompt => 'Pilih Bahasa';

  @override
  String get settingsBtnDefault => 'System';

  @override
  String get settingsBtnLanguageID => 'Bahasa Indonesia';

  @override
  String get settingsBtnLanguageEN => 'Bahasa Inggris';

  @override
  String get settingsBtnCancel => 'Batal';

  @override
  String get settingsBtnTheme => 'Tema';

  @override
  String get settingsBtnThemePrompt => 'Pilih tema aplikasi';

  @override
  String get settingsBtnThemeLight => 'Tema Terang';

  @override
  String get settingsBtnThemeDark => 'Tema Gelap';

  @override
  String settingsTextVersion(String version) {
    return 'versi $version';
  }

  @override
  String get validatorRequired => 'Tidak boleh kosong';

  @override
  String get validatorEmailInvalid => 'Masukkan alamat email yang valid';

  @override
  String validatorMinLength(int length) {
    return 'Password harus terdiri dari minimal $length karakter';
  }
}
