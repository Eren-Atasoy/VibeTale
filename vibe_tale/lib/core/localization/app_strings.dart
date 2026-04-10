/// Simple bilingual string table for VibeTale (Turkish / English).
/// Add new keys here as screens are translated.
class AppStrings {
  const AppStrings(this._locale);

  final String _locale;

  bool get _isTr => _locale == 'tr';

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  String get navHome => _isTr ? 'Anasayfa' : 'Home';
  String get navLibrary => _isTr ? 'Kütüphane' : 'Library';
  String get navNew => _isTr ? 'Yeni' : 'New';
  String get navStats => _isTr ? 'Puanlar' : 'Scores';
  String get navProfile => _isTr ? 'Profil' : 'Profile';

  // ── Home ──────────────────────────────────────────────────────────────────
  String get discover => _isTr ? 'Keşfet' : 'Discover';
  String get readNow => _isTr ? 'ŞİMDİ OKU' : 'READ NOW';
  String get weeklyPicks => _isTr ? 'Haftanın Önerileri' : 'Weekly Picks';
  String get darkPast => _isTr ? 'Karanlık Geçmiş' : 'Dark Past';
  String get popularAuthors => _isTr ? 'Popüler Yazarlar' : 'Popular Authors';
  String get searchHint =>
      _isTr ? 'Kitap, yazar veya kategori ara...' : 'Search books, authors...';
  String get searchEmpty =>
      _isTr ? 'Kitap, yazar veya kategori gir' : 'Enter a book, author or category';
  String get searchCancel => _isTr ? 'İptal' : 'Cancel';
  String get popular => _isTr ? 'Popüler' : 'Popular';

  // ── Library ───────────────────────────────────────────────────────────────
  String get myLibrary => _isTr ? 'Kütüphanem' : 'My Library';
  String get tabReading => _isTr ? 'Okuyorum' : 'Reading';
  String get tabCompleted => _isTr ? 'Tamamladım' : 'Completed';
  String get tabSaved => _isTr ? 'Kaydedilenler' : 'Saved';
  String get books => _isTr ? 'kitap' : 'books';
  String get readingEmpty =>
      _isTr ? 'Henüz okumaya başlamadın' : 'You haven\'t started reading yet';
  String get readingEmptySub =>
      _isTr ? 'Keşfet sekmesinden bir kitap seç' : 'Pick a book from Discover';
  String get completedEmpty =>
      _isTr ? 'Henüz kitap tamamlamadın' : 'No completed books yet';
  String get completedEmptySub =>
      _isTr ? 'Okuduğun kitaplar burada görünecek' : 'Finished books will appear here';
  String get savedEmpty => _isTr ? 'Kaydedilen kitap yok' : 'No saved books';
  String get savedEmptySub =>
      _isTr ? 'Kitap detayından kaydet butonuna bas' : 'Tap Save on any book detail page';
  String get completed => _isTr ? '% tamamlandı' : '% done';
  String get pages => _isTr ? 'sf.' : 'pg.';

  // ── Profile ───────────────────────────────────────────────────────────────
  String get myProfile => _isTr ? 'Profilim' : 'My Profile';
  String get editProfile => _isTr ? 'Profili Düzenle' : 'Edit Profile';
  String get memberSince => _isTr ? 'tarihinden beri üye' : 'member since';
  String get booksRead => _isTr ? 'Okunan' : 'Read';
  String get booksCompleted => _isTr ? 'Tamamlanan' : 'Completed';
  String get totalHours => _isTr ? 'Toplam Saat' : 'Total Hours';
  String get achievements => _isTr ? 'Başarımlar' : 'Achievements';
  String get thisWeek => _isTr ? 'Bu Hafta' : 'This Week';
  String get minutes => _isTr ? 'dk' : 'min';

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settings => _isTr ? 'Ayarlar' : 'Settings';
  String get sectionGeneral => _isTr ? 'GENEL' : 'GENERAL';
  String get sectionAccount => _isTr ? 'HESAP' : 'ACCOUNT';
  String get notifications => _isTr ? 'Bildirimler' : 'Notifications';
  String get readingReminder => _isTr ? 'Okuma Hatırlatıcısı' : 'Reading Reminder';
  String get theme => _isTr ? 'Tema' : 'Theme';
  String get themeDark => _isTr ? 'Karanlık' : 'Dark';
  String get themeLight => _isTr ? 'Aydınlık' : 'Light';
  String get language => _isTr ? 'Dil' : 'Language';
  String get accountInfo => _isTr ? 'Hesap Bilgileri' : 'Account Info';
  String get privacy => _isTr ? 'Gizlilik' : 'Privacy';
  String get helpSupport => _isTr ? 'Yardım & Destek' : 'Help & Support';
  String get about => _isTr ? 'Hakkında' : 'About';
  String get logout => _isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutConfirmTitle => _isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutConfirmBody =>
      _isTr ? 'Hesabından çıkmak istediğine emin misin?' : 'Are you sure you want to log out?';
  String get cancel => _isTr ? 'İptal' : 'Cancel';

  // ── Book Details ──────────────────────────────────────────────────────────
  String get synopsis => _isTr ? 'Özet' : 'Synopsis';
  String get startReading => _isTr ? 'OKUMAYA BAŞLA' : 'START READING';
  String get addToLibrary => _isTr ? 'Kütüphaneye Ekle' : 'Add to Library';
  String get pages2 => _isTr ? 'sayfa' : 'pages';
  String get bookNotFound => _isTr ? 'Kitap bulunamadı' : 'Book not found';
}
