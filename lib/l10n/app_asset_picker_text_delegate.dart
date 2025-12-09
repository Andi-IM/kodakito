// coverage:ignore-file
import 'package:insta_assets_picker/insta_assets_picker.dart';

class IndonesianAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const IndonesianAssetPickerTextDelegate();

  @override
  String get languageCode => 'id';

  @override
  String get confirm => 'Konfirmasi';

  @override
  String get cancel => 'Batal';

  @override
  String get edit => 'Edit';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get livePhotoIndicator => 'LIVE';

  @override
  String get loadFailed => 'Gagal memuat';

  @override
  String get original => 'Asli';

  @override
  String get preview => 'Pratinjau';

  @override
  String get select => 'Pilih';

  @override
  String get emptyList => 'Daftar kosong';

  @override
  String get unSupportedAssetType => 'Tipe aset HEIC tidak didukung.';

  @override
  String get unableToAccessAll =>
      'Tidak dapat mengakses semua aset di perangkat';

  @override
  String get viewingLimitedAssetsTip =>
      'Hanya melihat aset dan album yang dapat diakses aplikasi.';

  @override
  String get changeAccessibleLimitedAssets =>
      'Klik untuk memperbarui aset yang dapat diakses';

  @override
  String get accessAllTip =>
      'Aplikasi hanya dapat mengakses beberapa aset di perangkat. '
      'Buka pengaturan sistem dan izinkan aplikasi mengakses semua aset di perangkat.';

  @override
  String get goToSystemSettings => 'Buka pengaturan sistem';

  @override
  String get accessLimitedAssets => 'Lanjutkan dengan akses terbatas';

  @override
  String get accessiblePathName => 'Aset yang dapat diakses';

  @override
  String get sTypeAudioLabel => 'Audio';

  @override
  String get sTypeImageLabel => 'Gambar';

  @override
  String get sTypeVideoLabel => 'Video';

  @override
  String get sTypeOtherLabel => 'Aset lainnya';

  @override
  String get sActionPlayHint => 'putar';

  @override
  String get sActionPreviewHint => 'pratinjau';

  @override
  String get sActionSelectHint => 'pilih';

  @override
  String get sActionSwitchPathLabel => 'ganti jalur';

  @override
  String get sActionUseCameraHint => 'gunakan kamera';

  @override
  String get sNameDurationLabel => 'durasi';

  @override
  String get sUnitAssetCountLabel => 'jumlah';
}
