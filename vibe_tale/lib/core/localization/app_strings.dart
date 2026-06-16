import 'package:vibe_tale/core/error/auth_error.dart';

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
  String get searchEmpty => _isTr
      ? 'Kitap, yazar veya kategori gir'
      : 'Enter a book, author or category';
  String get searchCancel => _isTr ? 'İptal' : 'Cancel';
  String get popular => _isTr ? 'Popüler' : 'Popular';

  // ── Home Filters ──────────────────────────────────────────────────────────
  String get filterDiscoverMore => _isTr ? 'Daha fazla keşfet' : 'Explore More';
  String get filterClassics => _isTr ? 'Klasikler' : 'Classics';
  String get filterFairyTales => _isTr ? 'Masallar' : 'Fairy Tales';
  String get filterNovel => _isTr ? 'Roman' : 'Novel';
  String get filterFantasy => _isTr ? 'Fantastik' : 'Fantasy';

  String heroSubtitle(String category) =>
      _isTr ? '$category • Popüler' : '$category • Popular';

  String searchNoResults(String query) =>
      _isTr ? '"$query" için sonuç bulunamadı' : 'No results for "$query"';

  // ── Library ───────────────────────────────────────────────────────────────
  String get myLibrary => _isTr ? 'Kütüphanem' : 'My Library';
  String get tabReading => _isTr ? 'Okuyorum' : 'Reading';
  String get tabCompleted => _isTr ? 'Tamamladım' : 'Completed';
  String get tabSaved => _isTr ? 'Kaydedilenler' : 'Saved';
  String get books => _isTr ? 'kitap' : 'books';
  String get readingEmpty =>
      _isTr ? 'Henüz okumaya başlamadın' : "You haven't started reading yet";
  String get readingEmptySub =>
      _isTr ? 'Keşfet sekmesinden bir kitap seç' : 'Pick a book from Discover';
  String get completedEmpty =>
      _isTr ? 'Henüz kitap tamamlamadın' : 'No completed books yet';
  String get completedEmptySub => _isTr
      ? 'Okuduğun kitaplar burada görünecek'
      : 'Finished books will appear here';
  String get savedEmpty => _isTr ? 'Kaydedilen kitap yok' : 'No saved books';
  String get savedEmptySub => _isTr
      ? 'Kitap detayından kaydet butonuna bas'
      : 'Tap Save on any book detail page';
  String get completed => _isTr ? '% tamamlandı' : '% done';
  String get pages => _isTr ? 'sf.' : 'pg.';

  String percentDone(int pct) => _isTr ? '$pct% tamamlandı' : '$pct% done';
  String pagesProgress(int current, int total) =>
      _isTr ? '$current/$total sf.' : '$current/$total pg.';

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
  String get hoursSuffix => _isTr ? 's' : 'h';

  // ── Profile Badges ────────────────────────────────────────────────────────
  String get badgeStreak7 => _isTr ? '7 Gün Serisi' : '7-Day Streak';
  String get badgeFastReader => _isTr ? 'Hızlı Okuyucu' : 'Speed Reader';
  String get badgeFirstBook => _isTr ? 'İlk Kitap' : 'First Book';
  String get badgeSuperReader => _isTr ? 'Süper Okuyucu' : 'Super Reader';
  String get badgeMonthRecord => _isTr ? 'Ay Rekoru' : 'Month Record';

  List<String> get weekDays => _isTr
      ? ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settings => _isTr ? 'Ayarlar' : 'Settings';
  String get sectionGeneral => _isTr ? 'GENEL' : 'GENERAL';
  String get sectionAccount => _isTr ? 'HESAP' : 'ACCOUNT';
  String get notifications => _isTr ? 'Bildirimler' : 'Notifications';
  String get readingReminder =>
      _isTr ? 'Okuma Hatırlatıcısı' : 'Reading Reminder';
  String get theme => _isTr ? 'Tema' : 'Theme';
  String get themeDark => _isTr ? 'Karanlık' : 'Dark';
  String get themeLight => _isTr ? 'Aydınlık' : 'Light';
  String get language => _isTr ? 'Dil' : 'Language';
  String get selectLanguage => _isTr ? 'Dil Seç' : 'Select Language';
  String get languageChangedTr =>
      _isTr ? 'Dil Türkçe olarak değiştirildi' : 'Language changed to Turkish';
  String get languageChangedEn => 'Language changed to English';
  String get accountInfo => _isTr ? 'Hesap Bilgileri' : 'Account Info';
  String get privacy => _isTr ? 'Gizlilik' : 'Privacy';
  String get helpSupport => _isTr ? 'Yardım & Destek' : 'Help & Support';
  String get about => _isTr ? 'Hakkında' : 'About';
  String get logout => _isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutConfirmTitle => _isTr ? 'Çıkış Yap' : 'Log Out';
  String get logoutConfirmBody => _isTr
      ? 'Hesabından çıkmak istediğine emin misin?'
      : 'Are you sure you want to log out?';
  String get cancel => _isTr ? 'İptal' : 'Cancel';

  // ── Settings — Account Sheet ──────────────────────────────────────────────
  String get fullName => _isTr ? 'Ad Soyad' : 'Full Name';
  String get emailField => _isTr ? 'E-posta' : 'Email';
  String get membership => _isTr ? 'Üyelik' : 'Membership';
  String get plan => 'Plan';
  String get planFree => _isTr ? 'Ücretsiz' : 'Free';
  String get editAccount => _isTr ? 'Hesabı Düzenle' : 'Edit Account';

  // ── Settings — Privacy Sheet ──────────────────────────────────────────────
  String get hideReadingHistory =>
      _isTr ? 'Okuma Geçmişini Gizle' : 'Hide Reading History';
  String get publicProfile =>
      _isTr ? 'Profili Herkese Açık Göster' : 'Show Profile Publicly';
  String get shareAchievements =>
      _isTr ? 'Başarımları Paylaş' : 'Share Achievements';
  String get downloadData => _isTr ? 'Verileri İndir' : 'Download Data';
  String get deleteAccount => _isTr ? 'Hesabı Sil' : 'Delete Account';

  // ── Settings — Help Sheet ─────────────────────────────────────────────────
  String get faq => _isTr ? 'Sık Sorulan Sorular' : 'FAQ';
  String get contactUs => _isTr ? 'Bize Ulaşın' : 'Contact Us';
  String get sendFeedback => _isTr ? 'Geri Bildirim Gönder' : 'Send Feedback';
  String get reportBug => _isTr ? 'Hata Bildir' : 'Report Bug';

  // ── Settings — About Sheet ────────────────────────────────────────────────
  String get versionLabel => _isTr ? 'Versiyon 1.0.0' : 'Version 1.0.0';
  String get developer => _isTr ? 'Geliştirici' : 'Developer';
  String get license => _isTr ? 'Lisans' : 'License';
  String get buildDate => _isTr ? 'Yapı Tarihi' : 'Build Date';
  String get buildDateValue => _isTr ? 'Ocak 2025' : 'January 2025';

  // ── Book Details ──────────────────────────────────────────────────────────
  String get synopsis => _isTr ? 'Özet' : 'Synopsis';
  String get startReading => _isTr ? 'OKUMAYA BAŞLA' : 'START READING';
  String get addToLibrary => _isTr ? 'Kütüphaneye Ekle' : 'Add to Library';
  String get pages2 => _isTr ? 'sayfa' : 'pages';
  String get bookNotFound => _isTr ? 'Kitap bulunamadı' : 'Book not found';
  String get newBadge => _isTr ? 'YENİ' : 'NEW';
  String pageCountLabel(int n) => _isTr ? '$n sayfa' : '$n pages';

  // ── Auth — Login ──────────────────────────────────────────────────────────
  String get appTagline =>
      _isTr ? 'SÜRÜKLEYİCİ KÜTÜPHANENİZ' : 'YOUR IMMERSIVE LIBRARY';
  String get startYourJourney =>
      _isTr ? 'Yolculuğuna Başla' : 'Start Your Journey';
  String get loginSubtitle => _isTr
      ? 'Devam etmek için bilgilerini gir.'
      : 'Enter your credentials to continue.';
  String get emailLabel => _isTr ? 'E-posta Adresi' : 'Email Address';
  String get passwordLabel => _isTr ? 'Şifre' : 'Password';
  String get loginButton => _isTr ? 'GİRİŞ YAP' : 'LOG IN';
  String get orContinueWith =>
      _isTr ? 'VEYA ŞUNUNLA DEVAM ET' : 'OR CONTINUE WITH';
  String get magicLink => _isTr ? 'Sihirli Bağlantı' : 'Magic Link';
  String get forgotPassword => _isTr ? 'Şifremi Unuttum?' : 'Forgot Password?';
  String get newHere => _isTr ? 'Yeni misin? ' : 'New here? ';
  String get createAccount => _isTr ? 'Hesap Oluştur' : 'Create Account';

  // ── Auth — Signup ─────────────────────────────────────────────────────────
  String get startStoryPrefix => _isTr ? 'Hikayeni ' : 'Start Your ';
  String get startStoryAccent => _isTr ? 'Başlat' : 'Story';
  String get signupSubtitle => _isTr
      ? 'Kütüphaneni düzenlememize izin ver.\nKişiselleştirmeye başlamak için bilgilerini gir.'
      : 'Let us organize your library.\nEnter your details to start personalizing.';
  String get usernameLabel => _isTr ? 'Kullanıcı Adı' : 'Username';
  String get continueButton => _isTr ? 'Devam Et  →' : 'Continue  →';
  String get orSpeedUp =>
      _isTr ? 'Veya şununla hızlandır:' : 'Or speed up with:';
  String get alreadyMember =>
      _isTr ? 'Zaten üye misin? ' : 'Already a member? ';
  String get loginAction => _isTr ? 'Giriş Yap' : 'Log In';

  // ── Auth — Forgot Password ────────────────────────────────────────────────
  String get forgotPasswordTitle =>
      _isTr ? 'Şifreni Mi Unuttun?' : 'Forgot Your Password?';
  String get forgotPasswordSubtitle => _isTr
      ? 'E-posta adresini gir, sıfırlama bağlantısı gönderelim.'
      : 'Enter your email and we\'ll send a reset link.';
  String get sendResetLink => _isTr ? 'BAĞLANTI GÖNDER' : 'SEND RESET LINK';
  String get emailSentTitle => _isTr ? 'E-posta Gönderildi!' : 'Email Sent!';
  String get emailSentSubtitle => _isTr
      ? 'Gelen kutunu kontrol et ve sıfırlama bağlantısına tıkla.'
      : 'Check your inbox and click the reset link.';
  String get backToLogin => _isTr ? 'Girişe Geri Dön' : 'Back to Login';
  String get authError => _isTr ? 'Bir hata oluştu' : 'An error occurred';

  // ── Auth — Validation ─────────────────────────────────────────────────────
  String get errEmailEmpty =>
      _isTr ? 'E-posta adresi boş bırakılamaz.' : 'Email cannot be empty.';
  String get errEmailInvalid => _isTr
      ? 'Geçerli bir e-posta adresi gir.'
      : 'Enter a valid email address.';
  String get errPasswordEmpty =>
      _isTr ? 'Şifre boş bırakılamaz.' : 'Password cannot be empty.';
  String get errPasswordMin6 => _isTr
      ? 'Şifre en az 6 karakter olmalı.'
      : 'Password must be at least 6 characters.';
  String get errPasswordMin8 => _isTr
      ? 'Şifre en az 8 karakter olmalı.'
      : 'Password must be at least 8 characters.';
  String get errUsernameEmpty =>
      _isTr ? 'Kullanıcı adı boş bırakılamaz.' : 'Username cannot be empty.';
  String get errUsernameMin3 => _isTr
      ? 'Kullanıcı adı en az 3 karakter olmalı.'
      : 'Username must be at least 3 characters.';
  String get errUsernameChars => _isTr
      ? 'Sadece harf, rakam, nokta ve alt çizgi kullanılabilir.'
      : 'Only letters, numbers, dots and underscores allowed.';

  /// Localized message for a semantic auth error code (used in toasts).
  String authErrorMessage(AuthErrorCode code) => switch (code) {
    AuthErrorCode.invalidCredentials =>
      _isTr ? 'E-posta veya şifre hatalı.' : 'Invalid email or password.',
    AuthErrorCode.emailNotConfirmed =>
      _isTr
          ? 'Devam etmeden önce e-postanı doğrulaman gerekiyor.'
          : 'Please confirm your email before continuing.',
    AuthErrorCode.emailAlreadyInUse =>
      _isTr
          ? 'Bu e-posta adresi zaten kayıtlı.'
          : 'This email is already registered.',
    AuthErrorCode.weakPassword =>
      _isTr ? 'Şifre çok zayıf.' : 'Password is too weak.',
    AuthErrorCode.emailConfirmationRequired =>
      _isTr
          ? 'Kayıt başarılı. Lütfen e-postanı doğrula.'
          : 'Sign-up successful. Please confirm your email.',
    AuthErrorCode.network =>
      _isTr
          ? 'İnternet bağlantını kontrol et.'
          : 'Check your internet connection.',
    AuthErrorCode.unknown =>
      _isTr
          ? 'Bir hata oluştu. Lütfen tekrar dene.'
          : 'Something went wrong. Please try again.',
  };

  // ── File Upload ───────────────────────────────────────────────────────────
  String get urlPaste => _isTr ? 'URL Yapıştır' : 'Paste URL';
  String get cloudImport => _isTr ? 'Buluttan İçe Aktar' : 'Import from Cloud';
  String get supportedFormats => _isTr
      ? 'Desteklenen formatlar: EPUB, PDF, DOCX, TXT'
      : 'Supported formats: EPUB, PDF, DOCX, TXT';
  String get unsupportedFormat => _isTr
      ? 'Desteklenmeyen dosya formatı. Lütfen şunlardan birini seç: EPUB, PDF, DOCX, TXT'
      : 'Unsupported file format. Please choose one of: EPUB, PDF, DOCX, TXT';
  String get uploadTitle => _isTr ? 'Dosya Yükle' : 'Upload File';
  String get uploadPreparing => _isTr ? 'Hazırlanıyor...' : 'Preparing...';
  String get uploadUploading => _isTr ? 'Yükleniyor' : 'Uploading';
  String get uploadDone => _isTr ? 'Tamamlandı!' : 'Done!';
  String get uploadError => _isTr ? 'Hata Oluştu' : 'Error Occurred';
  String get uploadIdleSubtitle => _isTr
      ? 'Hikayeni buraya bırak veya\narşivlerine göz atmak için dokun.'
      : 'Drop your story here or\ntap to browse your files.';
  String uploadingSubtitle(String name) =>
      _isTr ? '"$name" yükleniyor' : 'Uploading "$name"';
  String uploadDoneSubtitle(String name) => _isTr
      ? '$name\nKütüphanene başarıyla eklendi.'
      : '$name\nSuccessfully added to your library.';
  String get uploadErrorSubtitle => _isTr
      ? 'Dosya yüklenemedi. Tekrar dene.'
      : 'File could not be uploaded. Try again.';
  String get browseFiles => _isTr ? 'Dosyalara Göz At' : 'Browse Files';
  String get goToLibrary => _isTr ? 'Kütüphaneye Git' : 'Go to Library';
  String get addAnotherFile => _isTr ? 'Başka Dosya Ekle' : 'Add Another File';
  String get vibeEngineReady => _isTr ? 'VIBEENGINE HAZIR' : 'VIBEENGINE READY';
  String get vibeEngineAnalyzed =>
      _isTr ? 'Analiz Tamamlandı' : 'Analysis Complete';
  String get importButton => _isTr ? 'İçe Aktar' : 'Import';
  String get driveSub => _isTr
      ? 'Drive hesabınızdan içe aktarın'
      : 'Import from your Drive account';
  String get dropboxSub =>
      _isTr ? 'Dropbox klasörünüzden seçin' : 'Select from your Dropbox folder';
  String get icloudSub =>
      _isTr ? 'Apple iCloud dosyalarınız' : 'Your Apple iCloud files';

  // ── Stats / Leaderboard ───────────────────────────────────────────────────
  String get leaderboard => _isTr ? 'Liderler' : 'Leaderboard';
  String get periodWeek => _isTr ? 'Hafta' : 'Week';
  String get periodMonth => _isTr ? 'Ay' : 'Month';
  String get periodAll => _isTr ? 'Tüm' : 'All';
  String get ranking => _isTr ? 'Sıralama' : 'Ranking';
  String get booksReadLabel => _isTr ? 'Okunan Kitap' : 'Books Read';
  String get myStatus => _isTr ? 'Benim Durumum' : 'My Status';
  String get rankLabel => _isTr ? 'Sıra' : 'Rank';
  String get youBadge => _isTr ? 'SEN' : 'YOU';
  String get booksWord => _isTr ? 'kitap' : 'books';
  String streakLine(int days, int pages) =>
      _isTr ? '🔥 $days gün • $pages sayfa' : '🔥 $days days • $pages pages';
}
